import 'dart:ui_web' as ui; // ✅ Fix deprecated platformViewRegistry
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePlayerWidget extends StatefulWidget {
  final String videoId;

  const YoutubePlayerWidget({super.key, required this.videoId});

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;
  bool isPlaying = true;
  bool isMuted = false;
  Duration currentDuration = Duration.zero;
  Duration totalDuration = const Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
    // _registerTransparentOverlay();
    _initController();
  }

  void _initController() {
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      params: const YoutubePlayerParams(
        enableJavaScript: true,
        showControls: true,
        showFullscreenButton: true,
        playsInline: true,
        showVideoAnnotations: false,
        strictRelatedVideos: true,
        // pointerEvents: PointerEvents.none, // disables iframe interaction
      ),
    );

    _controller.videoStateStream.listen((state) async {
      final durationSeconds = await _controller.duration;
      setState(() {
        currentDuration = state.position;
        totalDuration = Duration(seconds: durationSeconds.toInt());
      });
    });
  }

  // void _registerTransparentOverlay() {
  //   // Register only once
  //   ui.platformViewRegistry.registerViewFactory(
  //     'transparent-blocker',
  //         (int viewId) {
  //       final blocker = html.DivElement()
  //         ..style.width = '100%'
  //         ..style.height = '100%'
  //         ..style.position = 'absolute'
  //         ..style.top = '0'
  //         ..style.left = '0'
  //         ..style.zIndex = '9999'
  //         ..style.backgroundColor = 'transparent'
  //         ..style.pointerEvents = 'auto'; // blocks interaction
  //       return blocker;
  //     },
  //   );
  // }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  void didUpdateWidget(YoutubePlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      _controller.loadVideoById(videoId: widget.videoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Column(
      children: [
        YoutubePlayerScaffold(
          controller: _controller,
          builder: (context, player) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: AspectRatio(
                aspectRatio: 41/20,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: player,
                      ),
                      // const HtmlElementView(viewType: 'transparent-blocker'),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Custom Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(_formatDuration(currentDuration)),
                  Expanded(
                    child: Slider(
                      value: currentDuration.inSeconds.toDouble(),
                      min: 0,
                      max: totalDuration.inSeconds.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          currentDuration = Duration(seconds: value.toInt());
                        });
                      },
                      onChangeEnd: (value) {
                        _controller.seekTo(seconds: value);
                      },
                    ),
                  ),
                  Text(_formatDuration(totalDuration - currentDuration)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      setState(() {
                        isPlaying = !isPlaying;
                        isPlaying ? _controller.playVideo() : _controller.pauseVideo();
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                    onPressed: () {
                      setState(() {
                        isMuted = !isMuted;
                        isMuted ? _controller.mute() : _controller.unMute();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}