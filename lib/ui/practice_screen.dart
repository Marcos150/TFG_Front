import 'dart:async';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:metronome/metronome.dart';
import 'package:tfg/models/playing_state.dart';
import 'package:tfg/models/sheet_music.dart';
import 'package:tfg/server/sheet_music_service.dart';
import 'package:tfg/ui/common/image_viewer.dart';
import 'package:tfg/ui/common/my_app_bar.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({required this.sheetMusic, super.key});

  final SheetMusic sheetMusic;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  File? sheetMusicFile;
  int bpm = 120;
  final metronome = Metronome();
  late final StreamSubscription<int> tickSubscription;

  @override
  void initState() {
    getSheetMusicFile(
      widget.sheetMusic.id!,
    ).then((value) => setState(() => sheetMusicFile = value));

    metronome.init(
      'assets/audio/metronome.wav',
      accentedPath: 'assets/audio/metronomeFirst.wav',
      bpm: bpm,
      //0 ~ 100
      volume: 100,
      enableTickCallback: true,
      // The time signature is the number of beats per measure,default is 4
      timeSignature: PlayingState().beatsPerMeasure,
      sampleRate: 44100,
    );

    tickSubscription = metronome.tickStream.listen((int tick) async {
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
                IconButton.outlined(
                  onPressed: PlayingState().isPlaying
                      ? null
                      : () {
                          metronome.setBPM(--bpm);
                          setState(() {});
                        },
                  onLongPress: () {
                    bpm -= 10;
                    metronome.setBPM(bpm);
                    setState(() {});
                  },
                  icon: const Icon(Icons.remove, size: 36),
                ),
                IconButton.filled(
                  onPressed: () {
                    if (PlayingState().isPlaying) {
                      metronome.stop();
                    } else {
                      metronome.play();
                    }
                    setState(() => PlayingState().changeState());
                  },
                  icon: Icon(
                    PlayingState().isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 36,
                  ),
                ),
                IconButton.outlined(
                  onPressed: PlayingState().isPlaying
                      ? null
                      : () {
                          metronome.setBPM(++bpm);
                          setState(() {});
                        },
                  onLongPress: () {
                    bpm += 10;
                    metronome.setBPM(bpm);
                    setState(() {});
                  },
                  icon: const Icon(Icons.add, size: 36),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_note, size: 42),
                Text('= $bpm', style: const TextStyle(fontSize: 32)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                ...List<Widget>.generate(3, (int index) {
                  return ChoiceChip(
                    label: Text(
                      (index + 2).toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                    selected: PlayingState().beatsPerMeasure == index + 2,
                    onSelected: PlayingState().isPlaying
                        ? null
                        : (bool selected) {
                            setState(() {
                              metronome.setTimeSignature(
                                PlayingState().beatsPerMeasure = index + 2,
                              );
                            });
                          },
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            if (sheetMusicFile == null)
              const CircularProgressIndicator()
            else
              Flexible(
                child: ImageViewer(
                  file: sheetMusicFile!,
                  measures: widget.sheetMusic.measures ?? [],
                  hideMeasures: PlayingState().isPlaying,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    metronome.destroy();
    tickSubscription.cancel();
    PlayingState().stop();
    super.dispose();
  }

  @override
  void deactivate() {
    metronome.stop();
    PlayingState().stop();
    super.deactivate();
  }
}
