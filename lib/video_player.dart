import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerScreen2 extends StatefulWidget {
  const VideoPlayerScreen2({super.key});

  @override
  State<VideoPlayerScreen2> createState() => _VideoPlayerScreen2State();
}

class _VideoPlayerScreen2State extends State<VideoPlayerScreen2> {
  late VideoPlayerController _controller;
  late VideoPlayerController _assetVideoController;
  ChewieController? _chewieController; // For custom UI controls
  ChewieController? _assetChewieController; // For custom UI controls
  bool _isLoading = true;
  bool _hasError = false;

  bool _assetIsLoading = true;
  bool _assetHasError = false;

  @override
  void initState() {
    super.initState();
    initAssetVideo();
    initOnlineVideo();
  }

  initAssetVideo() async {
    setState(() {
      _assetIsLoading = true;
      _assetHasError = false;
    });
    try {
      _assetVideoController = VideoPlayerController.asset("assets/video.mp4");

      await _assetVideoController.initialize();

      // Create the ChewieController
      _assetChewieController = ChewieController(
        videoPlayerController: _assetVideoController,
        autoPlay: true,
        looping: false,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error loading video: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {
        _assetIsLoading = false;
      });
    } catch (error) {
      setState(() {
        _assetHasError = true;
        _assetIsLoading = false;
      });
    }
  }

  initOnlineVideo() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      // Check if it's a network or asset video

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        ),
      );

      await _controller.initialize();

      // Create the ChewieController
      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: true,
        looping: false,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error loading video: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    _assetVideoController.dispose();
    _assetChewieController?.dispose();
    super.dispose();
  }

  void _reloadAssetVideo() {
    _assetVideoController.pause();
    _assetVideoController.dispose();
    initAssetVideo();
  }

  _reloadOnlineVideo() {
    _controller.pause();
    _controller.dispose();
    initOnlineVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Video Player'),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .43,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _hasError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Failed to load video.'),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _reloadOnlineVideo,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : Chewie(
                            controller: _chewieController!,
                          ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .45),
                height: MediaQuery.of(context).size.height * .43,
                width: double.infinity,
                child: _assetIsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _assetHasError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Failed to load asset video.'),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _reloadAssetVideo,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : Chewie(
                            controller: _assetChewieController!,
                          ),
              ),
              // Main content of the screen goes here
              Positioned(
                bottom: 20,
                right: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_assetHasError)
                      FloatingActionButton(
                        onPressed: _reloadAssetVideo,
                        child: const Icon(Icons.sync),
                      ),
                    if (_hasError) ...[
                      const SizedBox(height: 10), // Space between buttons
                      FloatingActionButton(
                        onPressed: _reloadOnlineVideo,
                        child: const Icon(Icons.sync_disabled_outlined),
                      )
                    ]
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
