import 'package:tfg/models/tag.dart';
import 'package:json_annotation/json_annotation.dart';
part 'sheet_music.g.dart';

@JsonSerializable()
class SheetMusic {
  final String title;
  final String author;
  final List<Tag> tags;

  const SheetMusic(this.title, this.author, {this.tags = const []});

  factory SheetMusic.fromJson(Map<String, dynamic> json) => _$SheetMusicFromJson(json);

  Map<String, dynamic> toJson() => _$SheetMusicToJson(this);
}
