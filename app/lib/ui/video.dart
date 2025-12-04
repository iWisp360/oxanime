import "package:flutter/material.dart";
import "package:media_kit/media_kit.dart";
import "package:media_kit_video/media_kit_video.dart";

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final Map<String, String>? headers;
  const VideoPlayerScreen({super.key, required this.videoUrl, this.headers});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final player = Player();
  late final VideoController controller = VideoController(player);

  @override
  void initState() {
    super.initState();

    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    player.open(Media(widget.videoUrl, httpHeaders: widget.headers));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Video(controller: controller));
  }
}
