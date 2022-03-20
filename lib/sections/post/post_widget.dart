import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:math';

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
      this.showComments = false,
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
  final bool showComments;
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
              PostWidgetFooter(
                text: post.caption,
                width: width,
                height: height,
                post: post,
                commentsHeightFraction: commentsHeightFraction,
                showComments: showComments,
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

class PostWidgetFooter extends StatefulWidget {
  // Displays the comments button, caption, and date time for a post. The
  // comments button is in it's own widget, and the caption and date time are
  // in the same width. When the comments button is pressed, this entire widget
  // disappears.

  const PostWidgetFooter(
      {@required this.text,
      @required this.width,
      @required this.height,
      @required this.commentsHeightFraction,
      @required this.post,
      this.showComments = false});

  final String text;
  final double width;
  final double height;
  final Post post;
  final bool showComments;
  final double commentsHeightFraction;

  @override
  State<PostWidgetFooter> createState() => _PostWidgetFooterState();
}

class _PostWidgetFooterState extends State<PostWidgetFooter> {
  bool _showCaption;

  @override
  void initState() {
    super.initState();
    _showCaption = true;
    if (widget.showComments) {
      // opens comments after build is finished
      WidgetsBinding.instance.addPostFrameCallback((_) => _openComments());
    }
  }

  @override
  Widget build(BuildContext context) {
    // First deines all the sizing (margin, widths, etc). Then, determines the
    // height of the caption. This is needed to know the height of everything.
    // Then returns a row of two widgets: a comments widget and a captions
    // widget.

    if (_showCaption == false) {
      return Container();
    }

    TextStyle textStyle = TextStyle(
      fontFamily: 'SF Pro Text',
      fontSize: .026 * widget.height,
      color: Colors.white,
    );

    double margin = .04 * widget.width;
    double captionsButtonWidth = .14 * globals.size.width;
    double captionsTextWidth =
        .95 * (widget.width - 4 * margin - 2 * captionsButtonWidth);

    String captionText =
        _resizeText(widget.post.caption, textStyle, captionsTextWidth);

    final Size size = (TextPainter(
            text: TextSpan(text: captionText, style: textStyle),
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;
    double captionsWidth = widget.width - 3 * margin - captionsButtonWidth;
    // added scaler for vertical padding
    double height = 1.1 * max(size.height, .1 * widget.height);

    return Container(
        margin: EdgeInsets.all(margin),
        height: height,
        width: widget.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                width: captionsButtonWidth,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.4),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: _commentsButton()),
            Container(
              width: widget.post.caption != null && widget.post.caption != ""
                  ? captionsWidth
                  : captionsButtonWidth,
              height: height,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.4),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: _captionsWidget(captionsTextWidth, captionsButtonWidth,
                  margin, textStyle, captionText),
            )
          ],
        ));
  }

  String _resizeText(String text, TextStyle textStyle, double maxWidth) {
    // Adds newline characters in specific spots in the text so that the text
    // remains within the maximum width. Returns the new text.

    if (widget.text == "" || widget.text == null) {
      return "";
    }

    List<String> lines = widget.text.split("\n");
    String newText = "";

    // goes through each line in the original text
    for (int i = 0; i < lines.length; i++) {
      List<String> words = lines[i].split(" ");
      String newLine = "";

      // iterates through each word in a given line
      for (int j = 0; j < words.length; j++) {
        String tempNewLine = newLine + " " + words[j];
        double tempNewLineWidth = _getSize(tempNewLine, textStyle).width;

        // if the new word can be added to the line without exceeding max width,
        // add it to the line
        if (tempNewLineWidth < maxWidth) {
          newLine = tempNewLine;
        } else {
          // if the current new line isn't blank, add the new line to the new
          // text and reset the new line
          if (newLine != "") {
            newText += newLine + "\n";
            newLine = words[j];

            // if the current line is blank, divide the word up into multiple
            // lines so it can fit within the required width
          } else {
            String temp = "";
            for (int k = 0; k < words[j].length; k++) {
              String char = words[j][k];
              double tempWidth = _getSize(temp + char, textStyle).width;

              if (tempWidth < maxWidth) {
                temp += char;
              } else {
                newText += temp + "\n";
                temp = char;
              }
            }
            newText += temp + "\n";
          }
        }
      }
      newText += newLine + "\n";
    }

    // remove the last character because it's a new line character
    return newText.substring(0, newText.length - 1);
  }

  Size _getSize(String text, TextStyle textStyle) {
    return (TextPainter(
            text: TextSpan(text: text, style: textStyle),
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;
  }

  Widget _commentsButton() {
    return GestureDetector(
        child: Center(
            child: Transform.scale(
                scale: 1.5,
                child: SvgPicture.asset("assets/images/comments.svg"))),
        onTap: () => _openComments());
  }

  Widget _captionsWidget(double captionsWidth, double dateWidth, double margin,
      TextStyle textStyle, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.post.caption != null && widget.post.caption != "")
          Expanded(
            child: Container(
              width: captionsWidth,
              child: Text(text, textAlign: TextAlign.center, style: textStyle),
            ),
          ),
        if (widget.post.caption != null && widget.post.caption != "")
          Container(width: margin),
        Container(
            width: dateWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: .2 * dateWidth,
                    ),
                    child: Image.asset("assets/images/calender.png")),
                if (widget.post.dateFormatted != null)
                  Text(widget.post.dateFormatted,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontSize: .016 * widget.height,
                        color: Colors.white,
                      ))
              ],
            )),
      ],
    );
  }

  void _openComments() {
    setState(() {
      _showCaption = false;
    });
    Navigator.of(context)
        .push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => CommentsSnackBar(
                post: widget.post,
                commentsHeightFraction: widget.commentsHeightFraction)))
        .then((_) {
      setState(() {
        _showCaption = true;
      });
    });
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
