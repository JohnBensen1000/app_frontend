import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../globals.dart' as globals;
import '../../models/post.dart';

class PostWidget extends StatelessWidget {
  // Returns a stack of the post outline and the post. The post is centered
  // inside of this outline. Determines if the post is an image, a video, or a
  // video thumbnail and returns the appropriate widget.

  const PostWidget({
    @required this.post,
    @required this.height,
    @required this.aspectRatio,
    this.playWithVolume = true,
    this.playVideo = true,
  });

  final Post post;
  final double height;
  final double aspectRatio;
  final bool playWithVolume;
  final bool playVideo;

  @override
  Widget build(BuildContext context) {
    double width = height / aspectRatio;
    double cornerRadius = height / 19;
    return Stack(alignment: Alignment.center, children: [
      Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cornerRadius),
            border: Border.all(
              width: 1.0,
              color: post.creator != null
                  ? post.creator.profileColor
                  : Colors.grey[700],
            ),
          )),
      Stack(
        alignment: Alignment.topRight,
        children: [
          if (post.isImage)
            ImageContainer(
                post: post,
                height: height,
                width: width,
                cornerRadius: cornerRadius)
          else if (playVideo)
            VideoContainer(
                post: post,
                height: height,
                width: width,
                cornerRadius: cornerRadius,
                playWithVolume: playWithVolume)
          else
            ThumbnailContainer(
                post: post,
                height: height,
                width: width,
                cornerRadius: cornerRadius),
          if (!playVideo && !post.isImage)
            Container(
                padding: EdgeInsets.all(.03 * height),
                child: Text(
                  "Video",
                  style: TextStyle(color: Colors.grey),
                )),
        ],
      )
    ]);
  }
}

class ImageContainer extends StatefulWidget {
  ImageContainer(
      {@required this.post,
      @required this.height,
      @required this.width,
      @required this.cornerRadius});

  final Post post;
  final double height;
  final double width;
  final double cornerRadius;

  @override
  _ImageContainerState createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height - 2,
        width: widget.width - 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.cornerRadius - 1),
          image: DecorationImage(
            image: Image.network(widget.post.downloadURL).image,
            fit: BoxFit.cover,
          ),
        ));
  }
}

class VideoContainer extends StatefulWidget {
  VideoContainer(
      {@required this.post,
      @required this.height,
      @required this.width,
      @required this.cornerRadius,
      @required this.playWithVolume});

  final Post post;
  final double height;
  final double width;
  final double cornerRadius;
  final bool playWithVolume;

  @override
  _VideoContainerState createState() => _VideoContainerState();
}

class _VideoContainerState extends State<VideoContainer> {
  VideoPlayerController _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context).isCurrent) {
      return FutureBuilder(
          future: _initializeVideoController(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return VisibilityDetector(
                  key: Key("unique key"),
                  child: Container(
                      width: widget.width - 2,
                      height: widget.height - 2,
                      child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(widget.cornerRadius - 1),
                          child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                  height: _videoPlayerController
                                          .value.size?.height ??
                                      0,
                                  width: _videoPlayerController
                                          .value.size?.width ??
                                      0,
                                  child: VideoPlayer(
                                    _videoPlayerController,
                                  ))))),
                  onVisibilityChanged: (VisibilityInfo info) {
                    if (info.visibleFraction == 1.0)
                      _videoPlayerController.play();
                    else
                      _videoPlayerController.pause();
                  });
            } else
              return Container(
                height: widget.height - 2,
                width: widget.width - 2,
              );
          });
    } else
      return Container();
  }

  Future<void> _initializeVideoController() async {
    _videoPlayerController =
        VideoPlayerController.network(widget.post.downloadURL);

    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.initialize();

    if (!widget.playWithVolume) await _videoPlayerController.setVolume(0.0);
  }
}

class ThumbnailContainer extends StatefulWidget {
  ThumbnailContainer({
    @required this.post,
    @required this.height,
    @required this.width,
    @required this.cornerRadius,
  });

  final Post post;
  final double height;
  final double width;
  final double cornerRadius;

  @override
  _ThumbnailContainerState createState() => _ThumbnailContainerState();
}

class _ThumbnailContainerState extends State<ThumbnailContainer> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: VideoThumbnail.thumbnailData(video: widget.post.downloadURL),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData)
            return Container(
                height: widget.height - 2,
                width: widget.width - 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.cornerRadius - 1),
                  image: DecorationImage(
                    image: MemoryImage(snapshot.data),
                    fit: BoxFit.cover,
                  ),
                ));
          else
            return Container(
              height: widget.height - 2,
              width: widget.width - 2,
            );
        });
  }
}
