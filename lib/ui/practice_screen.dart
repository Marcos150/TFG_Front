import 'dart:async';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:metronome/metronome.dart';
import 'package:tfg/models/playing_state.dart';
import 'package:tfg/models/sheet_music.dart';
import 'package:tfg/server/sheet_music_service.dart';
import 'package:tfg/ui/common/image_viewer.dart';
import 'package:tfg/ui/common/maintained_press_detector.dart';
import 'package:tfg/ui/common/my_app_bar.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({required this.sheetMusic, super.key});

  final SheetMusic sheetMusic;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  File? _sheetMusicFile;
  int _bpm = 120;
  final _metronome = Metronome();
  late final StreamSubscription<int> _tickSubscription;
  bool _errorGettingFile = false;

  @override
  void initState() {
    getSheetMusicFile(widget.sheetMusic.id)
        .then((value) => setState(() => _sheetMusicFile = value))
        .catchError((_) => setState(() => _errorGettingFile = true));

    _metronome.init(
      'assets/audio/metronome.wav',
      accentedPath: 'assets/audio/metronomeFirst.wav',
      bpm: _bpm,
      //0 ~ 100
      volume: 100,
      enableTickCallback: true,
      // The time signature is the number of beats per measure,default is 4
      timeSignature: PlayingState().beatsPerMeasure,
    );

    _tickSubscription = _metronome.tickStream.listen((int tick) async {
      if (tick == 0) {
        PlayingState().currentMeasure++;
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: widget.sheetMusic.title),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 24,
              children: [
                MaintainedPressDetector(
                  frequency: const Duration(milliseconds: 100),
                  whileLongPress: () {
                    _metronome.setBPM(--_bpm);
                    setState(() {});
                  },
                  child: IconButton.outlined(
                    onPressed: () {
                      _metronome.setBPM(--_bpm);
                      setState(() {});
                    },
                    icon: const Icon(Icons.remove, size: 36),
                  ),
                ),
                IconButton.filled(
                  onPressed: () {
                    if (PlayingState().isPlaying) {
                      _metronome.stop();
                    } else {
                      _metronome.play();
                    }
                    setState(() => PlayingState().changeState());
                  },
                  icon: Icon(
                    PlayingState().isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 36,
                  ),
                ),
                MaintainedPressDetector(
                  frequency: const Duration(milliseconds: 100),
                  whileLongPress: () {
                    _metronome.setBPM(++_bpm);
                    setState(() {});
                  },
                  child: IconButton.outlined(
                    onPressed: () {
                      _metronome.setBPM(++_bpm);
                      setState(() {});
                    },
                    icon: const Icon(Icons.add, size: 36),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_note, size: 42),
                Text('= $_bpm', style: const TextStyle(fontSize: 32)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                ...List<Widget>.generate(4, (int index) {
                  return ChoiceChip(
                    label: Text(
                      (index + 1).toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                    selected: PlayingState().beatsPerMeasure == index + 1,
                    onSelected: PlayingState().isPlaying
                        ? null
                        : (bool selected) {
                            setState(() {
                              _metronome.setTimeSignature(
                                PlayingState().beatsPerMeasure = index + 1,
                              );
                            });
                          },
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            if (_sheetMusicFile != null)
              Flexible(
                child: ImageViewer(
                  file: _sheetMusicFile!,
                  measures: widget.sheetMusic.measures ?? const [],
                  hideMeasures: PlayingState().isPlaying,
                ),
              ),
            if (_errorGettingFile)
              const Text(
                'Error al cargar la partitura.',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _metronome.destroy();
    _tickSubscription.cancel();
    PlayingState().stop();
    super.dispose();
  }

  @override
  void deactivate() {
    _metronome.stop();
    PlayingState().stop();
    super.deactivate();
  }
}
