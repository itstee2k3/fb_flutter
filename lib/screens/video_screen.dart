import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  final List<String> videoAssets;
  final int initialIndex;

  const VideoScreen({super.key, required this.videoAssets, this.initialIndex = 0});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late PageController _pageController;
  late int currentIndex;
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
    _initializeController(widget.videoAssets[currentIndex]);
  }

  void _initializeController(String videoAsset) {
    // If the controller is already initialized, do nothing
    if (_controller != null && _controller!.value.isInitialized) return;

    _controller?.dispose(); // Dispose of any previous controller if it exists
    _controller = VideoPlayerController.asset(videoAsset)
      ..initialize().then((_) {
        setState(() {});
        _controller?.play();
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _changeVideo(int index) {
    setState(() {
      currentIndex = index;
      _initializeController(widget.videoAssets[currentIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.videoAssets.length,
            onPageChanged: _changeVideo,
            itemBuilder: (context, index) {
              return Center(
                child: _controller?.value.isInitialized ?? false
                    ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
                    : const CircularProgressIndicator(color: Colors.white),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (currentIndex > 0)
            Positioned(
              bottom: 60,
              left: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Icon(Icons.navigate_before),
              ),
            ),
          if (currentIndex < widget.videoAssets.length - 1)
            Positioned(
              bottom: 60,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Icon(Icons.navigate_next),
              ),
            ),
          Positioned(
                bottom: 60,
                left: MediaQuery.of(context).size.width / 2 - 28,  // Center horizontally
                child: FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: () {
                setState(() {
                if (_controller?.value.isPlaying ?? false) {
                _controller?.pause();
                } else {
                _controller?.play();
                }
                });
                },
                child: Icon(
                  (_controller?.value.isPlaying ?? false)
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
            ),

        ],
      ),
    );
  }
}
