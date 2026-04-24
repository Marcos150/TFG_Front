// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'name']);
  return Tag(json['name'] as String, id: (json['id'] as num?)?.toInt());
}

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};
