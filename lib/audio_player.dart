import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isPaused = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Listen to audio position changes
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playOnlineAudio() async {
    const String url =
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";
    await _audioPlayer.play(UrlSource(url));
    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });
  }

  Future<void> _playLocalAudio() async {
    // Play from assets
    await _audioPlayer.play(AssetSource('audio.mp3'));
    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
      _isPaused = true;
    });
  }

  Future<void> _resumeAudio() async {
    await _audioPlayer.resume();
    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _position = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Player"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Now Playing", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Slider(
              min: 0.0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble(),
              onChanged: (value) async {
                final position = Duration(seconds: value.toInt());
                await _audioPlayer.seek(position);
                await _audioPlayer.resume();
                setState(() {
                  _position = position;
                  _isPlaying = true;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position)),
                Text(_formatDuration(_duration)),
              ],
            ),
            const SizedBox(height: 20),
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isPlaying
                      ? _pauseAudio
                      : (_isPaused ? _resumeAudio : _playOnlineAudio),
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(_isPlaying
                      ? "Pause"
                      : (_isPaused ? "Resume" : "Play Online")),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _isPlaying ? _stopAudio : _playLocalAudio,
                  icon: const Icon(Icons.stop),
                  label: Text(_isPlaying ? "Stop" : "Play Local"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
