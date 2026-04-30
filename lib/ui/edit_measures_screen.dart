import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tfg/ui/common/image_viewer.dart';
import 'package:tfg/ui/common/my_app_bar.dart';
import 'package:tfg/utils/measure_painter.dart';

class EditMeasuresScreen extends StatefulWidget {
  const EditMeasuresScreen({
    super.key,
    required this.file,
    required this.measures,
  });

  final List<Rect> measures;
  final File file;

  @override
  State<EditMeasuresScreen> createState() => _EditMeasuresScreenState();
}

class _EditMeasuresScreenState extends State<EditMeasuresScreen> {
  Offset? _startPos;
  Offset? _currentPos;
  late final List<Rect> _measures = widget.measures.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Editar compases',
        onBackPressed: () => Navigator.of(context).pop(_measures),
      ),
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _startPos = details.localPosition;
            _currentPos = details.localPosition;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _currentPos = details.localPosition;
          });
        },
        onPanEnd: (details) {
          if (_startPos != null && _currentPos != null) {
            final selectionRect = Rect.fromPoints(_startPos!, _currentPos!);
            _measures.add(selectionRect);
          }
        },
        child: Stack(
          children: [
            Flex(
              direction: Axis.vertical,
              children: [ImageViewer(file: widget.file, measures: _measures)],
            ),

            if (_startPos != null && _currentPos != null)
              CustomPaint(
                painter: MeasurePainter.fromOffsets(_startPos!, _currentPos!),
                child: Container(),
              ),
          ],
        ),
      ),
    );
  }
}
