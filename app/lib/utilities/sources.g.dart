// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sources.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Source _$SourceFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['uuid']);
  return Source(
    chaptersVideosJsonListStartPattern:
        json['chaptersVideosJsonListStartPattern'] as String,
    chaptersVideosJsonListEndPattern:
        json['chaptersVideosJsonListEndPattern'] as String,
    videoSourcesPriority:
        (json['videoSourcesPriority'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    videosUrlParseMode: $enumDecode(
      _$ChaptersVideosUrlParseModesEnumMap,
      json['videosUrlParseMode'],
    ),
    searchSerieNameExcludes: (json['searchSerieNameExcludes'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    searchSerieNameCSSClass: json['searchSerieNameCSSClass'] as String,
    searchSerieUrlCSSClass: json['searchSerieUrlCSSClass'] as String,
    searchSerieImageCSSClass: json['searchSerieImageCSSClass'] as String,
    searchSerieChaptersIdentifiersCSSClass:
        json['searchSerieChaptersIdentifiersCSSClass'] as String,
    searchSerieChaptersUrlsCSSClass:
        json['searchSerieChaptersUrlsCSSClass'] as String,
    searchSerieDescriptionCSSClass:
        json['searchSerieDescriptionCSSClass'] as String,
    searchSerieDescriptionExcludes:
        (json['searchSerieDescriptionExcludes'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
    searchSerieImageExcludes:
        (json['searchSerieImageExcludes'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
    searchSerieUrlExcludes: (json['searchSerieUrlExcludes'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    name: json['name'] as String? ?? "OxAnime Source",
    mainUrl: json['mainUrl'] as String,
    searchUrl: json['searchUrl'] as String,
    searchSerieUrlResultsAbsolute:
        json['searchSerieUrlResultsAbsolute'] as bool? ?? false,
    enabled: json['enabled'] as bool? ?? false,
    uuid: json['uuid'] as String,
  );
}

Map<String, dynamic> _$SourceToJson(Source instance) => <String, dynamic>{
  'searchSerieNameCSSClass': instance.searchSerieNameCSSClass,
  'searchSerieNameExcludes': instance.searchSerieNameExcludes,
  'searchSerieDescriptionCSSClass': instance.searchSerieDescriptionCSSClass,
  'searchSerieDescriptionExcludes': instance.searchSerieDescriptionExcludes,
  'searchSerieUrlCSSClass': instance.searchSerieUrlCSSClass,
  'searchSerieUrlExcludes': instance.searchSerieUrlExcludes,
  'searchSerieImageCSSClass': instance.searchSerieImageCSSClass,
  'searchSerieImageExcludes': instance.searchSerieImageExcludes,
  'searchSerieChaptersIdentifiersCSSClass':
      instance.searchSerieChaptersIdentifiersCSSClass,
  'searchSerieChaptersUrlsCSSClass': instance.searchSerieChaptersUrlsCSSClass,
  'videoSourcesPriority': instance.videoSourcesPriority,
  'videosUrlParseMode':
      _$ChaptersVideosUrlParseModesEnumMap[instance.videosUrlParseMode]!,
  'chaptersVideosJsonListStartPattern':
      instance.chaptersVideosJsonListStartPattern,
  'chaptersVideosJsonListEndPattern': instance.chaptersVideosJsonListEndPattern,
  'name': instance.name,
  'mainUrl': instance.mainUrl,
  'searchUrl': instance.searchUrl,
  'enabled': instance.enabled,
  'uuid': instance.uuid,
  'searchSerieUrlResultsAbsolute': instance.searchSerieUrlResultsAbsolute,
};

const _$ChaptersVideosUrlParseModesEnumMap = {
  ChaptersVideosUrlParseModes.jsonList: 'jsonList',
};
