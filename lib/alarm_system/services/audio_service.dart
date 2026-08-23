import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer player = AudioPlayer();
  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await player.setReleaseMode(
      ReleaseMode.loop,
    );

    _initialized = true;
  }

// diff alarms based oon severity levels
  Future<void> playMild() async {
    await initialize();

    await player.stop();

    await player.play(
      AssetSource('alarms/mild_alarm.mp3'),
    );
  }

  Future<void> playWarning() async {
    await initialize();

    await player.stop();

    await player.play(
      AssetSource('alarms/warning_alarm.mp3'),
    );
  }

  Future<void> playCritical() async {
    await initialize();

    await player.stop();

    await player.play(
      AssetSource('alarms/critical_alarm.mp3'),
    );
  }

// stop alarms
  Future<void> stop() async {
    await player.stop();
  }

  Future<void> dispose() async {
    await player.stop();
    await player.dispose();
    _initialized = false;
  }
}