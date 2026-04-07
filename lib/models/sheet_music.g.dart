// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_music.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SheetMusic _$SheetMusicFromJson(Map<String, dynamic> json) => SheetMusic(
  json['title'] as String,
  json['author'] as String,
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SheetMusicToJson(SheetMusic instance) =>
    <String, dynamic>{
      'title': instance.title,
      'author': instance.author,
      'tags': instance.tags,
    };
