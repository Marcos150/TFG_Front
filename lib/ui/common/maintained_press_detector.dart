import 'package:flutter/material.dart';

class MaintainedPressDetector extends StatefulWidget {
  final Widget? child;
  final Duration frequency;
  final VoidCallback whileLongPress;
  final bool enabled;

  const MaintainedPressDetector({
    super.key,
    this.child,
    this.frequency = const Duration(milliseconds: 500),
    required this.whileLongPress,
    this.enabled = true,
  });

  @override
  State<MaintainedPressDetector> createState() =>
      _MaintainedPressDetectorState();
}

class _MaintainedPressDetectorState extends State<MaintainedPressDetector> {
  bool _buttonPressed = false;

  void _increaseCounterWhilePressed() async {
    while (_buttonPressed) {
      widget.whileLongPress();
      await Future<void>.delayed(
        Duration(milliseconds: widget.frequency.inMilliseconds),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.enabled
          ? () {
              _buttonPressed = true;
              _increaseCounterWhilePressed();
            }
          : null,
      onLongPressUp: widget.enabled ? () => _buttonPressed = false : null,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _buttonPressed = false;
    super.dispose();
  }
}
