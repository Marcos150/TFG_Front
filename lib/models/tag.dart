import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

@JsonSerializable()
class Tag {
  @JsonKey(required: true)
  final int? id;
  @JsonKey(required: true)
  final String name;

  const Tag(this.name, {this.id});

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);

  @override
  bool operator ==(Object other) =>
      other is Tag && other.runtimeType == runtimeType && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
