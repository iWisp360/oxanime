import 'package:animebox/data/html_parser.dart';
import 'package:animebox/data/video_url_parsers/video_url_parsers.dart';
import "package:animebox/core/exceptions.dart";
import 'package:collection/collection.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart';

class Mp4upload with VideoSourceParameters {
  static Future<String?> getVideoFromUrl(final String url) async {
    late final Document doc;
    final client = Client();
    try {
      final request = Request("GET", Uri.parse(url))..headers["referer"] = "https://mp4upload.com/";

      doc = (await SourceHtmlParser.create(
        html: (await Response.fromStream(await client.send(request))).body,
      )).serializedHtml;
    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }

    try {
      final script = doc
          .querySelectorAll(scriptHtmlCSSClass)
          .firstWhereOrNull((element) => element.text.contains("player.src"))!
          .text;

      final videoUrl = RegExp(r'src:\s*"([^"]+)"').firstMatch(script);

      return videoUrl?.group(1);
    } catch (e) {
      throw VideoUrlParserException(kind: VideoUrlParserExceptionKind.videoNotFoundException);
    }
  }
}
