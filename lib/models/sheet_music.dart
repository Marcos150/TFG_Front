import 'package:tfg/models/tag.dart';
import 'package:json_annotation/json_annotation.dart';

import 'measure.dart';

part 'sheet_music.g.dart';

@JsonSerializable(explicitToJson: true)
class SheetMusic {
  @JsonKey(required: true)
  final int id;
  final String title;
  final String author;
  final List<Tag> tags;
  final List<Measure> measures;
  final String? fileLocalPath;

  SheetMusic(
    this.title,
    this.author, {
    required this.id,
    this.tags = const [],
    this.measures = const [],
    this.fileLocalPath,
  }) {
    measures.sort((a, b) {
      const tolerance = 0.05;

      if ((a.top - b.top).abs() > tolerance) return a.top.compareTo(b.top);

      return a.left.compareTo(b.left);
    });
  }

  const SheetMusic.empty()
    : id = -1,
      title = '',
      author = '',
      tags = const [],
      measures = const [],
      fileLocalPath = null;

  factory SheetMusic.fromJson(Map<String, dynamic> json) =>
      _$SheetMusicFromJson(json);

  Map<String, dynamic> toJson() => _$SheetMusicToJson(this);
}
