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
  late Offset _globalScaledStartPos; // For erasing measures
  Offset? _currentPos;
  late final List<Rect> _measures = widget.measures.toList();
  bool showRemoveOption = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Editar compases',
        onBackPressed: () => Navigator.of(context).pop(_measures),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          onPanStart: (details) {
            showRemoveOption = false;
            _globalScaledStartPos = Offset(
              details.globalPosition.dx / constraints.maxWidth,
              details.globalPosition.dy / constraints.maxHeight,
            );
            final bool hasTappedRect = _measures.any(
              (rect) => rect.contains(_globalScaledStartPos),
            );

            _startPos = details.localPosition;

            if (hasTappedRect) {
              setState(() => showRemoveOption = true);
              return;
            }

            setState(() {
              _currentPos = details.localPosition;
            });
          },
          onPanUpdate: (details) {
            if (!showRemoveOption) {
              setState(() => _currentPos = details.localPosition);
            }
          },
          onPanEnd: (details) {
            if (_startPos != null && _currentPos != null) {
              final selectionRect = Rect.fromPoints(_startPos!, _currentPos!);
              if (selectionRect.longestSide < 20) return;

              final RenderBox box = context.findRenderObject() as RenderBox;
              final size = box.size;

              final scaledStart = Offset(
                _startPos!.dx / size.width,
                _startPos!.dy / size.height,
              );

              final scaledEnd = Offset(
                _currentPos!.dx / size.width,
                _currentPos!.dy / size.height,
              );

              final scaledRect = Rect.fromPoints(scaledStart, scaledEnd);

              _measures.add(scaledRect);

              setState(() => _currentPos = null);
            }
          },
          child: Stack(
            children: [
              ImageViewer(file: widget.file, measures: _measures),

              if (_startPos != null && _currentPos != null)
                CustomPaint(
                  painter: MeasurePainter.fromOffsets(_startPos!, _currentPos!),
                ),

              if (showRemoveOption)
                Positioned(
                  left: _startPos!.dx - 22,
                  top: _startPos!.dy - 50,
                  child: IconButton.filled(
                    onPressed: () {
                      _measures.removeWhere(
                        (rect) => rect.contains(_globalScaledStartPos),
                      );
                      setState(() => showRemoveOption = false);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
