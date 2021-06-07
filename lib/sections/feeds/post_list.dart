import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../globals.dart' as globals;
import '../../API/posts.dart';
import '../../models/post.dart';

import '../post/post_view.dart';

class PostListTransitionProvider extends ChangeNotifier {
  // Keeps track of the vertical offset of the posts in PostListScroller. Allows
  // for smooth sliding up and down of the posts. swipeUp(), swipeDown(), and
  // moveBack() all slowly change the vertical offsets to create a smooth
  // transition from one post to the next (or to the same post as with
  // moveBack()

  final double postVerticalOffset;

  List<double> offsets;

  PostListTransitionProvider({@required this.postVerticalOffset}) {
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

class PostList extends StatefulWidget {
  /*Responsible for displaying a scrollable list of post widgets. At any given
    time, this widget holds the previous, current, and next post widget so that
    transition between post widgets is smooth. The previous and next post widget
    are both positioned off-screen. By using a PostListScrollerProvider() and a
    GestureDetector(), this widget listens to the user's vertical drags to
    continuously update the position of each widget.
  */

  PostList({@required this.postList});

  final List<Post> postList;

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  int postListIndex = 0;
  double postVerticalOffset = 650;

  List<Future<PostView>> postViews;
  List<bool> alreadyWatched;

  @override
  Widget build(BuildContext context) {
    if (widget.postList.length == 0)
      return Center(
        child: Text("Sorry, we ran out of content."),
      );

    alreadyWatched = List<bool>.filled(widget.postList.length, false);
    postViews = [
      _buildPostView(postListIndex - 1),
      _buildPostView(postListIndex),
      _buildPostView(postListIndex + 1)
    ];

    return ChangeNotifierProvider(
      create: (context) =>
          PostListTransitionProvider(postVerticalOffset: postVerticalOffset),
      child: Consumer<PostListTransitionProvider>(
          builder: (context, provider, child) {
        alreadyWatched[postListIndex] = true;

        return Stack(children: [
          Transform.translate(
            offset: Offset(0, provider.verticalOffset + provider.offsets[0]),
            child: _buildGestureDetector(provider, postViews[0]),
          ),
          Transform.translate(
            offset: Offset(0, provider.verticalOffset + provider.offsets[1]),
            child: _buildGestureDetector(provider, postViews[1]),
          ),
          Transform.translate(
            offset: Offset(0, provider.verticalOffset + provider.offsets[2]),
            child: _buildGestureDetector(provider, postViews[2]),
          ),
        ]);
      }),
    );
  }

  Future<PostView> _buildPostView(int index) async {
    // Looks to see if index is a valid index of widget.postList. If it is,
    // builds and returns a PostView() that corresponds to the correct
    // item of widget.postList. If the post is a video, then this function
    // initializes the videoPlayerController that will be used to play/pause the
    // video.

    if (index < 0 || index >= widget.postList.length) {
      return null;
    } else {
      Post post = widget.postList[index];
      VideoPlayerController videoPlayerController;

      if (post.isImage == false) {
        videoPlayerController = VideoPlayerController.network(post.downloadURL);
        videoPlayerController.setLooping(true);
      }

      PostView postView = PostView(
        post: post,
        height: 500,
        aspectRatio: globals.goldenRatio,
        postStage: PostStage.fullWidget,
        videoPlayerController: videoPlayerController,
        playOnInit: true,
      );

      return postView;
    }
  }

  GestureDetector _buildGestureDetector(
      PostListTransitionProvider provider, Future<PostView> PostView) {
    // Returns a GestureDetector that contains a post widget and updates the
    // provider whenever it detects a vertical drag.

    return GestureDetector(
      child: FutureBuilder(
          future: PostView,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Center(child: snapshot.data);
            } else {
              return Center();
            }
          }),
      onVerticalDragUpdate: (value) =>
          provider.verticalOffset += value.delta.dy,
      onVerticalDragEnd: (_) {
        _handleVerticalDragStop(provider);
      },
    );
  }

  Future<void> _handleVerticalDragStop(
      PostListTransitionProvider provider) async {
    // Responsible for determine what post widget to display whenever a vertical
    // drag is detected. If the user swipes down, then both the current and next
    // post widget are shifted up. The previous post widget is replaced with the
    // next un-built post widget, and is positioned to be below current widget.
    // The same logic applies for the user swiping up. Nothing happens if the
    // current post widget is either the first or last post in postList.

    _recordedWatched();

    provider.findIndexes();

    if (postListIndex + 1 < widget.postList.length &&
        provider.verticalOffset < -(postVerticalOffset / 4)) {
      postListIndex++;
      provider.swipeUp();
      await _dealWithvideoPlayerControllers(await postViews[provider.nextIndex],
          await postViews[provider.currIndex]);

      postViews[provider.prevIndex] = _buildPostView(postListIndex + 1);
    } else if (postListIndex - 1 >= 0 &&
        provider.verticalOffset > (postVerticalOffset / 4)) {
      postListIndex--;
      provider.swipeDown();
      await _dealWithvideoPlayerControllers(await postViews[provider.prevIndex],
          await postViews[provider.currIndex]);

      postViews[provider.nextIndex] = _buildPostView(postListIndex - 1);
    } else {
      provider.moveBack();
      // TODO: When user runs out of posts to watch, request more posts from server

    }
  }

  Future<void> _recordedWatched() async {
    // Sends a post request to the server to tell it to record that the user
    // has watched the current post.
    String postID = widget.postList[postListIndex].postID;

    var response = await recordWatched(postID, 5);

    alreadyWatched[postListIndex] = true;
  }

  Future<void> _dealWithvideoPlayerControllers(
      PostView postViewPlay, PostView postViewPause) async {
    // This function only applies to video posts. Plays a video if it comes
    // into view. Pauses a video if it goes off screen.

    if (postViewPlay != null && postViewPlay.videoPlayerController != null) {
      await postViewPlay.videoPlayerController.play();
    }
    if (postViewPause != null && postViewPause.videoPlayerController != null) {
      await postViewPause.videoPlayerController.pause();
      await postViewPause.videoPlayerController
          .seekTo(Duration(microseconds: 0));
    }
  }
}
