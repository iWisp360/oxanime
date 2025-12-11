import "package:animebox/core/exceptions.dart";

import "package:animebox/data/html_parser.dart";

import "package:animebox/data/video_url_parsers/video_url_parsers.dart";
import "package:collection/collection.dart";

import "package:http/http.dart";

class StreamTape with VideoSourceParameters {
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
    client.close();

    final elementSelectFirst = (await SourceHtmlParser.create(html: responseBody)).serializedHtml
        .querySelectorAll(scriptHtmlCSSClass)
        .firstWhereOrNull(
          (element) => element.text.contains("document.getElementById('robotlink')"),
        );

    final firstDelimiter = "document.getElementById('robotlink').innerHTML = '";
    final secondDelimiter = "+ ('xcd";

    if (elementSelectFirst == null || !responseBody.contains(firstDelimiter)) {
      throw VideoUrlParserException(kind: VideoUrlParserExceptionKind.videoNotFoundException);
    }

    final strSubstringAfter = elementSelectFirst.text.substring(
      elementSelectFirst.text.indexOf(firstDelimiter) + firstDelimiter.length,
    );

    final firstQuoteIndex = strSubstringAfter.indexOf("'");
    final secondDelimiterIndex = strSubstringAfter.indexOf(secondDelimiter);

    if (firstQuoteIndex == -1 || secondDelimiterIndex == -1) {
      throw VideoUrlParserException(stackTrace: StackTrace.current);
    }

    final afterSecondDelimiter = strSubstringAfter.substring(
      secondDelimiterIndex + secondDelimiter.length,
    );

    final secondQuoteIndex = afterSecondDelimiter.indexOf("'");

    if (secondQuoteIndex == -1) {
      throw VideoUrlParserException(stackTrace: StackTrace.current);
    }

    final part1 = strSubstringAfter.substring(0, firstQuoteIndex);
    final part2 = afterSecondDelimiter.substring(0, secondQuoteIndex);

    return "https:$part1$part2";
  }
}
