// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sources.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Source _$SourceFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['uuid']);
  return Source(
    name: json['name'] as String? ?? "OxAnime Source",
    searchSerieNameExcludes: (json['searchSerieNameExcludes'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    searchSerieUrlResultsAbsolute:
        json['searchSerieUrlResultsAbsolute'] as bool? ?? false,
    searchSerieNameHasSplitPattern:
        json['searchSerieNameHasSplitPattern'] as bool? ?? false,
    searchSerieNameSplitPattern: json['searchSerieNameSplitPattern'] as String?,
    searchSerieNameCSSClass: json['searchSerieNameCSSClass'] as String,
    mainUrl: json['mainUrl'] as String,
    searchUrl: json['searchUrl'] as String,
    searchSerieUrlCSSClass: json['searchSerieUrlCSSClass'] as String,
    searchSerieImageCSSClass: json['searchSerieImageCSSClass'] as String,
    searchSerieChaptersCSSClass: json['searchSerieChaptersCSSClass'] as String,
    searchSerieDescriptionCSSClass:
        json['searchSerieDescriptionCSSClass'] as String,
    searchSerieDescriptionExcludes:
        (json['searchSerieDescriptionExcludes'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
    enabled: json['enabled'] as bool? ?? false,
    uuid: json['uuid'] as String,
  );
}

Map<String, dynamic> _$SourceToJson(Source instance) => <String, dynamic>{
  'searchSerieUrlResultsAbsolute': instance.searchSerieUrlResultsAbsolute,
  'searchSerieNameHasSplitPattern': instance.searchSerieNameHasSplitPattern,
  'searchSerieNameSplitPattern': instance.searchSerieNameSplitPattern,
  'searchSerieNameExcludes': instance.searchSerieNameExcludes,
  'searchSerieDescriptionExcludes': instance.searchSerieDescriptionExcludes,
  'name': instance.name,
  'mainUrl': instance.mainUrl,
  'searchUrl': instance.searchUrl,
  'searchSerieNameCSSClass': instance.searchSerieNameCSSClass,
  'searchSerieUrlCSSClass': instance.searchSerieUrlCSSClass,
  'searchSerieImageCSSClass': instance.searchSerieImageCSSClass,
  'searchSerieChaptersCSSClass': instance.searchSerieChaptersCSSClass,
  'searchSerieDescriptionCSSClass': instance.searchSerieDescriptionCSSClass,
  'enabled': instance.enabled,
  'uuid': instance.uuid,
};
