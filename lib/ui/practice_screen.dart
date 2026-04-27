import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:metronome/metronome.dart';
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
  int bpm = 60;
  bool isPlaying = false;
  final metronome = Metronome();

  @override
  void initState() {
    getSheetMusicFile(
      widget.sheetMusic.id!,
    ).then((value) => setState(() => sheetMusicFile = value));

    metronome.init(
      'assets/audio/vine-boom.wav',
      accentedPath: 'assets/audio/loud-vine-boom.wav',
      bpm: bpm,
      //0 ~ 100
      volume: 70,
      enableTickCallback: false,
      // The time signature is the number of beats per measure,default is 4
      timeSignature: 4,
      sampleRate: 88200,
    );

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
                  onPressed: () {
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
                    if (isPlaying) {
                      metronome.stop();
                    } else {
                      metronome.play();
                    }
                    setState(() => isPlaying = !isPlaying);
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 36,
                  ),
                ),
                IconButton.outlined(
                  onPressed: () {
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
            const SizedBox(height: 12),
            if (sheetMusicFile == null)
              const CircularProgressIndicator()
            else
              Expanded(child: ImageViewer(file: sheetMusicFile!)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    metronome.destroy();
    super.dispose();
  }

  @override
  void deactivate() {
    metronome.stop();
    super.deactivate();
  }
}
