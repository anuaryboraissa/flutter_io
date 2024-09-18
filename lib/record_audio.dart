import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderScreen extends StatefulWidget {
  const AudioRecorderScreen({super.key});

  @override
  State<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  String? _recordedFilePath;
  bool _isRecording = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder?.openRecorder();
    await _player?.openPlayer();
    await Permission.microphone.request();
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      String path = await _getFilePath();
      setState(() {
        _recordedFilePath = path;
        _isRecording = true;
      });
      await _recorder?.startRecorder(toFile: path, codec: Codec.aacADTS);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission denied")),
      );
    }
  }

  Future<void> _stopRecording() async {
    await _recorder?.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Recording saved at $_recordedFilePath")),
    );
  }

  Future<void> _playAudio() async {
    if (_recordedFilePath != null && File(_recordedFilePath!).existsSync()) {
      await _player?.startPlayer(
        fromURI: _recordedFilePath,
        codec: Codec.aacADTS,
      );
      setState(() {
        _isPlaying = _player!.isPlaying;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No recorded file found")),
      );
    }
  }

  Future<void> _stopAudio() async {
    await _player?.stopPlayer();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _player?.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Recorder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(_isRecording ? "Recording..." : "Press record to start"),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(_isRecording ? "Stop Recording" : "Start Recording"),
                onPressed: _isRecording ? _stopRecording : _startRecording,
              ),
              const SizedBox(height: 20),
              Text(_isPlaying ? "Playing..." : "Press play to listen"),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                label: Text(_isPlaying ? "Stop Playing" : "Play Audio"),
                onPressed: _isPlaying ? _stopAudio : _playAudio,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
