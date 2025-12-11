import 'package:animebox/core/enums.dart';
import 'package:animebox/data/html_parser.dart';
import 'package:animebox/data/video_url_parsers/video_url_parsers.dart';
import "package:animebox/core/exceptions.dart";
import 'package:collection/collection.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart';

class Mp4upload with VideoSourceParameters {
  static Future<AnimeBoxVideo> getVideoFromUrl(final String url) async {
    late final Document doc;
    final client = Client();
    final request = Request("GET", Uri.parse(url))..headers["referer"] = "https://mp4upload.com/";

    try {
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

      if (videoUrl == null || videoUrl.group(1) == null) {
        throw VideoUrlParserException(kind: VideoUrlParserExceptionKind.videoNotFoundException);
      }

      return AnimeBoxVideo(
        url: videoUrl.group(1)!,
        headers: request.headers,
        assignedParser: VideoUrlParsers.mp4upload,
      );
    } catch (e) {
      throw VideoUrlParserException(kind: VideoUrlParserExceptionKind.videoNotFoundException);
    }
  }
}
