import "dart:convert";
import "dart:io";

import "package:collection/collection.dart";
import "package:html/dom.dart";
import "package:json_annotation/json_annotation.dart";
import "package:animebox/core/constants.dart";
import "package:animebox/core/files.dart";
import "package:animebox/core/logs.dart";
import "package:animebox/data/html_parser.dart";
import "package:animebox/data/networking.dart";
import "package:animebox/domain/chapters.dart";
import "package:animebox/domain/sources.dart";

part "series.g.dart";

const seriesFileName = FileNames.seriesJson;

late final List<Serie> series;

@JsonSerializable()
class Serie {
  @JsonKey(includeFromJson: false)
  final Source source;
  final String name;
  final String url;
  final String imageUrl;
  String? description;
  late List<Chapter> chapters;
  final String sourceUUID;

  Serie({
    Source? inputSource,
    required this.name,
    required this.url,
    required this.imageUrl,
    this.description,
    this.chapters = const [],
    required this.sourceUUID,
  }) : source = inputSource ?? Placeholders.source;

  factory Serie.fromMap(Map<String, dynamic> map) => _$SerieFromJson(map);

  Future<List<Chapter>> getChaptersRemote() async {
    List<Chapter> chapters = [];
    late Document sourceRequestDocument;

    try {
      sourceRequestDocument = await SourceConnection.parseHtml(
        await SourceConnection.getBodyFrom(url),
      );
    } catch (e) {
      logger.e("Error while getting chapters from remote sources: $e");
      rethrow;
    }

    var chapterIdentifiers = sourceRequestDocument
        .querySelectorAll(source.chaptersFields.identifiersCSSClass)
        .map((e) => e.text)
        .toList();

    var chapterUrls = sourceRequestDocument
        .querySelectorAll(source.chaptersFields.urlsCSSClass)
        .map((e) => e.attributes[urlHtmlAttribute])
        .map((e) {
          if (source.configurationFields.resultsUrlAbsolute == false) {
            if (e == null) return Placeholders.emptyString;

            return SourceConnection.makeUrlFromRelative(source.configurationFields.mainUrl, e);
          }
        })
        .toList();

    for (int i = 0; i < chapterIdentifiers.length; i++) {
      var chapter = Chapter(
        sourceUUID: sourceUUID,
        identifier: chapterIdentifiers.elementAt(i),
        source:
            sources.singleWhereOrNull(
              (element) => element.configurationFields.uuid == sourceUUID,
            ) ??
            Placeholders.source,
        url: chapterUrls.elementAtOrNull(i) ?? Placeholders.emptyString,
      );

      chapters.add(chapter);
    }
    return chapters;
  }

  Future<List<Serie>> getSeries() async {
    try {
      List<Serie> series = [];
      final String serieFileContents = await File(await _getSeriesPath()).bufferedRead();
      List<Map<String, dynamic>> serializedContents = jsonDecode(serieFileContents);
      for (var serie in serializedContents) {
        series.add(Serie.fromMap(serie));
      }
      return series;
    } catch (e, s) {
      logger.e("Error while getting series: $e\n$s");
      rethrow;
    }
  }

  Future<void> pushToFile() async {
    final seriesPath = await _getSeriesPath();
    try {
      final fileContents = await File(await _getSeriesPath()).bufferedRead();
      final Map<String, dynamic> serializedSerie = toMap();
      List<Map<String, dynamic>> serializedSeries = jsonDecode(fileContents);

      // WIP: Merge Manager, it will be able to merge certain fields of an existing serie with
      // this one, to avoid duplication. EVEN CHAPTERS.

      series.add(this);

      serializedSeries.add(serializedSerie);

      final deserializedSources = jsonEncode(serializedSeries);
      await File(seriesPath).bufferedWrite(deserializedSources);
    } catch (e, s) {
      logger.e("Error while pushing serie: $e\n$s");
      rethrow;
    }
  }

  Map<String, dynamic> toMap() => _$SerieToJson(this);

  static Source assignSource(String sourceUUID) {
    late Source source;
    for (var s in sources) {
      if (s.configurationFields.uuid == sourceUUID) {
        source = s;
      } else {
        throw Exception("Source not found for serie with uuid: $sourceUUID");
      }
    }
    return source;
  }

  static Future<Serie> createSerie(SearchResult result) async {
    final String? description = await _getSerieDescription(
      (await SourceConnection.getBodyFrom(result.mainUrl)),
      result.mainUrl,
      assignSource(result.sourceUUID),
    );
    var serie = Serie(
      name: result.name,
      url: result.mainUrl,
      sourceUUID: result.sourceUUID,
      inputSource: assignSource(result.sourceUUID),
      description: description ?? "No Description", // should be translated
      imageUrl: result.imageUrl ?? Placeholders.emptyString,
    );
    return serie;
  }

  static Future<String?> _getSerieDescription(
    final String responseBody,
    final String url,
    Source source,
  ) async {
    if (source.serieFields.descriptionCSSClass == Placeholders.emptyString) {
      logger.w("searchSerieDescriptionCSSClass is empty. Returning fallback description");
      return "No Description";
    }

    late final String? description;
    try {
      description =
          await (await SourceHtmlParser.create(
            html: await SourceConnection.getBodyFrom(url),
          )).getSerieCSSClassText(
            source.serieFields.descriptionCSSClass,
            source.serieFields.descriptionExcludes,
          );
    } catch (e) {
      logger.e("Couldn't get description of serie: $e");
      return null;
    }
    return description;
  }

  static Future<String> _getSeriesPath() async {
    try {
      return await getDataDirectoryWithJoined(FileNames.seriesJson);
    } catch (e, s) {
      logger.e("Error while getting series path: $e\n$s");
      rethrow;
    }
  }
}
