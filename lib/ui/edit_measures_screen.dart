import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tfg/models/measure.dart';
import 'package:tfg/ui/common/image_viewer.dart';
import 'package:tfg/ui/common/my_app_bar.dart';
import 'package:tfg/utils/measure_painter.dart';

class EditMeasuresScreen extends StatefulWidget {
  const EditMeasuresScreen({
    super.key,
    required this.file,
    required this.measures,
  });

  final List<Measure> measures;
  final File file;

  @override
  State<EditMeasuresScreen> createState() => _EditMeasuresScreenState();
}

class _EditMeasuresScreenState extends State<EditMeasuresScreen> {
  Offset? _startPos;
  Measure? _rectToRemove;
  Offset? _currentPos;
  late final List<Measure> _measures = widget.measures.toList();
  bool _showRemoveOption = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Editar compases',
        onBackPressed: () => Navigator.of(context).pop(_measures),
      ),
      body: Column(
        spacing: 16,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              onPanStart: (details) {
                _showRemoveOption = false;
                _startPos = details.localPosition;

                final RenderBox box = context.findRenderObject() as RenderBox;
                final scaledStartPos = Offset(
                  _startPos!.dx / box.size.width,
                  _startPos!.dy / box.size.height,
                );

                _rectToRemove = _measures.firstWhere(
                  (rect) => rect.contains(scaledStartPos),
                  orElse: () => const Measure(0, 0, 0, 0),
                );

                if (_rectToRemove != const Measure(0, 0, 0, 0)) {
                  setState(() => _showRemoveOption = true);
                  return;
                }

                setState(() {
                  _currentPos = details.localPosition;
                });
              },
              onPanUpdate: (details) {
                if (!_showRemoveOption) {
                  setState(() => _currentPos = details.localPosition);
                }
              },
              onPanEnd: (details) {
                if (_startPos != null &&
                    _currentPos != null &&
                    !_showRemoveOption) {
                  final selectionRect = Rect.fromPoints(
                    _startPos!,
                    _currentPos!,
                  );
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

                  final scaledRect = Measure.fromPoints(scaledStart, scaledEnd);

                  _measures.add(scaledRect);

                  setState(() => _currentPos = null);
                }
              },
              child: Stack(
                children: [
                  ImageViewer(file: widget.file, measures: _measures),

                  if (_startPos != null &&
                      _currentPos != null &&
                      !_showRemoveOption)
                    CustomPaint(
                      painter: MeasurePainter.fromOffsets(
                        _startPos!,
                        _currentPos!,
                      ),
                    ),

                  if (_showRemoveOption)
                    Positioned(
                      left: _startPos!.dx - 22,
                      top: _startPos!.dy - 50,
                      child: IconButton.filled(
                        onPressed: () {
                          _measures.remove(_rectToRemove);
                          _startPos = null;
                          setState(() => _showRemoveOption = false);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(_measures),
                label: const Text('Guardar'),
                icon: const Icon(Icons.save_alt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
