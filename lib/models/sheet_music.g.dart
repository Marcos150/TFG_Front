// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_music.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SheetMusic _$SheetMusicFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id']);
  return SheetMusic(
    json['title'] as String,
    json['author'] as String,
    id: (json['id'] as num?)?.toInt(),
    tags:
        (json['tags'] as List<dynamic>?)
            ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );
}

Map<String, dynamic> _$SheetMusicToJson(SheetMusic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author,
      'tags': instance.tags,
    };
