import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  VideoPreview({Key key, @required this.file, @required this.playVideo})
      : super(key: key);

  final File file;
  final bool playVideo;

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController videoController;

  @override
  void initState() {
    videoController = VideoPlayerController.file(widget.file);
    videoController.setLooping(true);

    super.initState();
  }

  @override
  void dispose() {
    videoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: videoController.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return FutureBuilder(
              future: videoController.play(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return VideoPlayer(videoController);
                } else {
                  return Center(child: Text("Loading..."));
                }
              });
        } else {
          return Center(child: Text("Loading..."));
        }
      },
    );
  }
}
