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

  FullPostProvider({@required bool isOpen}) {
    _isOpen = isOpen;
    _yOffset = (_isOpen) ? 0 : 1;
  }

  double deltaY = .009;

  bool _isOpen;
  double _yOffset;

  bool get isOpen => _isOpen;

  double get yOffset => _yOffset;

  set yOffset(newYOffset) {
    _yOffset = newYOffset > 0 ? newYOffset : 0;
    notifyListeners();
  }

  Future<void> openComments() async {
    _isOpen = true;
    notifyListeners();

    while (_yOffset > 0) {
      _yOffset -= deltaY;
      await Future.delayed(Duration(milliseconds: 1));
      notifyListeners();
    }
  }

  Future<void> closeComments() async {
    while (_yOffset < 1) {
      _yOffset += deltaY;
      await Future.delayed(Duration(milliseconds: 1));
      notifyListeners();
    }

    _isOpen = false;
    notifyListeners();
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
      this.playVideo = true,
      this.isFullPage = false,
      this.showComments = false,
      this.showCaption = false});

  final Post post;
  final double height;
  final bool playVideo;
  final bool isFullPage;
  final bool showComments;
  final bool showCaption;

  @override
  State<FullPostWidget> createState() => _FullPostWidgetState();
}

class _FullPostWidgetState extends State<FullPostWidget> {
  @override
  Widget build(BuildContext context) {
    double postWidgetHeight = .8 * widget.height;
    double width = postWidgetHeight / globals.goldenRatio;
    return ChangeNotifierProvider(
        create: (context) => FullPostProvider(isOpen: widget.showComments),
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Container(
            height: widget.height,
            width: width,
            child: Column(
              children: [
                GestureDetector(
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
                    child: PostWidget(
                      post: widget.post,
                      height: postWidgetHeight,
                      aspectRatio: globals.goldenRatio,
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
          CommentsSnackBar(height: widget.height, post: widget.post),
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
            onTap: () => provider.openComments()),
      );
    else
      return Container();
  }
}

class CommentsSnackBar extends StatefulWidget {
  // When the comments section is opened, this widget returns a stack of a
  // transparent button that closes the comments section and the comments
  // section.
  CommentsSnackBar({@required this.height, @required this.post});

  final double height;
  final Post post;

  @override
  _CommentsSnackBarState createState() => _CommentsSnackBarState();
}

class _CommentsSnackBarState extends State<CommentsSnackBar> {
  double snackbarHeight;

  @override
  void initState() {
    snackbarHeight = .7 * widget.height;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FullPostProvider>(builder: (context, provider, child) {
      if (provider.isOpen)
        return GestureDetector(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              GestureDetector(
                child: Container(
                  width: globals.size.width,
                  height: widget.height,
                  color: Colors.transparent,
                ),
                onTap: () => provider.closeComments(),
              ),
              Transform.translate(
                offset: Offset(0, provider.yOffset * snackbarHeight),
                child: GestureDetector(
                  child: Container(
                    width: globals.size.width,
                    height: snackbarHeight + .03 * globals.size.height,
                    decoration: BoxDecoration(
                        color: Colors.grey[300].withOpacity(.8),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Comments(height: snackbarHeight, post: widget.post),
                  ),
                  onVerticalDragUpdate: (DragUpdateDetails dragUpdates) =>
                      provider.yOffset += dragUpdates.delta.dy / snackbarHeight,
                  onVerticalDragEnd: (DragEndDetails dragEndDetails) =>
                      provider.yOffset > .2
                          ? provider.closeComments()
                          : provider.openComments(),
                ),
              )
            ],
          ),
          onLongPress: () => null,
          onVerticalDragUpdate: (_) => null,
          onVerticalDragDown: (_) => null,
        );
      else
        return Container();
    });
  }
}
