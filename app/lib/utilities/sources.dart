import "dart:convert";
import "dart:io";

import "package:json_annotation/json_annotation.dart";
import "package:oxanime/utilities/files.dart";
import "package:oxanime/utilities/http.dart";
import "package:oxanime/utilities/logs.dart";
import "package:uuid/uuid.dart";
import "package:oxanime/utilities/series.dart";

part "sources.g.dart";

const sourcesFileName = "sources.json";

late List<Source> sources;

@JsonSerializable()
class Source {
  // serie name fields
  final String searchSerieNameCSSClass;
  List<String>? searchSerieNameExcludes;
  // serie description fields
  final String searchSerieDescriptionCSSClass;
  List<String>? searchSerieDescriptionExcludes;
  // serie searching fields
  final String searchSerieUrlCSSClass;
  final String searchSerieImageCSSClass;
  // serie chapters fields
  final String searchSerieChaptersCSSClass;
  // source configuration fields
  final String name;
  final String mainUrl;
  final String searchUrl;
  @JsonKey(defaultValue: false)
  final bool enabled;
  @JsonKey(disallowNullValue: true)
  final String uuid;
  @JsonKey(defaultValue: false)
  bool? searchSerieUrlResultsAbsolute;

  Source({
    this.searchSerieNameExcludes,
    required this.searchSerieNameCSSClass,
    required this.searchSerieUrlCSSClass,
    required this.searchSerieImageCSSClass,
    required this.searchSerieChaptersCSSClass,
    required this.searchSerieDescriptionCSSClass,
    this.searchSerieDescriptionExcludes,
    this.name = "OxAnime Source",
    required this.mainUrl,
    required this.searchUrl,
    this.searchSerieUrlResultsAbsolute,
    this.enabled = false,
    required this.uuid,
  });

  // WIP: search series

  factory Source.fromMap(Map<String, dynamic> json) => _$SourceFromJson(json);

  Future<Source?> getDuplicate(List<Source> sources) async {
    for (var source in sources) {
      if (source.name.toLowerCase() == name.toLowerCase() ||
          source.uuid == uuid ||
          mainUrl.contains(source.name.toLowerCase())) {
        return source;
      }
    }
    return null;
  }

  Future<String?> getSerieDescription(final String responseBody) async {
    return await (await SourceHtmlParser.create(
      html: responseBody,
    )).getSerieCSSClassText(searchSerieDescriptionCSSClass, searchSerieDescriptionExcludes ?? []);
  }

  Future<String?> getSerieName(final String responseBody) async {
    return await (await SourceHtmlParser.create(
      html: responseBody,
    )).getSerieCSSClassText(searchSerieNameCSSClass, searchSerieNameExcludes ?? []);
  }

  bool isUsable() {
    bool result = (enabled == true) && (Uuid.isValidUUID(fromString: uuid));
    logger.i((result == false) ? "$name is not usable" : "$name is usable");
    return result;
  }

  Future pushSource() async {
    final sourcesPath = await _getSourcesPath();
    final serializedSource = toMap();

    try {
      final fileContents = await File(await _getSourcesPath()).bufferedRead();

      List<Map<String, dynamic>> serializedSources = jsonDecode(fileContents);
      final conflict = await getDuplicate(sources);
      if (conflict != null) {
        throw Exception(
          "Not adding $name with UUID $name as it is a duplicate of ${conflict.name} with UUID ${conflict.uuid}",
        );
      }

      sources.add(this);

      serializedSources.add(serializedSource);

      final deserializedSources = jsonEncode(serializedSources);
      await File(sourcesPath).bufferedWrite(deserializedSources);
    } catch (e, s) {
      logger.e("Error while pushing source $name to $sourcesPath\n$s");
      rethrow;
    }
  }

  Map<String, dynamic> toMap() => _$SourceToJson(this);

  static Future<List<Source>> getSources() async {
    try {
      List<Source> sources = [];
      final String fileContents = await File(await _getSourcesPath()).bufferedRead();
      List<Map<String, dynamic>> serializedContents = jsonDecode(fileContents);
      for (var source in serializedContents) {
        sources.add(Source.fromMap(source));
      }
      return sources.where((source) => source.isUsable()).toList();
    } catch (e, s) {
      logger.e("Error while reading sources: $e\n$s");
      rethrow;
    }
  }

  /// This function should only be used at the startup of the program to serialize the sources.json file.
  /// Further access or modification is expected through global variable sources, which can be accessed by importing this module.
  static Future<String> _getSourcesPath() async {
    return await getDataDirectoryWithJoined("sources.json");
  }
}
