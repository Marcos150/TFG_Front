class PlayingState {
  bool isPlaying;
  int beatsPerMeasure = 4;
  int currentMeasure = -1;

  static final PlayingState _singleton = PlayingState._internal();

  factory PlayingState() {
    return _singleton;
  }

  PlayingState._internal(): isPlaying = false;

  void changeState() {
    isPlaying = !isPlaying;
    currentMeasure = -1;
  }

  void stop() {
    isPlaying = false;
    currentMeasure = -1;
  }
}