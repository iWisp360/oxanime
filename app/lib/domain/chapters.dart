import "dart:convert";

import "package:html/dom.dart";
import "package:html/parser.dart";
import "package:http/http.dart";
import "package:json_annotation/json_annotation.dart";
import "package:oxanime/core/constants.dart";
import "package:oxanime/core/enums.dart";
import "package:oxanime/data/html_parser.dart";
import "package:oxanime/core/logs.dart";
import "package:oxanime/domain/sources.dart";
import "package:collection/collection.dart";

part "chapters.g.dart";

@JsonSerializable()
class Chapter {
  final String identifier;
  final String url;
  final String sourceUUID;
  @JsonKey(includeFromJson: false)
  final Source _source;

  Chapter({required this.identifier, required this.url, required this.sourceUUID, Source? source})
    : _source = source ?? PlaceHolders.source;

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
    print(responseBody);
    switch (_source.chaptersVideosUrlParseMode) {
      case ChaptersVideosUrlParseModes.jsonList:
        final Element? element = HtmlParser(responseBody)
            .parse()
            .querySelectorAll(scriptHtmlCSSClass)
            .firstWhereOrNull(
              (element) => element.text.contains(_source.chaptersVideosJsonListStartPattern),
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
            startOfUrlIndex,
          );

          if (startOfUrlIndex == -1 || endOfUrlIndex == -1) {
            logger.w("No pattern didn't match startMark or endMark, returning null");
            return videoUrls;
          }

          var jsonList = jsonDecode(
            elementSelectFirstData.substring(
              startOfUrlIndex + _source.chaptersVideosJsonListStartPattern.length,
              endOfUrlIndex,
            ),
          );
          for (var object in jsonList) {
            final videoUrl = object[_source.chaptersVideosJsonListKey];
            if (videoUrl == null) continue;
            videoUrls.add(videoUrl);
          }
        }

        break;
      case ChaptersVideosUrlParseModes.empty:
        return videoUrls;
    }

    return videoUrls;
  }
}
