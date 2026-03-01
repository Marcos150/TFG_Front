import 'dart:io' show File;

import 'package:flutter/material.dart';

void showSnackbar(
  final String text,
  final BuildContext context, {
  final int duration = 2,
}) {
  final snackBar = SnackBar(
    duration: Duration(seconds: duration),
    content: Text(text),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

String getFileExtension(final File file) => file.path.split('.').last;
