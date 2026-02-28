import 'package:tfg/models/tag.dart';

class SheetMusic {
  final String name;
  final String author;
  final List<Tag> tags;

  const SheetMusic(this.name, this.author, {this.tags = const []});
}