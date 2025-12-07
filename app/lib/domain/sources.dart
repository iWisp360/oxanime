import "dart:convert";
import "dart:io";

import "package:collection/collection.dart";
import "package:json_annotation/json_annotation.dart";
import "package:animebox/core/constants.dart";
import "package:animebox/core/enums.dart";
import "package:animebox/core/files.dart";
import "package:animebox/core/logs.dart";
import "package:animebox/core/validations.dart";
import "package:animebox/data/html_parser.dart";
import "package:animebox/data/networking.dart";

part "sources.g.dart";

late List<Source> sources;
late bool sourcesInitSuccess;

class SearchResult {
  final String name;
  final String mainUrl;
  final String? imageUrl;
  final String sourceUUID;

  SearchResult({
    required this.sourceUUID,
    this.imageUrl,
    required this.mainUrl,
    required this.name,
  });
}

@JsonSerializable(explicitToJson: true)
class Source {
  @JsonKey(defaultValue: SourceSerieFields.new)
  final SourceSerieFields serieFields;

  @JsonKey(defaultValue: SourceSearchFields.new)
  final SourceSearchFields searchFields;

  @JsonKey(defaultValue: SourceVideosFields.new)
  final SourceVideosFields videosFields;

  @JsonKey(defaultValue: SourceChaptersFields.new)
  final SourceChaptersFields chaptersFields;

  @JsonKey(defaultValue: SourceConfigurationFields.new)
  final SourceConfigurationFields configurationFields;

  Source({
    required this.serieFields,
    required this.searchFields,
    required this.videosFields,
    required this.chaptersFields,
    required this.configurationFields,
  });

  factory Source.fromMap(Map<String, dynamic> json) => _$SourceFromJson(json);

  bool isUsable() {
    logger.i("Validating source '${configurationFields.name}'");
    var validation = ValidateSource.validate(this);
    logger.i(
      (validation.result == false)
          ? "${configurationFields.name} is not usable"
          : "${configurationFields.name} is usable",
    );
    return validation.result;
  }

  Future<void> pop() async {
    final sourceCache = sources.singleWhereOrNull(
      (source) => source.configurationFields.uuid == configurationFields.uuid,
    );

    if (sourceCache == null) {
      logger.e("Couldn't cache the source to remove: .singleWhereOrNull() returned a null value");
      return;
    }

    logger.i("Removing source with name ${configurationFields.name}");
    final File file = File(await _getSourcesPath());
    sources.removeWhere((source) => source.configurationFields.uuid == configurationFields.uuid);
    final serializedSources = jsonEncode(sources);

    try {
      await file.bufferedWrite(serializedSources);
    } catch (e, s) {
      logger.e("Couldn't remove sources from ${FileNames.sourcesJson}: $e\n$s");
      sources.add(sourceCache);
      rethrow;
    }
  }

  Future push() async {
    final sourcesPath = await _getSourcesPath();
    final deserializedSource = _toMap();

    try {
      final fileContents = await File(await _getSourcesPath()).bufferedRead();

      List<Map<String, dynamic>> newSources = jsonDecode(fileContents);
      final conflict = await _getDuplicate(sources);
      if (conflict != null) {
        throw Exception(
          "Not adding ${configurationFields.name} with UUID ${configurationFields.name}"
          "as it is a duplicate of ${conflict.configurationFields.name}"
          "with UUID ${conflict.configurationFields.uuid}",
        );
      }

      sources.add(this);

      newSources.add(deserializedSource);

      final serializedSources = jsonEncode(newSources);
      await File(sourcesPath).bufferedWrite(serializedSources);
    } catch (e, s) {
      logger.e("Error while pushing source ${configurationFields.name} to $sourcesPath\n$s");
      rethrow;
    }
  }

  Future<List<SearchResult>> query(String query) async {
    logger.i("Performing search with query $query");
    List<SearchResult> results = [];
    final String responseBody;
    try {
      responseBody = await SourceConnection.getBodyFrom(configurationFields.searchUrl + query);
    } catch (e, s) {
      logger.e("Error while performing request with query $query: $e\n$s");
      rethrow;
    }
    final sourceHtmlParser = await SourceHtmlParser.create(html: responseBody);
    final List<String> names = await sourceHtmlParser.getMultipleCSSClassText(
      serieFields.nameCSSClass,
      serieFields.nameExcludes,
    );

    final List<String?> seriesUrls =
        (await sourceHtmlParser.getMultipleCSSClassAttrValue(
          searchFields.serieUrlCSSClass,
          searchFields.serieUrlExcludes,
          urlHtmlAttribute,
        )).map((e) {
          if (configurationFields.resultsUrlAbsolute == false) {
            return SourceConnection.makeUrlFromRelative(configurationFields.mainUrl, e);
          }
        }).toList();

    late final List<String?> imageUrls;

    if (searchFields.serieImageCSSClass.isEmpty) {
      logger.w("Source doesn't have a CSS class for images");
    } else {
      imageUrls =
          (await sourceHtmlParser.getMultipleCSSClassAttrValue(
            searchFields.serieImageCSSClass,
            searchFields.serieImageExcludes,
            imgHtmlAttribute,
          )).map((e) {
            if (configurationFields.resultsUrlAbsolute == false) {
              return SourceConnection.makeUrlFromRelative(configurationFields.mainUrl, e);
            }
          }).toList();
    }

    for (int i = 0; i < names.length; i++) {
      results.add(
        SearchResult(
          sourceUUID: configurationFields.uuid,
          name: names[i],
          mainUrl: seriesUrls[i] ?? Placeholders.emptyString,
          imageUrl: imageUrls[i] ?? Placeholders.emptyString,
        ),
      );
    }
    logger.i("Got ${results.length} results");
    return results;
  }

  Future<Source?> _getDuplicate(List<Source> sources) async {
    for (var source in sources) {
      if (source.configurationFields.name.toLowerCase() == configurationFields.name.toLowerCase() ||
          source.configurationFields.uuid == configurationFields.uuid ||
          configurationFields.mainUrl.contains(source.configurationFields.name.toLowerCase())) {
        return source;
      }
    }
    return null;
  }

  Map<String, dynamic> _toMap() => _$SourceToJson(this);

  static Future<List<Source>> getSources() async {
    logger.i("Initializing sources");
    try {
      List<Source> sources = [];
      final String fileContents = await File(await _getSourcesPath()).bufferedRead();
      if (fileContents.isEmpty) {
        await File(await _getSourcesPath()).bufferedWrite("[]");
      }

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

@JsonSerializable()
class SourceChaptersFields {
  final String identifiersCSSClass;
  final String urlsCSSClass;

  SourceChaptersFields({
    this.identifiersCSSClass = Placeholders.emptyString,
    this.urlsCSSClass = Placeholders.emptyString,
  });

  factory SourceChaptersFields.fromJson(Map<String, dynamic> json) =>
      _$SourceChaptersFieldsFromJson(json);

  Map<String, dynamic> toJson() => _$SourceChaptersFieldsToJson(this);
}

@JsonSerializable()
class SourceConfigurationFields {
  final String name;
  final String mainUrl;
  final String searchUrl;
  final bool enabled;
  final String uuid;
  bool resultsUrlAbsolute;

  SourceConfigurationFields({
    this.enabled = false,
    this.mainUrl = Placeholders.emptyString,
    this.searchUrl = Placeholders.emptyString,
    this.name = Placeholders.emptyString,
    this.uuid = Placeholders.uuid,
    this.resultsUrlAbsolute = false,
  });

  factory SourceConfigurationFields.fromJson(Map<String, dynamic> json) =>
      _$SourceConfigurationFieldsFromJson(json);

  Map<String, dynamic> toJson() => _$SourceConfigurationFieldsToJson(this);
}

@JsonSerializable()
class SourceSearchFields {
  final String serieUrlCSSClass;
  final List<String> serieUrlExcludes;
  final String serieImageCSSClass;
  final List<String> serieImageExcludes;

  SourceSearchFields({
    this.serieUrlCSSClass = Placeholders.emptyString,
    this.serieImageCSSClass = Placeholders.emptyString,
    this.serieImageExcludes = const [],
    this.serieUrlExcludes = const [],
  });

  factory SourceSearchFields.fromJson(Map<String, dynamic> json) =>
      _$SourceSearchFieldsFromJson(json);

  Map<String, dynamic> toJson() => _$SourceSearchFieldsToJson(this);
}

@JsonSerializable()
class SourceSerieFields {
  final String descriptionCSSClass;
  final String nameCSSClass;
  final List<String> descriptionExcludes;
  final List<String> nameExcludes;

  SourceSerieFields({
    this.descriptionCSSClass = Placeholders.emptyString,
    this.nameCSSClass = Placeholders.emptyString,
    this.descriptionExcludes = const [],
    this.nameExcludes = const [],
  });

  factory SourceSerieFields.fromJson(Map<String, dynamic> json) =>
      _$SourceSerieFieldsFromJson(json);

  Map<String, dynamic> toJson() => _$SourceSerieFieldsToJson(this);
}

// Sources may present chapter video links inside javascript
// arrays, which are unreachable by using a css class,
// so, parsing the array is necessary. Luckily, arrays
// in Javascript has the same structure as a JSON object.

@JsonSerializable()
class SourceVideosFields {
  final List<String> videoSourcesPriority;
  final ChaptersVideosUrlLocation videosUrlLocation;
  final ChaptersVideosUrlParseModes videosUrlParseMode;
  final String jsonListStartPattern;
  final String jsonListEndPattern;
  final String jsonListKeyForVideosUrl;

  SourceVideosFields({
    this.videoSourcesPriority = const [],
    this.videosUrlParseMode = ChaptersVideosUrlParseModes.empty,
    this.videosUrlLocation = ChaptersVideosUrlLocation.empty,
    this.jsonListKeyForVideosUrl = Placeholders.emptyString,
    this.jsonListStartPattern = Placeholders.emptyString,
    this.jsonListEndPattern = Placeholders.emptyString,
  });

  factory SourceVideosFields.fromJson(Map<String, dynamic> json) =>
      _$SourceVideosFieldsFromJson(json);

  Map<String, dynamic> toJson() => _$SourceVideosFieldsToJson(this);
}
