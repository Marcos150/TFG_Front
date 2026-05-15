import 'dart:io' show File;

String _getFileExtension(final File file) => file.path.split('.').last;

enum SheetMusicFileType {
  pdf,
  image,
  other;

  static const allowedExtensions = ['pdf', 'jpeg', 'jpg', 'png', 'webp'];
}

SheetMusicFileType getFileType(final File file) {
  final extension = _getFileExtension(file);
  switch (extension) {
    case 'pdf':
      return SheetMusicFileType.pdf;
    case 'jpg':
    case 'jpeg':
    case 'webp':
    case 'png':
      return SheetMusicFileType.image;
    default:
      return SheetMusicFileType.other;
  }
}