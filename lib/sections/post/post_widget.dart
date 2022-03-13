import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../globals.dart' as globals;
import '../../models/post.dart';
import '../../widgets/post_caption.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../comments/comments.dart';
import '../../widgets/entropy_scaffold.dart';

import '../../main.dart';

class PostWidget extends StatelessWidget {
  // Returns a stack of the post outline and the post. The post is centered
  // inside of this outline. Determines if the post is an image, a video, or a
  // video thumbnail and returns the appropriate widget.

  const PostWidget(
      {@required this.post,
      @required this.height,
      @required this.aspectRatio,
      this.commentsHeightFraction = .65,
      this.playWithVolume = true,
      this.playVideo = true,
      this.showCaption = false,
      this.cornerRadiusFraction = 0.04});

  final Post post;
  final double height;
  final double aspectRatio;
  final bool playWithVolume;
  final bool playVideo;
  final bool showCaption;
  final double cornerRadiusFraction;
  final double commentsHeightFraction;

  @override
  Widget build(BuildContext context) {
    double borderWidth = .0025 * globals.size.width;
    double width = .98 * (height / aspectRatio);
    double cornerRadius = cornerRadiusFraction * height;

    return Stack(alignment: Alignment.center, children: [
      StreamBuilder(
          stream: globals.userRepository.stream,
          builder: (context, snapshot) {
            return FutureBuilder(
                future: globals.userRepository.get(
                    post.creator != null ? post.creator.uid : post.creatorUID),
                builder: (context, snapshot) {
                  return Container(
                      height: height,
                      width: width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(cornerRadius),
                          border: Border.all(
                              width: borderWidth,
                              color: (snapshot.hasData)
                                  ? snapshot.data.profileColor
                                  : post.creator != null
                                      ? post.creator.profileColor
                                      : Colors.transparent)));
                });
          }),
      Container(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                if (post.isImage)
                  ImageContainer(
                      post: post,
                      height: height - 2 * borderWidth,
                      width: width - 2 * borderWidth,
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
            ),
            if (showCaption)
              PostWidgetCaption(
                text: post.caption,
                width: width,
                height: height,
                post: post,
                commentsHeightFraction: commentsHeightFraction,
              ),
          ],
        ),
      ),
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
        height: widget.height,
        width: widget.width,
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
  // When this widget is first built, calls a future that initializes the video
  // player and saves this future in the variable _videoPlayerFuture. Also
  // subscribes to the routeObserver (initialized in main.dart). When another
  // route is pushed on top of this widget, the callback didPushNext() is called
  // and the video is paused. This widget also uses the visibility detector to
  // pause the video when it is hidden from view, and play the video when it is
  // 100% in view. Disposes of the video controller when this widget is
  // disposed.

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

class _VideoContainerState extends State<VideoContainer> with RouteAware {
  Future _videoPlayerFuture;
  VideoPlayerController _videoPlayerController;
  bool _isDisposed;

  @override
  void initState() {
    _videoPlayerFuture = _initializeVideoController();
    _isDisposed = false;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPushNext() {
    if (_videoPlayerController != null) {
      _videoPlayerController.pause();
    }
  }

  @override
  void didPop() {
    if (_videoPlayerController != null) {
      _videoPlayerController.pause();
    }
  }

  @override
  void dispose() {
    _disposeVideoController();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _videoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _videoPlayerController != null)
            return VisibilityDetector(
              key: Key(widget.post.postID),
              child: Container(
                  width: widget.width - 2,
                  height: widget.height - 2,
                  child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(widget.cornerRadius - 1),
                      child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                              height:
                                  _videoPlayerController.value.size?.height ??
                                      0,
                              width:
                                  _videoPlayerController.value.size?.width ?? 0,
                              child: VideoPlayer(
                                _videoPlayerController,
                              ))))),
              onVisibilityChanged: (info) {
                if (_isDisposed != true && _videoPlayerController != null) {
                  if (info.visibleFraction == 1.0)
                    _videoPlayerController.play();
                  else
                    _videoPlayerController.pause();
                }
              },
            );
          else
            return Container(
              height: widget.height - 2,
              width: widget.width - 2,
            );
        });
  }

  Future<void> _initializeVideoController() async {
    _videoPlayerController =
        VideoPlayerController.network(widget.post.downloadURL);

    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.initialize();

    if (!widget.playWithVolume) await _videoPlayerController.setVolume(0.0);
  }

  Future<void> _disposeVideoController() async {
    if (_videoPlayerController != null) {
      await _videoPlayerController.pause();
      await _videoPlayerController.dispose();
      _isDisposed = true;
    }
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

class PostWidgetCaption extends StatefulWidget {
  const PostWidgetCaption(
      {@required this.text,
      @required this.width,
      @required this.height,
      @required this.commentsHeightFraction,
      @required this.post});

  final String text;
  final double width;
  final double height;
  final Post post;
  final double commentsHeightFraction;

  @override
  State<PostWidgetCaption> createState() => _PostWidgetCaptionState();
}

class _PostWidgetCaptionState extends State<PostWidgetCaption> {
  bool showCaption;

  @override
  void initState() {
    super.initState();
    showCaption = true;
  }

  @override
  Widget build(BuildContext context) {
    if (showCaption == false) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(.025 * widget.width),
      child: Stack(
        children: [
          if (widget.post.caption != null && widget.post.caption != "")
            Container(
              alignment: Alignment.centerLeft,
              child: Container(
                width: .775 * widget.width,
                height: .12 * widget.height,
                padding: EdgeInsets.symmetric(
                    horizontal: .04 * globals.size.width,
                    vertical: .01 * globals.size.height),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.4),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
            ),
          if (widget.post.caption != null && widget.post.caption != "")
            Container(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(.025 * widget.width),
                  child: Text(widget.text,
                      style: TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontSize: .018 * globals.size.height,
                        color: Colors.white,
                      )),
                )),
          Container(
            alignment: Alignment.centerRight,
            child: GestureDetector(
                child: Container(
                    width: .15 * widget.width,
                    height: .12 * widget.height,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.4),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Center(
                        child: Transform.scale(
                            scale: 1.5,
                            child: SvgPicture.asset(
                                "assets/images/comments.svg")))),
                onTap: () {
                  setState(() {
                    showCaption = false;
                  });
                  Navigator.of(context)
                      .push(PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (_, __, ___) => CommentsSnackBar(
                              post: widget.post,
                              commentsHeightFraction:
                                  widget.commentsHeightFraction)))
                      .then((_) {
                    setState(() {
                      showCaption = true;
                    });
                  });
                }),
          ),
        ],
      ),
    );
  }
}

class CommentsSnackBar extends StatefulWidget {
  // When the comments section is opened, this widget returns a stack of a
  // transparent button that closes the comments section and the comments
  // section.
  CommentsSnackBar({
    @required this.post,
    @required this.commentsHeightFraction,
  });

  final Post post;
  final double commentsHeightFraction;

  @override
  _CommentsSnackBarState createState() => _CommentsSnackBarState();
}

class _CommentsSnackBarState extends State<CommentsSnackBar> {
  Widget _commentsWidget;
  double _deltaY;
  double _yOffset;

  @override
  void initState() {
    _deltaY = .009;
    _yOffset = 1;

    _commentsWidget = Comments(
        height: widget.commentsHeightFraction * globals.size.height,
        post: widget.post);
    super.initState();
    _openComments();
  }

  @override
  Widget build(BuildContext context) {
    return EntropyScaffold(
        disableAutoPadding: true,
        backgroundColor: Colors.transparent,
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                child: Container(
                    height: (1 - widget.commentsHeightFraction) *
                        globals.size.height,
                    color: Colors.transparent),
                onTap: () => _closeComments(),
              ),
              Transform.translate(
                  offset: Offset(
                      0,
                      (_yOffset * widget.commentsHeightFraction) *
                              globals.size.height +
                          .01 * globals.size.height),
                  child: Container(
                    height: widget.commentsHeightFraction * globals.size.height,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: <Color>[
                            Colors.grey[300].withOpacity(1.0),
                            Colors.grey[200].withOpacity(.8),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        )),
                    child: _commentsWidget,
                  ))
            ],
          ),
        ));
  }

  Future<void> _openComments() async {
    while (_yOffset > 0) {
      _yOffset -= _deltaY;
      await Future.delayed(Duration(milliseconds: 1));
      setState(() {});
    }
  }

  Future<void> _closeComments() async {
    while (_yOffset <= 1) {
      _yOffset += _deltaY;
      await Future.delayed(Duration(milliseconds: 1));
      setState(() {});
    }
    Navigator.pop(context);
  }
}
