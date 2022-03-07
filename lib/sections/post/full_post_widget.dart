import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../widgets/profile_pic.dart';
import '../../models/post.dart';

import '../profile_page/profile_page.dart';
import '../comments/comments.dart';

import 'post_widget.dart';
import 'post_page.dart';

class FullPostProvider extends ChangeNotifier {
  // Controls the animation of opening and closing the comments section. If
  // isOpen is true, then the comments section is initially positioned as open,
  // otherwise it is positioned as closed.

  FullPostProvider(
      {@required this.post,
      @required this.commentsHeightFraction,
      @required BuildContext context,
      bool isOpen = false}) {
    _isOpen = isOpen;
    if (isOpen) {
      openComments(context);
    }
  }

  final Post post;
  final double commentsHeightFraction;

  bool _isOpen;

  bool get isOpen => _isOpen;

  set isOpen(newIsOpen) {
    _isOpen = newIsOpen;
    notifyListeners();
  }

  Future<void> openComments(BuildContext context) async {
    isOpen = true;
    Navigator.of(context)
        .push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => CommentsSnackBar(
                post: post, commentsHeightFraction: commentsHeightFraction)))
        .then((value) => isOpen = false);
  }
}

class FullPostWidget extends StatefulWidget {
  // Returns a column of the creator's profile, the post, and the comments
  // button. When the profile is pressed, takes user to that creator's profile
  // page. When the post is pressed and the post is not it's own page, then
  // takes the user to the page that only shows the post. When the comments
  // button is pressed, opens up the comments section.

  FullPostWidget(
      {@required this.post,
      @required this.height,
      this.aspectRatio = globals.goldenRatio,
      this.playVideo = true,
      this.isFullPage = false,
      this.showComments = false,
      this.verticalOffset = 0,
      this.commentsHeightFraction = .65,
      this.showCaption = false});

  final double aspectRatio;
  final Post post;
  final double height;
  final bool playVideo;
  final bool isFullPage;
  final bool showComments;
  final bool showCaption;
  final double verticalOffset;
  final double commentsHeightFraction;

  @override
  State<FullPostWidget> createState() => _FullPostWidgetState();
}

class _FullPostWidgetState extends State<FullPostWidget> {
  @override
  Widget build(BuildContext context) {
    double postWidgetHeight = .8 * widget.height;
    double width = postWidgetHeight / widget.aspectRatio;
    return ChangeNotifierProvider(
        create: (context) => FullPostProvider(
            commentsHeightFraction: widget.commentsHeightFraction,
            post: widget.post,
            context: context,
            isOpen: widget.showComments),
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Container(
            height: widget.height,
            width: width,
            child: Column(
              children: [
                GestureDetector(
                    key: UniqueKey(),
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: .01 * widget.height),
                        child: Profile(
                            diameter: .08 * widget.height,
                            user: widget.post.creator)),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(user: widget.post.creator)))),
                GestureDetector(
                    key: UniqueKey(),
                    child: PostWidget(
                      post: widget.post,
                      height: postWidgetHeight,
                      aspectRatio: widget.aspectRatio,
                      showCaption: widget.showCaption,
                      playVideo: widget.playVideo,
                    ),
                    onTap: () {
                      if (!widget.isFullPage) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostPage(
                                    isFullPost: true, post: widget.post)));
                      }
                    }),
                CommentsButton(),
              ],
            ),
          ),
        ]));
  }
}

class CommentsButton extends StatelessWidget {
  // When pressed, tells provider to open the comments section. The button only
  // appears if the comments section is closed.

  @override
  Widget build(BuildContext context) {
    FullPostProvider provider = Provider.of<FullPostProvider>(context);

    if (!provider.isOpen)
      return Container(
        padding: EdgeInsets.only(top: .01 * globals.size.height),
        child: GestureDetector(
            child: Container(
                padding: EdgeInsets.only(top: .00355 * globals.size.height),
                width: .374 * globals.size.width,
                height: .0296 * globals.size.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(globals.size.height),
                  color: const Color(0xffffffff),
                  border:
                      Border.all(width: 3.0, color: const Color(0xff707070)),
                ),
                child: Text(
                  'View Comments',
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: .0118 * globals.size.height,
                    color: const Color(0x67000000),
                  ),
                  textAlign: TextAlign.center,
                )),
            onTap: () => provider.openComments(context)),
      );
    else
      return Container();
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
    return Column(
      children: [
        GestureDetector(
          child: Container(
              width: globals.size.width,
              height: (1 - widget.commentsHeightFraction) * globals.size.height,
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
              width: globals.size.width,
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
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: _commentsWidget,
            ))
      ],
    );
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
