// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chapter _$ChapterFromJson(Map<String, dynamic> json) =>
    Chapter(index: (json['index'] as num).toInt(), uri: json['uri'] as String);

Map<String, dynamic> _$ChapterToJson(Chapter instance) => <String, dynamic>{
  'index': instance.index,
  'uri': instance.uri,
};

Serie _$SerieFromJson(Map<String, dynamic> json) => Serie(
  name: json['name'] as String,
  description: json['description'] as String?,
  chapters: (json['chapters'] as List<dynamic>)
      .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
      .toList(),
  sourceUUID: json['sourceUUID'] as String,
);

Map<String, dynamic> _$SerieToJson(Serie instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'chapters': instance.chapters,
  'sourceUUID': instance.sourceUUID,
};
