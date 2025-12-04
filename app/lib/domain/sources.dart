import "dart:convert";
import "dart:io";

import "package:json_annotation/json_annotation.dart";
import "package:oxanime/core/validations.dart";
import "package:oxanime/core/files.dart";
import "package:oxanime/data/html_parser.dart";
import "package:oxanime/core/logs.dart";
import "package:oxanime/data/networking.dart";
import "package:oxanime/core/constants.dart";
import "package:oxanime/core/enums.dart";

part "sources.g.dart";

late List<Source> sources;
late bool sourcesInitSuccess;

/// Sources may present chapter video links inside javascript
/// arrays, which are unreachable by using a css class,
/// so, parsing the array is necessary. Luckily, arrays
/// in Javascript has the same structure as a JSON object.

class SearchResult {
  final String name;
  final String mainUrl;
  String? imageUrl;
  final String sourceUUID;
  SearchResult({
    required this.sourceUUID,
    this.imageUrl,
    required this.mainUrl,
    required this.name,
  });
}

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
  List<String>? searchSerieUrlExcludes;
  String? searchSerieImageCSSClass;
  List<String>? searchSerieImageExcludes;
  // serie chapters fields
  final String searchSerieChaptersIdentifiersCSSClass;
  final String searchSerieChaptersUrlsCSSClass;
  // chapters videos fields
  @JsonKey(defaultValue: [])
  final List<String> videoSourcesPriority;
  @JsonKey(defaultValue: ChaptersVideosUrlLocation.empty)
  final ChaptersVideosUrlLocation chaptersVideosUrlLocation;
  @JsonKey(defaultValue: ChaptersVideosUrlParseModes.empty)
  final ChaptersVideosUrlParseModes chaptersVideosUrlParseMode;
  @JsonKey(defaultValue: PlaceHolders.emptyString)
  final String chaptersVideosJsonListStartPattern;
  @JsonKey(defaultValue: PlaceHolders.emptyString)
  final String chaptersVideosJsonListEndPattern;
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
    required this.chaptersVideosUrlLocation,
    required this.chaptersVideosUrlParseMode,
    required this.chaptersVideosJsonListStartPattern,
    required this.chaptersVideosJsonListEndPattern,
    required this.videoSourcesPriority,
    this.searchSerieNameExcludes,
    required this.searchSerieNameCSSClass,
    required this.searchSerieUrlCSSClass,
    this.searchSerieImageCSSClass,
    required this.searchSerieChaptersIdentifiersCSSClass,
    required this.searchSerieChaptersUrlsCSSClass,
    required this.searchSerieDescriptionCSSClass,
    this.searchSerieDescriptionExcludes,
    this.searchSerieImageExcludes,
    this.searchSerieUrlExcludes,
    this.name = "OxAnime Source",
    required this.mainUrl,
    required this.searchUrl,
    this.searchSerieUrlResultsAbsolute,
    this.enabled = false,
    required this.uuid,
  });

  factory Source.fromMap(Map<String, dynamic> json) => _$SourceFromJson(json);

  Future pushSource() async {
    final sourcesPath = await _getSourcesPath();
    final serializedSource = _toMap();

    try {
      final fileContents = await File(await _getSourcesPath()).bufferedRead();

      List<Map<String, dynamic>> serializedSources = jsonDecode(fileContents);
      final conflict = await _getDuplicate(sources);
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

  Future<List<SearchResult>> query(String query) async {
    logger.i("Performing search with query $query");
    List<SearchResult> results = [];
    final String responseBody;
    try {
      responseBody = await SourceConnection.getBodyFrom(searchUrl + query);
    } catch (e, s) {
      logger.e("Error while performing request with query $query: $e\n$s");
      rethrow;
    }
    final sourceHtmlParser = await SourceHtmlParser.create(html: responseBody);
    final List<String> names = await sourceHtmlParser.getMultipleCSSClassText(
      searchSerieNameCSSClass,
      searchSerieNameExcludes ?? [],
    );

    final List<String?> seriesUrls =
        (await sourceHtmlParser.getMultipleCSSClassAttrValue(
          searchSerieUrlCSSClass,
          searchSerieUrlExcludes ?? [],
          urlHtmlAttribute,
        )).map((e) {
          if (searchSerieUrlResultsAbsolute == false) {
            return SourceConnection.makeUrlFromRelative(mainUrl, e);
          }
        }).toList();

    late final List<String?> imageUrls;

    if (searchSerieImageCSSClass == null) {
      logger.w("Source doesn't have a CSS class for images");
    } else {
      imageUrls =
          (await sourceHtmlParser.getMultipleCSSClassAttrValue(
            searchSerieImageCSSClass ?? PlaceHolders.emptyString,
            searchSerieImageExcludes ?? [],
            imgHtmlAttribute,
          )).map((e) {
            if (searchSerieUrlResultsAbsolute == false) {
              return SourceConnection.makeUrlFromRelative(mainUrl, e);
            }
          }).toList();
    }

    for (int i = 0; i < names.length; i++) {
      results.add(
        SearchResult(
          sourceUUID: uuid,
          name: names[i],
          mainUrl: seriesUrls[i] ?? PlaceHolders.emptyString,
          imageUrl: imageUrls[i] ?? PlaceHolders.emptyString,
        ),
      );
    }
    logger.i("Got ${results.length} results");
    return results;
  }

  Future<Source?> _getDuplicate(List<Source> sources) async {
    for (var source in sources) {
      if (source.name.toLowerCase() == name.toLowerCase() ||
          source.uuid == uuid ||
          mainUrl.contains(source.name.toLowerCase())) {
        return source;
      }
    }
    return null;
  }

  bool isUsable() {
    bool result = (enabled == true) && Validate.source(this);
    logger.i((result == false) ? "$name is not usable" : "$name is usable");
    return result;
  }

  Map<String, dynamic> _toMap() => _$SourceToJson(this);

  static Future<List<Source>> getSources() async {
    logger.i("Initializing sources");
    try {
      List<Source> sources = [];
      final String fileContents = await File(await _getSourcesPath()).bufferedRead();
      var serializedContents = jsonDecode(fileContents);
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
    return await getDataDirectoryWithJoined(FileNames.sourcesJson);
  }
}
