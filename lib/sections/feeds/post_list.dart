import 'dart:core';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/methods/watched.dart';
import 'package:test_flutter/widgets/report_button.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../globals.dart' as globals;
import '../../API/handle_requests.dart';
import '../../models/post.dart';
import '../../models/user.dart';

import '../post/full_post_widget.dart';
import '../post/post_page.dart';

class PostListProvider extends ChangeNotifier {
  // Contains the list of posts for the post list. Whenever the user changes the
  // post that they are on, this provider checks if user is approaching the end
  // of the post list. if they are, calls the Function function to get a new
  // list of posts. Provides functions for removing an individual post for when
  // the user reports a post and removing all posts from a creator when the user
  // blocks a user.
  // Uses a stop watch to keep track of how long the user spends on a post. This
  // is used to determine how much the user likes the post. timeInFullScreen
  // keeps track of how much time the user spent in full screen mode of the
  // post.

  final Function function;
  final BuildContext context;

  List<Post> _postsList;
  int _currentPostIndex;

  Stopwatch stopWatch;

  PostListProvider(
      {@required this.function,
      @required this.context,
      @required List<Post> postsList}) {
    _postsList = postsList;
    _currentPostIndex = 0;

    stopWatch = new Stopwatch();

    _blockedCreatorCallback();
  }

  set currentPostIndex(int newCurrentPostIndex) {
    _currentPostIndex = newCurrentPostIndex;
    if (_currentPostIndex >= _postsList.length - 2) refreshPostsList();
    stopWatch.reset();

    notifyListeners();
  }

  int get currentPostIndex => _currentPostIndex;

  Post get currentPost => _postsList[_currentPostIndex];

  void refreshPostsList() async {
    List<Post> newPosts = await handleRequest(context, function());
    if (newPosts != null) _postsList += newPosts;
  }

  void reportCurrentPost() {
    _postsList.remove(currentPost);
    if (currentPostIndex == _postsList.length) currentPostIndex--;

    notifyListeners();
  }

  void blockCurrentCreator() {
    globals.blockedRepository.block(currentPost.creator);
  }

  Future<void> recordRating() async {
    double userRating = stopWatch.elapsed.inMilliseconds / 1000.0;
    await recordWatched(currentPost.postID, userRating);
  }

  void _blockedCreatorCallback() {
    globals.blockedRepository.stream.listen((List<User> blockedUsers) {
      for (User user in blockedUsers) {
        for (int i = _postsList.length - 1; i >= 0; i--) {
          if (_postsList[i].creator.uid == user.uid) {
            _postsList.removeAt(i);
            currentPostIndex--;
          }
        }

        if (currentPostIndex < 0)
          currentPostIndex = 0;
        else if (currentPostIndex >= _postsList.length - 1)
          currentPostIndex = _postsList.length - 1;
        else
          currentPostIndex = currentPostIndex + 1;
      }
    });
    notifyListeners();
  }
}

class PostList extends StatefulWidget {
  // Calls the function to get the posts for the post list. Builds three post
  // widgets at a time (current, previous, and next posts). These three posts
  // are rebuilt every time the user goes to a new post (updated by provider).
  // If there are no posts in the posts lists, displays a refresh button. Starts
  // the stop watch when the PostList comes into view, and pauses it when it
  // goes out of view.

  PostList({@required this.height, @required this.function});

  final double height;
  final Function function;

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: handleRequest(context, widget.function()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return ChangeNotifierProvider(
              create: (context) => PostListProvider(
                  function: widget.function,
                  context: context,
                  postsList: snapshot.data),
              child: Consumer<PostListProvider>(
                  builder: (context, provider, child) {
                List<Post> postsList = provider._postsList;
                int currentIndex = provider.currentPostIndex;

                if (postsList.length != 0) {
                  return VisibilityDetector(
                      key: Key("unique key"),
                      child: PostListPage(
                          previousPostView:
                              _buildPostView(postsList, currentIndex - 1),
                          currentPostView:
                              _buildPostView(postsList, currentIndex),
                          nextPostView:
                              _buildPostView(postsList, currentIndex + 1),
                          height: widget.height,
                          key: UniqueKey()),
                      onVisibilityChanged: (VisibilityInfo info) {
                        if (info.visibleFraction == 1.0) {
                          provider.stopWatch.start();
                        } else {
                          provider.stopWatch.stop();
                        }
                      });
                } else {
                  return _refreshButton();
                }
              }));
        } else {
          return _refreshButton();
        }
      },
    );
  }

  Widget _buildPostView(List<Post> postList, int index) {
    if (index < 0 || index >= postList.length) {
      return null;
    } else {
      return FullPostWidget(
          post: postList[index], height: widget.height, showCaption: true);
    }
  }

  Widget _refreshButton() {
    return Center(
      child: GestureDetector(
          child: Container(
              width: .205 * globals.size.width,
              height: .0355 * globals.size.height,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius:
                      BorderRadius.all(Radius.circular(globals.size.height))),
              child: Center(child: Text("Refresh"))),
          onTap: () {
            setState(() {});
          }),
    );
  }
}

class PostListPage extends StatefulWidget {
  // Displays the three posts as a stack, with the previous and next posts
  // offset vertically to be off the screen. This stack of posts is wrapped in a
  // Gesture Detector. The vertical position of the stack is updated
  // continuously as the user swipes up or down. If the user swiped far enough
  // up or down, updates the current post index and moves to the next or
  // previous post. If the user holds down on a post, displays an alert dialog
  // that allows the user to report the post or block the user.

  PostListPage({
    @required this.previousPostView,
    @required this.currentPostView,
    @required this.nextPostView,
    @required this.height,
    Key key,
  }) : super(key: key);

  final FullPostWidget previousPostView;
  final FullPostWidget currentPostView;
  final FullPostWidget nextPostView;
  final double height;

  @override
  _PostListPageState createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  int offset = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PostListProvider provider =
        Provider.of<PostListProvider>(context, listen: false);

    return GestureDetector(
      child: Container(
        height: widget.height,
        width: double.infinity,
        color: Colors.transparent,
        child: Transform.translate(
          offset: Offset(0, offset.toDouble()),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                  offset: Offset(0, -widget.height),
                  child: widget.previousPostView),
              Transform.translate(
                  offset: Offset(0, 0), child: widget.currentPostView),
              Transform.translate(
                  offset: Offset(0, widget.height), child: widget.nextPostView)
            ],
          ),
        ),
      ),
      onVerticalDragUpdate: (value) {
        setState(() {
          offset += value.delta.dy.toInt();
        });
      },
      onVerticalDragEnd: (value) async {
        List<Post> postsList = provider._postsList;
        int currentIndex = provider.currentPostIndex;

        if (offset > .2 * widget.height && currentIndex - 1 >= 0) {
          _swipeUp(currentIndex, provider);
        } else if (offset < -.2 * widget.height &&
            currentIndex + 1 < postsList.length) {
          _swipeDown(currentIndex, provider);
        } else {
          await _swipeToPosition(0, (offset > 0) ? -1 : 1);
        }
      },
      onLongPress: () async {
        await showDialog(
                context: context,
                builder: (context) =>
                    ReportContentAlertDialog(post: provider.currentPost))
            .then((actionTaken) {
          switch (actionTaken) {
            case ActionTaken.blocked:
              provider.blockCurrentCreator();
              break;
            case ActionTaken.reported:
              provider.reportCurrentPost();
              break;
          }
        });
      },
    );
  }

  void _swipeUp(int currentIndex, PostListProvider provider) async {
    await _swipeToPosition(widget.height, 1);

    provider.currentPostIndex = currentIndex - 1;
  }

  void _swipeDown(int currentIndex, PostListProvider provider) async {
    await _swipeToPosition(-widget.height, -1);

    provider.recordRating();
    provider.currentPostIndex = currentIndex + 1;
  }

  Future<void> _swipeToPosition(double position, int direction) async {
    while ((position - offset) * direction > 0) {
      setState(() {
        offset += 4 * direction;
      });

      await Future.delayed(Duration(milliseconds: 1));
    }
  }
}
