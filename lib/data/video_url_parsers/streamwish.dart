import "package:animebox/core/exceptions.dart";

import "package:animebox/data/html_parser.dart";

import "package:animebox/data/video_url_parsers/video_url_parsers.dart";
import "package:collection/collection.dart";

import "package:http/http.dart";
import "package:animebox/core/constants.dart";
import "package:js_unpack/js_unpack.dart";

class StreamWish with VideoSourceParameters {
  static final m3u8Regex = RegExp("https[^\"]*m3u8[^\"]*", caseSensitive: false);
  static Future<String> getVideoFromUrl(final String url) async {
    final modifiedUrl = url.replaceFirst("streamwish.to", "habetar.com");

    final client = Client();
    final request = Request("GET", Uri.parse(modifiedUrl));

    request.headers["user-agent"] = HttpValues.userAgent;
    request.headers["referer"] = "https://streamwish.to/";

    final elementSelectFirst =
        (await SourceHtmlParser.create(
              html: (await Response.fromStream(await client.send(request))).body,
            )).serializedHtml
            .querySelectorAll(scriptHtmlCSSClass)
            .firstWhereOrNull((element) => element.text.contains("eval(function(p,a,c"));

    client.close();

    if (elementSelectFirst == null) {
      throw VideoUrlParserException(kind: VideoUrlParserExceptionKind.videoNotFoundException);
    }

    final unpackedJs = JsUnpack(elementSelectFirst.text).unpack();

    // this variable's name looks cool
    final m3u8UrlGroupZero = m3u8Regex.firstMatch(unpackedJs)?.group(0);

    if (m3u8UrlGroupZero == null) {
      throw VideoUrlParserException(kind: VideoUrlParserExceptionKind.videoNotFoundException);
    } else {
      return m3u8UrlGroupZero;
    }
  }
}
