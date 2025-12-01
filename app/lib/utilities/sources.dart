import "dart:convert";
import "dart:io";

import "package:json_annotation/json_annotation.dart";
import "package:oxanime/utilities/http.dart";
import "package:oxanime/utilities/logs.dart";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";

part "sources.g.dart";

late List<Source> sources;

@JsonSerializable()
class Source {
  @JsonKey(defaultValue: false)
  bool? searchSerieUrlResultsAbsolute;
  @JsonKey(defaultValue: false)
  bool? searchSerieNameHasSplitPattern;
  String? searchSerieNameSplitPattern;
  List<String>? searchSerieNameExcludes;
  List<String>? searchSerieDescriptionExcludes;
  final String name;
  final String mainUrl;
  final String searchUrl;
  final String searchSerieNameCSSClass;
  final String searchSerieUrlCSSClass;
  final String searchSerieImageCSSClass;
  final String searchSerieChaptersCSSClass;
  final String searchSerieDescriptionCSSClass;
  @JsonKey(defaultValue: false)
  final bool enabled;
  @JsonKey(disallowNullValue: true)
  final String uuid;

  Source({
    this.name = "OxAnime Source",
    this.searchSerieNameExcludes,
    this.searchSerieUrlResultsAbsolute,
    this.searchSerieNameHasSplitPattern,
    this.searchSerieNameSplitPattern,
    required this.searchSerieNameCSSClass,
    required this.mainUrl,
    required this.searchUrl,
    required this.searchSerieUrlCSSClass,
    required this.searchSerieImageCSSClass,
    required this.searchSerieChaptersCSSClass,
    required this.searchSerieDescriptionCSSClass,
    this.searchSerieDescriptionExcludes,
    this.enabled = false,
    required this.uuid,
  });

  factory Source.fromJson(Map<String, dynamic> json) => _$SourceFromJson(json);
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

  Map<String, dynamic> toJson() => _$SourceToJson(this);
}

class SourceManager {
  Future<List<Source>> getSources() async {
    final sourcesPath = await getSourcesPath();

    try {
      List<Source> sources = [];
      final String fileContents = await File(sourcesPath).readAsString();
      final serializedContents = jsonDecode(fileContents);
      for (var source in serializedContents) {
        sources.add(Source.fromJson(source));
      }
      return sources.where((source) {
        var result = (source.enabled == true)
            ? (source.uuid.isNotEmpty)
                  ? true
                  : false
            : false;
        if (result == false) {
          logger.i(
            "Source \"${source.name}\" disabled because uuid is empty or enabled is set to false",
          );
        }
        return result;
      }).toList();
    } catch (e) {
      logger.e("Error while reading sources: $e");
      rethrow;
    }
  }

  Future<String> getSourcesPath() async {
    return path.join(
      await getApplicationSupportDirectory().then((value) => value.path),
      "sources.json",
    );
  }

  Future pushSource(Source source) async {
    try {
      final serializedSource = source.toJson();
      final fileContents = await readSourcesFile();
      List<Map<String, dynamic>> serializedSources = jsonDecode(fileContents);
      serializedSources.add(serializedSource);
      final deserializedSources = jsonEncode(serializedSources);
      await File(await getSourcesPath()).writeAsString(deserializedSources);
    } catch (e, s) {
      logger.e("Error while pushing source ${source.name} to ${await getSourcesPath()}\n$s");
      rethrow;
    }
  }

  Future<String> readSourcesFile() async {
    final sourcesPath = await getSourcesPath();
    final sourcesFile = File(sourcesPath);
    final StringBuffer fileContents = StringBuffer();
    await for (var chunk in utf8.decoder.bind(sourcesFile.openRead())) {
      fileContents.write(chunk);
    }
    return fileContents.toString();
  }
}
