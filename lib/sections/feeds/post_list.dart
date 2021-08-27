import 'dart:core';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/methods/reports.dart';
import 'package:test_flutter/API/methods/watched.dart';
import 'package:test_flutter/repositories/post_list.dart';
import 'package:test_flutter/widgets/report_button.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../globals.dart' as globals;
import '../../models/post.dart';

import '../post/full_post_widget.dart';

class PostListProvider extends ChangeNotifier {
  // Acts as an in-between betweent he post list UI and post list repository.
  // Responsible for wrapping the post list repository with an API accessible
  // by the UI layer. Also takes care of other functionality not associated with
  // the post list repository. This includes recording the length of time that
  // the user spends on a post, allowing the user to block a post's creator,
  // and allowing the user to report a post.

  PostListProvider({
    @required PostListRepository repository,
    @required this.height,
  }) {
    stopWatch = Stopwatch();
    _repository = repository;
    _refreshPostListCallback();
  }

  final double height;

  PostListRepository _repository;
  Stopwatch stopWatch;

  bool get isListNotEmpty => _repository.isListNotEmpty;
  Post get previousPost => _repository.previousPost;
  Post get currentPost => _repository.currentPost;
  Post get nextPost => _repository.nextPost;

  String get repositoryName => _repository.function.toString();

  void moveDown() {
    _repository.moveDown();
  }

  void moveUp() async {
    double userRating = stopWatch.elapsed.inMilliseconds.toDouble() / 1000.0;
    await recordWatched(_repository.currentPost.postID, userRating);

    _repository.moveUp();
    stopWatch.reset();
  }

  void reportCurrentPost() {
    reportPost(_repository.currentPost);
    _repository.removeCurrentPost();
  }

  void blockCurrentCreator() {
    globals.blockedRepository.block(currentPost.creator);
  }

  void refreshPostList() => _repository.refreshPostList();

  void _refreshPostListCallback() {
    _repository.stream.listen((_) => notifyListeners());
  }
}

class PostList extends StatefulWidget {
  // Builds three post widgets at a time (current, previous, and next). These
  // three posts are rebuilt every time the user goes to a new post (updated by
  // provider). If there are no posts in the posts lists, displays a refresh
  // button. Starts the stop watch when the PostList comes into view, and pauses
  // it when it goes out of view.

  PostList({@required this.height, @required this.repository});

  final double height;
  final PostListRepository repository;

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => PostListProvider(
              height: widget.height,
              repository: widget.repository,
            ),
        child: Consumer<PostListProvider>(builder: (context, provider, child) {
          if (provider.isListNotEmpty) {
            return VisibilityDetector(
                key: Key(provider.repositoryName),
                child: PostListPage(
                    previousPostView:
                        _buildPostWidget(provider.previousPost, false),
                    currentPostView:
                        _buildPostWidget(provider.currentPost, true),
                    nextPostView: _buildPostWidget(provider.nextPost, false),
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
            return _refreshButton(provider);
          }
        }));
  }

  FullPostWidget _buildPostWidget(Post post, bool playVideo) {
    return post != null
        ? FullPostWidget(
            post: post,
            height: widget.height,
            playVideo: playVideo,
            showCaption: true)
        : null;
  }

  Widget _refreshButton(PostListProvider provider) {
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
            provider.refreshPostList();
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
  // that allows the user to report the post or block the user. Uses the
  // WidgetsBindingObserver to detect if the user leaves the app. If they do,
  // pauses the stop watch and when the user returns to the app, resumes the
  // stop watch.

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

class _PostListPageState extends State<PostListPage>
    with WidgetsBindingObserver {
  int _offset = 0;
  bool _allowSwiping = true;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      Provider.of<PostListProvider>(context, listen: false).stopWatch.start();
    else
      Provider.of<PostListProvider>(context, listen: false).stopWatch.stop();
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
          offset: Offset(0, _offset.toDouble()),
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
        if (_allowSwiping) {
          setState(() {
            _offset += value.delta.dy.toInt();
          });
        }
      },
      onVerticalDragEnd: (value) async {
        if (_allowSwiping) {
          if (_offset > .2 * widget.height && provider.previousPost != null) {
            _swipeUp(provider);
          } else if (_offset < -.2 * widget.height &&
              provider.nextPost != null) {
            _swipeDown(provider);
          } else {
            await _swipeToPosition(0, (_offset > 0) ? -1 : 1);
          }
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

  void _swipeUp(PostListProvider provider) async {
    setState(() {
      _allowSwiping = false;
    });
    await _swipeToPosition(widget.height, 1);
    provider.moveDown();
  }

  void _swipeDown(PostListProvider provider) async {
    setState(() {
      _allowSwiping = false;
    });
    await _swipeToPosition(-widget.height, -1);
    provider.moveUp();
  }

  Future<void> _swipeToPosition(double position, int direction) async {
    while ((position - _offset) * direction > 0) {
      setState(() {
        _offset += 4 * direction;
      });

      await Future.delayed(Duration(milliseconds: 1));
    }
  }
}
