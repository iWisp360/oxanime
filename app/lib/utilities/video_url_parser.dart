import "package:html/dom.dart";
import "package:html/parser.dart";
import "package:http/http.dart";
import "package:oxanime/utilities/exceptions.dart";
import "package:oxanime/utilities/html_parser.dart";
import "package:oxanime/utilities/logs.dart";

mixin VideoSourceParameters {
  bool get needsAWebView;
  Future<String?> getVideoFromUrl(final String url);
}

// In this context, a parser is the utility that brings you the content you need to watch a serie chapter,
// either by natively streaming it or embedding a webview player if getting a URL is not possible.
// A parser gets the following contents if available:
// - URL or a List of URLs of the static content of the video
// - Video Quality Options -> not implemented
// - Video Duration -> MediaKit does this, so these things actually don't
enum VideoSourceParsers {
  yourUpload, // sourced from aniyomi
}

class VideoSources {
  static String getCompleteUrl(final String domainName) {
    return "https://$domainName/";
  }

  static List<String> videoSourcesDomainNames(VideoSourceParsers videoSource) {
    return switch (videoSource) {
      VideoSourceParsers.yourUpload => ["yourupload.com"],
    };
  }
}

class YourUpload with VideoSourceParameters {
  @override
  bool get needsAWebView => false;

  @override
  Future<String?> getVideoFromUrl(final String url) async {
    const startMark = "file: '";
    const endMark = "',";
    late final Client client;
    late final Request request;
    try {
      client = Client();
      request = Request("GET", Uri.parse(url));

      request.headers["referer"] = VideoSources.getCompleteUrl(
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
        return null;
      }

      final String elementSelectFirstData = elementSelectFirst.text;

      if (elementSelectFirstData.isEmpty) {
        return null;
      } else {
        int startOfUrlIndex = elementSelectFirstData.indexOf(startMark);
        int endOfUrlIndex = elementSelectFirstData.indexOf(endMark);

        if (startOfUrlIndex == -1 || endOfUrlIndex == -1) {
          logger.w("No pattern didn't match startMark or endMark, returning null");
          return null;
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
