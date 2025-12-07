import "dart:convert";

import "package:collection/collection.dart";
import "package:html/dom.dart";
import "package:html/parser.dart";
import "package:http/http.dart";
import "package:json_annotation/json_annotation.dart";
import "package:animebox/core/constants.dart";
import "package:animebox/core/enums.dart";
import "package:animebox/core/logs.dart";
import "package:animebox/data/html_parser.dart";
import "package:animebox/data/video_url_parsers.dart";
import "package:animebox/domain/sources.dart";

part "chapters.g.dart";

@JsonSerializable()
class Chapter {
  final String identifier;
  final String url;
  late final List<String> videoUrls;
  final String sourceUUID;
  @JsonKey(includeFromJson: false)
  final Source _source;

  Chapter({required this.identifier, required this.url, required this.sourceUUID, Source? source})
    : _source = source ?? Placeholders.source;

  factory Chapter.fromJson(Map<String, dynamic> map) => _$ChapterFromJson(map);

  Future<List<String>> getChapterVideoUrls() async {
    List<String> videoUrls = [];

    late final String responseBody;

    try {
      final client = Client();
      final response = await client.get(Uri.parse(url));
      client.close();
      responseBody = response.body;
    } catch (e) {
      logger.e("Connection error while getting chapter video urls: $e");
      rethrow;
    }

    switch (_source.videosFields.videosUrlParseMode) {
      case ChaptersVideosUrlParseModes.jsonList:
        final Element? element = HtmlParser(responseBody)
            .parse()
            .querySelectorAll(scriptHtmlCSSClass)
            .firstWhereOrNull(
              (element) => element.text.contains(_source.videosFields.jsonListStartPattern),
            );

        if (element == null) {
          return videoUrls;
        }

        final String elementSelectFirstData = element.text;

        if (elementSelectFirstData.isEmpty) {
          return videoUrls;
        } else {
          int startOfUrlIndex = elementSelectFirstData.indexOf(
            _source.videosFields.jsonListStartPattern,
          );
          int endOfUrlIndex = elementSelectFirstData.indexOf(
            _source.videosFields.jsonListEndPattern,
            startOfUrlIndex,
          );

          if (startOfUrlIndex == -1 || endOfUrlIndex == -1) {
            logger.w("No pattern didn't match startMark or endMark, returning null");
            return videoUrls;
          }

          var jsonList = jsonDecode(
            elementSelectFirstData.substring(
              startOfUrlIndex + _source.videosFields.jsonListStartPattern.length,
              endOfUrlIndex,
            ),
          );
          for (var object in jsonList) {
            final String? videoUrl = object[_source.videosFields.jsonListKeyForVideosUrl];
            if (videoUrl == null) continue;
            videoUrls.add(videoUrl);
          }
        }

        break;
      case ChaptersVideosUrlParseModes.empty:
        return videoUrls;
    }

    return VideoUrlParser.sortVideoUrls(videoUrls, _source.videosFields.videoSourcesPriority);
  }

  Map<String, dynamic> toMap() => _$ChapterToJson(this);
}
