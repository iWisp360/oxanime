import "dart:convert";
import "dart:io";

import "package:json_annotation/json_annotation.dart";
import "package:oxanime/utilities/files.dart";
import "package:oxanime/utilities/logs.dart";

part "series.g.dart";

const seriesFileName = "series.json";

late final List<Serie> series;

@JsonSerializable()
class Chapter {
  final int index;
  final String uri;
  Chapter({required this.index, required this.uri});

  factory Chapter.fromJson(Map<String, dynamic> map) => _$ChapterFromJson(map);

  Map<String, dynamic> toMap() => _$ChapterToJson(this);
}

@JsonSerializable()
class Serie {
  final String name;
  String? description;
  final List<Chapter> chapters;
  final String sourceUUID;

  Serie({required this.name, this.description, required this.chapters, required this.sourceUUID});

  factory Serie.fromMap(Map<String, dynamic> map) => _$SerieFromJson(map);

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
      final serializedSerie = toMap();
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
      return await getDataDirectoryWithJoined("series.json");
    } catch (e, s) {
      logger.e("Error while getting series path: $e\n$s");
      rethrow;
    }
  }
}
