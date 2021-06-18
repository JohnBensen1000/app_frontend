import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../globals.dart' as globals;
import '../../API/methods/posts.dart';
import '../../models/post.dart';

import '../post/post_view.dart';

class PostListProvider extends ChangeNotifier {
  // Keeps track of the vertical offset of the posts in PostListScroller. Allows
  // for smooth sliding up and down of the posts. swipeUp(), swipeDown(), and
  // moveBack() all slowly change the vertical offsets to create a smooth
  // transition from one post to the next (or to the same post as with
  // moveBack()

  final double postVerticalOffset;

  List<double> offsets;

  PostListProvider({@required this.postVerticalOffset}) {
    offsets = [-postVerticalOffset, 0, postVerticalOffset];
  }

  double _verticalOffset = 0;
  int prevIndex, currIndex, nextIndex;

  void findIndexes() {
    prevIndex = offsets.indexOf(-postVerticalOffset);
    currIndex = offsets.indexOf(0);
    nextIndex = offsets.indexOf(postVerticalOffset);
  }

  double get verticalOffset {
    return _verticalOffset;
  }

  set verticalOffset(double newVerticalOffset) {
    _verticalOffset = newVerticalOffset;
    notifyListeners();
  }

  void swipeUp() async {
    for (int i = 0; i < 100 * (postVerticalOffset + _verticalOffset); i++) {
      _updateOffsets(0, -.01, -.01);
      await Future.delayed(Duration(microseconds: 10));
    }
    _setOffsets(postVerticalOffset, -postVerticalOffset, 0);
  }

  void swipeDown() async {
    for (int i = 0; i < 100 * (postVerticalOffset - _verticalOffset); i++) {
      _updateOffsets(.01, .01, 0);
      await Future.delayed(Duration(microseconds: 10));
    }
    _setOffsets(0, postVerticalOffset, -postVerticalOffset);
  }

  void moveBack() async {
    double direction = (_verticalOffset > 0) ? -.01 : .01;

    for (int i = 0; i < 100 * _verticalOffset.abs(); i++) {
      _updateOffsets(direction, direction, direction);
      await Future.delayed(Duration(microseconds: 10));
    }
    _setOffsets(-postVerticalOffset, 0, postVerticalOffset);
  }

  void _updateOffsets(double prevUpdate, double currUpdate, double nextUpdate) {
    offsets[prevIndex] += prevUpdate;
    offsets[currIndex] += currUpdate;
    offsets[nextIndex] += nextUpdate;
    notifyListeners();
  }

  void _setOffsets(double prevOffset, double currOffset, double nextOffset) {
    offsets[prevIndex] = prevOffset;
    offsets[currIndex] = currOffset;
    offsets[nextIndex] = nextOffset;

    _verticalOffset = 0;

    notifyListeners();
  }
}

class PostList extends StatelessWidget {
  // Simply initializes the provider and PostListPage().

  PostList({@required this.height, @required this.postList});

  final double height;
  final List<Post> postList;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => PostListProvider(postVerticalOffset: height),
        child: PostListPage(
          postList: postList,
        ));
  }
}

class PostListPage extends StatefulWidget {
  // Builds the current, previous, and next post views. Keeps track of the
  // vertical position of these three widgets. When the user starts scrolling
  // up/down, continuously updates the positions of these widgets using the
  // offset given by provider.verticalOffset. When the user stops scrolling,
  // determines if the user has scrolled far enough to move to the next widget.

  PostListPage({@required this.postList});

  final List<Post> postList;

  @override
  _PostListPageState createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  int postListIndex;
  double postVerticalOffset;

  List<Widget> postViews;
  List<bool> alreadyWatched;

  @override
  void initState() {
    super.initState();

    PostListProvider provider =
        Provider.of<PostListProvider>(context, listen: false);

    postListIndex = 0;
    postViews = [
      _postViewWidget(provider, postListIndex - 1),
      _postViewWidget(provider, postListIndex),
      _postViewWidget(provider, postListIndex + 1),
    ];
    alreadyWatched = List<bool>.filled(widget.postList.length, false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.postList.length == 0)
      return Center(
        child: Text("Sorry, we ran out of content."),
      );

    return Consumer<PostListProvider>(
      builder: (context, provider, child) {
        return Stack(children: [
          Transform.translate(
            offset: Offset(0, provider.verticalOffset + provider.offsets[0]),
            child: postViews[0],
          ),
          Transform.translate(
            offset: Offset(0, provider.verticalOffset + provider.offsets[1]),
            child: postViews[1],
          ),
          Transform.translate(
            offset: Offset(0, provider.verticalOffset + provider.offsets[2]),
            child: postViews[2],
          ),
        ]);
      },
    );
  }

  Widget _postViewWidget(PostListProvider provider, int index) {
    if (index < 0 || index >= widget.postList.length) {
      return null;
    } else {
      return GestureDetector(
        child: Center(
            child: PostView(
          post: widget.postList[index],
          height: .75 * provider.postVerticalOffset,
          aspectRatio: globals.goldenRatio,
          postStage: PostStage.fullWidget,
          playOnInit: true,
        )),
        onVerticalDragUpdate: (value) =>
            provider.verticalOffset += value.delta.dy,
        onVerticalDragEnd: (_) => _handleVerticalDragStop(provider),
      );
    }
  }

  Future<void> _handleVerticalDragStop(PostListProvider provider) async {
    // Responsible for determine what post widget to display whenever a vertical
    // drag is detected. If the user swipes down, then both the current and next
    // post widget are shifted up. The previous post widget is replaced with the
    // next un-built post widget, and is positioned to be below current widget.
    // The same logic applies for the user swiping up. Nothing happens if the
    // current post widget is either the first or last post in postList.

    _recordedWatched(postListIndex);

    provider.findIndexes();

    if (postListIndex + 1 < widget.postList.length &&
        provider.verticalOffset < -(provider.postVerticalOffset / 4)) {
      postListIndex++;
      provider.swipeUp();
      postViews[provider.prevIndex] =
          _postViewWidget(provider, postListIndex + 1);
    } else if (postListIndex - 1 >= 0 &&
        provider.verticalOffset > (provider.postVerticalOffset / 4)) {
      postListIndex--;
      provider.swipeDown();
      postViews[provider.nextIndex] =
          _postViewWidget(provider, postListIndex - 1);
    } else {
      provider.moveBack();
      // TODO: When user runs out of posts to watch, request more posts from server

    }
  }

  Future<void> _recordedWatched(int index) async {
    // Sends a post request to the server to tell it to record that the user
    // has watched the current post.
    if (!alreadyWatched[index]) {
      String postID = widget.postList[index].postID;

      await postRecordWatched(postID, 1);

      alreadyWatched[index] = true;
    }
  }
}
