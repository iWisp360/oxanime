import "package:animebox/core/enums.dart";
import "package:animebox/core/exceptions.dart";
import "package:animebox/core/logs.dart";
import "package:animebox/data/html_parser.dart";
import "package:animebox/data/networking.dart";
import "package:animebox/data/video_url_parsers/video_url_parsers.dart";
import "package:html/dom.dart";
import "package:html/parser.dart";
import "package:http/http.dart";

class YourUpload with VideoSourceParameters {
  static Future<String> getVideoFromUrl(final String url) async {
    const startMark = "file: '";
    const endMark = "',";
    late final Client client;
    late final Request request;
    try {
      client = Client();
      request = Request("GET", Uri.parse(url))
        ..headers["referer"] = SourceConnection.makeUrlFromDomainName(
          VideoUrlParser.videoSourcesDomainNames(VideoUrlParsers.yourUpload)[0],
        );
    } catch (e, s) {
      throw VideoUrlParserException(
        errorMsg: e,
        stackTrace: s,
        kind: VideoUrlParserExceptionKind.requestMakeException,
      );
    }

    client.close();

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
