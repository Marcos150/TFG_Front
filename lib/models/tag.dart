import 'package:json_annotation/json_annotation.dart';
part 'tag.g.dart';

@JsonSerializable()
class Tag {
  final String name;

  const Tag(this.name);

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);
}