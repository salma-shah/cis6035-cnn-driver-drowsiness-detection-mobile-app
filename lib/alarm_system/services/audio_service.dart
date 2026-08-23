import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer player = AudioPlayer();
  bool isInitalized = false;
  bool isPlaying = false;

  Future<void> initialize() async {
    if (isInitalized) return;
    await player.setReleaseMode(ReleaseMode.loop);
   isInitalized = true;
  }

   Future<void> playMild() async {
    // if (isPlaying) return;
    // isPlaying = true;
    await initialize();
    await player.play(
      AssetSource('alarms/mild_alarm.mp3'),
    );
  }

  Future<void> playWarning() async {
    //if (isPlaying) return;
   // isPlaying = true;
    await initialize();
    await player.play(
      AssetSource('alarms/warning_alarm.mp3'),
    );
  }

  Future<void> playCritical() async {
    // await stop();
    // isPlaying = true;
    await initialize();
    await player.play(
      AssetSource('alarms/critical_alarm.mp3'),
    );
  }

  Future<void> stop() async {
  //  if (!isPlaying) return;

    await player.stop();

   // isPlaying = false;
  }

  Future<void> dispose() async {
    await player.dispose();
  }
}