import 'dart:ui' show Rect;

import 'package:tfg/models/tag.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sheet_music.g.dart';

@JsonSerializable()
class SheetMusic {
  @JsonKey(required: true)
  final int? id;
  final String title;
  final String author;
  final List<Tag> tags;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<Rect> measures;

  const SheetMusic(
    this.title,
    this.author, {
    this.id,
    this.tags = const [],
    this.measures = const [],
  });

  factory SheetMusic.fromJson(Map<String, dynamic> json) =>
      _$SheetMusicFromJson(json);

  Map<String, dynamic> toJson() => _$SheetMusicToJson(this);
}
