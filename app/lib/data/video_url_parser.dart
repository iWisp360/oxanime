import "package:collection/collection.dart";
import "package:html/dom.dart";
import "package:html/parser.dart";
import "package:http/http.dart";
import "package:oxanime/core/constants.dart";
import "package:oxanime/core/enums.dart";
import "package:oxanime/core/exceptions.dart";
import "package:oxanime/core/logs.dart";
import "package:oxanime/data/html_parser.dart";
import "package:oxanime/data/networking.dart";

class StreamTape with VideoSourceParameters {
  @override
  bool get needsAWebView => false;

  static Future<String> getVideoFromUrl(final String url) async {
    late final Client client;
    late final String responseBody;

    try {
      client = Client();
      responseBody = (await client.get(Uri.parse(url))).body;
    } catch (e, s) {
      throw VideoUrlParserException(
        errorMsg: e,
        stackTrace: s,
        kind: VideoUrlParserExceptionKind.responseReceiveException,
      );
    }

    final elementSelectFirst = (await SourceHtmlParser.create(html: responseBody)).serializedHtml
        .querySelectorAll(scriptHtmlCSSClass)
        .firstWhereOrNull(
          (element) => element.text.contains("document.getElementById('robotlink')"),
        );

    final firstDelimiter = "document.getElementById('robotlink').innerHTML = '";
    final secondDelimiter = "+ ('xcd";

    if (elementSelectFirst == null || !responseBody.contains(firstDelimiter)) {
      return PlaceHolders.emptyString;
    }

    final strSubstringAfter = elementSelectFirst.text.substring(
      elementSelectFirst.text.indexOf(firstDelimiter) + firstDelimiter.length,
    );

    final firstQuoteIndex = strSubstringAfter.indexOf("'");
    final secondDelimiterIndex = strSubstringAfter.indexOf(secondDelimiter);

    if (firstQuoteIndex == -1 || secondDelimiterIndex == -1) return PlaceHolders.emptyString;

    final afterSecondDelimiter = strSubstringAfter.substring(
      secondDelimiterIndex + secondDelimiter.length,
    );

    final secondQuoteIndex = afterSecondDelimiter.indexOf("'");

    if (secondQuoteIndex == -1) return PlaceHolders.emptyString;

    final part1 = strSubstringAfter.substring(0, firstQuoteIndex);
    final part2 = afterSecondDelimiter.substring(0, secondQuoteIndex);

    return "https:$part1$part2";
  }
}

mixin VideoSourceParameters {
  bool get needsAWebView;
}

// In this context, a parser is the utility that brings you the content you need to watch a serie chapter,
// either by natively streaming it or embedding a webview player if getting a URL is not possible.
// A parser gets the following contents if available:
// - URL or a List of URLs of the static content of the video
// - Video Quality Options -> not implemented
// - Video Duration -> MediaKit does this, so these things actually don't

class VideoSources {
  static List<String> videoSourcesDomainNames(VideoSourceParsers videoSource) {
    return switch (videoSource) {
      VideoSourceParsers.yourUpload => ["yourupload.com"],
      VideoSourceParsers.streamTape => ["streamtape.com"],
    };
  }
}

class YourUpload with VideoSourceParameters {
  @override
  bool get needsAWebView => false;

  static Future<String> getVideoFromUrl(final String url) async {
    const startMark = "file: '";
    const endMark = "',";
    late final Client client;
    late final Request request;
    try {
      client = Client();
      request = Request("GET", Uri.parse(url));

      request.headers["referer"] = SourceConnection.makeUrlFromDomainName(
        VideoSources.videoSourcesDomainNames(VideoSourceParsers.yourUpload)[0],
      );
    } catch (e, s) {
      throw VideoUrlParserException(
        errorMsg: e,
        stackTrace: s,
        kind: VideoUrlParserExceptionKind.requestMakeException,
      );
    }
    late final Response response;
    try {
      response = await Response.fromStream(await client.send(request));
    } catch (e, s) {
      throw VideoUrlParserException(
        errorMsg: e,
        stackTrace: s,
        kind: VideoUrlParserExceptionKind.responseReceiveException,
      );
    }

    try {
      late final Element? elementSelectFirst;
      try {
        elementSelectFirst = HtmlParser(response.body)
            .parse()
            .querySelectorAll(scriptHtmlCSSClass)
            .cast<Element?>()
            .firstWhere(
              (element) => element?.text.contains("jwplayerOptions") == true,
              orElse: () => null,
            );
      } catch (e) {
        logger.w("elementSelectFirst is empty: $e");
        elementSelectFirst = null;
      }

      if (elementSelectFirst == null) {
        return "";
      }

      final String elementSelectFirstData = elementSelectFirst.text;

      if (elementSelectFirstData.isEmpty) {
        return "";
      } else {
        int startOfUrlIndex = elementSelectFirstData.indexOf(startMark);
        int endOfUrlIndex = elementSelectFirstData.indexOf(endMark);

        if (startOfUrlIndex == -1 || endOfUrlIndex == -1) {
          logger.w("No pattern didn't match startMark or endMark, returning null");
          return "";
        }

        return elementSelectFirstData.substring(startOfUrlIndex + startMark.length, endOfUrlIndex);
      }
    } catch (e, s) {
      throw VideoUrlParserException(
        errorMsg: e,
        stackTrace: s,
        kind: VideoUrlParserExceptionKind.responseParseException,
      );
    }
  }
}
