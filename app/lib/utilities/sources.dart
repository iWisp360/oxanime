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
    this.searchSerieNameHasSplitPattern,
    this.searchSerieNameSplitPattern,
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

  factory Source.fromJson(Map<String, dynamic> json) => _$SourceFromJson(json);

  /// This function should only be used at the startup of the program to serialize the sources.json file. Further access or modification is expected through global variable sources, which can be accessed by importing this module.
  static Future<List<Source>> getSources() async {
    final sourcesPath = await SourceFileManager().getSourcesPath();

    try {
      List<Source> sources = [];
      final String fileContents = await SourceFileManager().readSourcesFile();
      final serializedContents = jsonDecode(fileContents);
      for (var source in serializedContents) {
        sources.add(Source.fromJson(source));
      }
      return sources.where((source) => source.isUsable()).toList();
    } catch (e) {
      logger.e("Error while reading sources: $e");
      rethrow;
    }
  }

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
    bool result = (enabled == true)
        ? (uuid.isNotEmpty)
              ? true
              : false
        : false;
    logger.i((result == false) ? "$name is not usable" : "$name is usable");
    return false;
  }

  /// push this Source to the sources.json file and the sources List
  Future push(List<Source> localSources) async {
    final sourcesPath = await SourceFileManager().getSourcesPath();
    final serializedSource = toJson();

    try {  
      final fileContents = await SourceFileManager().readSourcesFile();

      List<Map<String, dynamic>> serializedSources = jsonDecode(fileContents);
      final conflict = await getDuplicate(localSources);
      if (conflict != null) {
        throw Exception(
          "Not adding $name with UUID $name as it is a duplicate of ${conflict.name} with UUID ${conflict.uuid}",
        );
      }
      // add this source to the global sources List
      sources.add(this);

      serializedSources.add(serializedSource);
      
      final deserializedSources = jsonEncode(serializedSources);
      // WIP Use buffered writes. Implement function in SourceFileManager class
      await File(sourcesPath).writeAsString(deserializedSources);
    } catch (e, s) {
      logger.e("Error while pushing source $name to $sourcesPath\n$s");
      rethrow;
    }
  }

  Map<String, dynamic> toMap() => _$SourceToJson(this);
}

class SourceFileManager {
  Future<String> getSourcesPath() async {
    String sourcesPath = path.join(
/// This post explains the path where getApplicationSupportDirectory points to in Android:
///
/// https://stackoverflow.com/questions/73685676/difference-between-application-documents-directory-and-support-directory-in-path 
/// 
/// On linux, it should be located at ~/.local/share/page.codeberg.oxanime/
      await getApplicationSupportDirectory().then((value) => value.path),
      "sources.json",
    );
    logger.i("Sources are located at $sourcesPath");
    return sourcesPath;
  }

  // use buffered read to improve performance
  Future<String> readSourcesFile() async {
    try {
      final sourcesPath = await getSourcesPath();
      final sourcesFile = File(sourcesPath);
      final StringBuffer fileContents = StringBuffer();
      await for (var chunk in utf8.decoder.bind(sourcesFile.openRead())) {
        fileContents.write(chunk);
      }
      return fileContents.toString();
    } catch (e) {
      logger.e("Error while reading sources file: $e");
      rethrow;
    }
  }
}
