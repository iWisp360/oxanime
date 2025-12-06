// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sources.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Source _$SourceFromJson(Map<String, dynamic> json) => Source(
  serieFields: SourceSerieFields.fromJson(
    json['serieFields'] as Map<String, dynamic>,
  ),
  searchFields: SourceSearchFields.fromJson(
    json['searchFields'] as Map<String, dynamic>,
  ),
  videosFields: SourceVideosFields.fromJson(
    json['videosFields'] as Map<String, dynamic>,
  ),
  chaptersFields: SourceChaptersFields.fromJson(
    json['chaptersFields'] as Map<String, dynamic>,
  ),
  configurationFields: SourceConfigurationFields.fromJson(
    json['configurationFields'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$SourceToJson(Source instance) => <String, dynamic>{
  'serieFields': instance.serieFields,
  'searchFields': instance.searchFields,
  'videosFields': instance.videosFields,
  'chaptersFields': instance.chaptersFields,
  'configurationFields': instance.configurationFields,
};

SourceChaptersFields _$SourceChaptersFieldsFromJson(
  Map<String, dynamic> json,
) => SourceChaptersFields(
  identifiersCSSClass:
      json['identifiersCSSClass'] as String? ?? Placeholders.emptyString,
  urlsCSSClass: json['urlsCSSClass'] as String? ?? Placeholders.emptyString,
);

Map<String, dynamic> _$SourceChaptersFieldsToJson(
  SourceChaptersFields instance,
) => <String, dynamic>{
  'identifiersCSSClass': instance.identifiersCSSClass,
  'urlsCSSClass': instance.urlsCSSClass,
};

SourceConfigurationFields _$SourceConfigurationFieldsFromJson(
  Map<String, dynamic> json,
) => SourceConfigurationFields(
  enabled: json['enabled'] as bool? ?? false,
  mainUrl: json['mainUrl'] as String? ?? Placeholders.emptyString,
  searchUrl: json['searchUrl'] as String? ?? Placeholders.emptyString,
  name: json['name'] as String? ?? Placeholders.emptyString,
  uuid: json['uuid'] as String? ?? Placeholders.uuid,
  searchUrlResultsAbsolute: json['searchUrlResultsAbsolute'] as bool? ?? false,
);

Map<String, dynamic> _$SourceConfigurationFieldsToJson(
  SourceConfigurationFields instance,
) => <String, dynamic>{
  'name': instance.name,
  'mainUrl': instance.mainUrl,
  'searchUrl': instance.searchUrl,
  'enabled': instance.enabled,
  'uuid': instance.uuid,
  'searchUrlResultsAbsolute': instance.searchUrlResultsAbsolute,
};

SourceSerieFields _$SourceSerieFieldsFromJson(Map<String, dynamic> json) =>
    SourceSerieFields(
      descriptionCSSClass:
          json['descriptionCSSClass'] as String? ?? Placeholders.emptyString,
      nameCSSClass: json['nameCSSClass'] as String? ?? Placeholders.emptyString,
      descriptionExcludes:
          (json['descriptionExcludes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      nameExcludes:
          (json['nameExcludes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SourceSerieFieldsToJson(SourceSerieFields instance) =>
    <String, dynamic>{
      'descriptionCSSClass': instance.descriptionCSSClass,
      'nameCSSClass': instance.nameCSSClass,
      'descriptionExcludes': instance.descriptionExcludes,
      'nameExcludes': instance.nameExcludes,
    };

SourceSearchFields _$SourceSearchFieldsFromJson(Map<String, dynamic> json) =>
    SourceSearchFields(
      serieUrlCSSClass:
          json['serieUrlCSSClass'] as String? ?? Placeholders.emptyString,
      serieImageCSSClass:
          json['serieImageCSSClass'] as String? ?? Placeholders.emptyString,
      serieImageExcludes:
          (json['serieImageExcludes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      serieUrlExcludes:
          (json['serieUrlExcludes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SourceSearchFieldsToJson(SourceSearchFields instance) =>
    <String, dynamic>{
      'serieUrlCSSClass': instance.serieUrlCSSClass,
      'serieUrlExcludes': instance.serieUrlExcludes,
      'serieImageCSSClass': instance.serieImageCSSClass,
      'serieImageExcludes': instance.serieImageExcludes,
    };

SourceVideosFields _$SourceVideosFieldsFromJson(Map<String, dynamic> json) =>
    SourceVideosFields(
      videoSourcesPriority:
          (json['videoSourcesPriority'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      videosUrlParseMode:
          $enumDecodeNullable(
            _$ChaptersVideosUrlParseModesEnumMap,
            json['videosUrlParseMode'],
          ) ??
          ChaptersVideosUrlParseModes.empty,
      videosUrlLocation:
          $enumDecodeNullable(
            _$ChaptersVideosUrlLocationEnumMap,
            json['videosUrlLocation'],
          ) ??
          ChaptersVideosUrlLocation.empty,
      jsonListKeyForVideosUrl:
          json['jsonListKeyForVideosUrl'] as String? ??
          Placeholders.emptyString,
      jsonListStartPattern:
          json['jsonListStartPattern'] as String? ?? Placeholders.emptyString,
      jsonListEndPattern:
          json['jsonListEndPattern'] as String? ?? Placeholders.emptyString,
    );

Map<String, dynamic> _$SourceVideosFieldsToJson(SourceVideosFields instance) =>
    <String, dynamic>{
      'videoSourcesPriority': instance.videoSourcesPriority,
      'videosUrlLocation':
          _$ChaptersVideosUrlLocationEnumMap[instance.videosUrlLocation]!,
      'videosUrlParseMode':
          _$ChaptersVideosUrlParseModesEnumMap[instance.videosUrlParseMode]!,
      'jsonListStartPattern': instance.jsonListStartPattern,
      'jsonListEndPattern': instance.jsonListEndPattern,
      'jsonListKeyForVideosUrl': instance.jsonListKeyForVideosUrl,
    };

const _$ChaptersVideosUrlParseModesEnumMap = {
  ChaptersVideosUrlParseModes.jsonList: 'jsonList',
  ChaptersVideosUrlParseModes.empty: 'empty',
};

const _$ChaptersVideosUrlLocationEnumMap = {
  ChaptersVideosUrlLocation.cssClass: 'cssClass',
  ChaptersVideosUrlLocation.none: 'none',
  ChaptersVideosUrlLocation.empty: 'empty',
};
