import "dart:convert";
import "dart:io";

import "package:collection/collection.dart";
import "package:html/dom.dart";
import "package:json_annotation/json_annotation.dart";
import "package:oxanime/core/constants.dart";
import "package:oxanime/domain/chapters.dart";
import "package:oxanime/core/files.dart";
import "package:oxanime/data/html_parser.dart";
import "package:oxanime/core/logs.dart";
import "package:oxanime/data/networking.dart";
import "package:oxanime/domain/sources.dart";

part "series.g.dart";

const seriesFileName = FileNames.seriesJson;

late final List<Serie> series;

@JsonSerializable()
class Serie {
  final String name;
  final String url;
  final String imageUrl;
  String? description;
  List<Chapter>? chapters;
  final String sourceUUID;
  static late final Source _source;

  Serie({
    required this.name,
    required this.url,
    required this.imageUrl,
    this.description,
    this.chapters,
    required this.sourceUUID,
  });

  factory Serie.fromMap(Map<String, dynamic> map) => _$SerieFromJson(map);

  Future<Serie> createSerie(SearchResult result) async {
    final String? description = await _getSerieDescription(
      (await SourceConnection.getBodyFrom(url)),
    );
    var serie = Serie(
      name: result.name,
      url: result.mainUrl,
      sourceUUID: result.sourceUUID,
      description: description ?? "No Description", // should be translated
      imageUrl: result.imageUrl ?? PlaceHolders.emptyString,
    );
    serie.assignSource();
    return serie;
  }

  Future<String?> _getSerieDescription(final String responseBody) async {
    if (_source.searchSerieDescriptionCSSClass == null ||
        _source.searchSerieDescriptionCSSClass == PlaceHolders.emptyString) {
      logger.w("searchSerieDescriptionCSSClass is null or empty. Returning fallback description");
      return "No Description";
    }

    late final String? description;
    try {
      description =
          await (await SourceHtmlParser.create(
            html: await SourceConnection.getBodyFrom(url),
          )).getSerieCSSClassText(
            _source.searchSerieDescriptionCSSClass!,
            _source.searchSerieDescriptionExcludes ?? [],
          );
    } catch (e) {
      logger.e("Couldn't get description of serie $name: $e");
      return null;
    }
    return description;
  }

  Future<void> assignSource() async {
    for (var s in sources) {
      if (s.uuid == sourceUUID) {
        _source = s;
      } else {
        throw Exception("Source not found for serie $name");
      }
    }
  }

  Future<void> getChaptersRemote() async {
    chapters ??= [];
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
        .querySelectorAll(_source.searchSerieChaptersIdentifiersCSSClass)
        .map((e) => e.text)
        .toList();

    var chapterUrls = sourceRequestDocument
        .querySelectorAll(_source.searchSerieChaptersUrlsCSSClass)
        .map((e) => e.attributes[urlHtmlAttribute])
        .map((e) {
          if (_source.searchSerieUrlResultsAbsolute == false) {
            if (e == null) return PlaceHolders.emptyString;

            return SourceConnection.makeUrlFromRelative(_source.mainUrl, e);
          }
        })
        .toList();

    for (int i = 0; i < chapterIdentifiers.length; i++) {
      chapters?.add(
        Chapter(
          sourceUUID: sourceUUID,
          identifier: chapterIdentifiers.elementAt(i),
          source:
              sources.singleWhereOrNull((element) => element.uuid == sourceUUID) ??
              PlaceHolders.source,
          url: chapterUrls.elementAtOrNull(i) ?? PlaceHolders.emptyString,
        ),
      );
    }
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

  static Future<String> _getSeriesPath() async {
    try {
      return await getDataDirectoryWithJoined(FileNames.seriesJson);
    } catch (e, s) {
      logger.e("Error while getting series path: $e\n$s");
      rethrow;
    }
  }
}
