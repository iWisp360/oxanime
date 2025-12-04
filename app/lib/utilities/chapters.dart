import "dart:convert";

import "package:html/dom.dart";
import "package:html/parser.dart";
import "package:http/http.dart";
import "package:json_annotation/json_annotation.dart";
import "package:oxanime/utilities/html_parser.dart";
import "package:oxanime/utilities/logs.dart";
import "package:oxanime/utilities/sources.dart";

part "chapters.g.dart";

@JsonSerializable()
class Chapter {
  static late final Source _source;
  final String identifier;
  final String url;
  final String sourceUUID;
  Chapter({required this.identifier, required this.url, required this.sourceUUID});

  factory Chapter.fromJson(Map<String, dynamic> map) => _$ChapterFromJson(map);

  Map<String, dynamic> toMap() => _$ChapterToJson(this);

  Future<List<String>> getChapterVideoUrls() async {
    List<String> videoUrls = [];

    late final String responseBody;

    try {
      final client = Client();
      final response = await client.get(Uri.parse(url));
      responseBody = response.body;
    } catch (e) {
      logger.e("Connection error while getting chapter video urls: $e");
      rethrow;
    }

    switch (_source.videosUrlParseMode) {
      case ChaptersVideosUrlParseModes.jsonList:
        final element = HtmlParser(responseBody)
            .parse()
            .querySelectorAll(scriptHtmlCSSClass)
            .cast<Element?>()
            .firstWhere(
              (element) =>
                  element?.text.contains(_source.chaptersVideosJsonListStartPattern) == true,
              orElse: () => null,
            );

        if (element == null) {
          return videoUrls;
        }

        final String elementSelectFirstData = element.text;

        if (elementSelectFirstData.isEmpty) {
          return videoUrls;
        } else {
          int startOfUrlIndex = elementSelectFirstData.indexOf(
            _source.chaptersVideosJsonListStartPattern,
          );
          int endOfUrlIndex = elementSelectFirstData.indexOf(
            _source.chaptersVideosJsonListEndPattern,
          );

          if (startOfUrlIndex == -1 || endOfUrlIndex == -1) {
            logger.w("No pattern didn't match startMark or endMark, returning null");
            return videoUrls;
          }

          // WIP: Chapters Url parse from serialized json
          var jsonObject = jsonDecode(
            elementSelectFirstData.substring(
              startOfUrlIndex + _source.chaptersVideosJsonListStartPattern.length,
              endOfUrlIndex,
            ),
          );
        }

        break;
    }

    return videoUrls;
  }

  Future<void> assignSource() async {
    for (var s in sources) {
      if (s.uuid == sourceUUID) {
        _source = s;
      } else {
        throw Exception("Source not found for this chapter");
      }
    }
  }
}
