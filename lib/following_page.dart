import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'user_info.dart';
import 'backend_connect.dart';
import 'view_post.dart';

final backendConnection = new ServerAPI();
FirebaseStorage storage = FirebaseStorage.instance;

class FollowingPage extends StatelessWidget {
  // Main widget for the following page. Returns a FutureBuilder() that waits
  // for a list of posts from the server. Once this widget recieves this list,
  // it builds PostListScroller().
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return PostListScroller(postList: snapshot.data);
          } else {
            return Center(child: Text("Loading...."));
          }
        });
  }

  Future<List<dynamic>> _getPosts() async {
    String newUrl = backendConnection.url + "posts/$userID/following/";
    var response = await http.get(newUrl);
    return json.decode(response.body)["postsList"];
  }
}

class PostListScrollerProvider extends ChangeNotifier {
  // Keeps track of the vertical offset of the posts in PostListScroller. Allows
  // for smooth sliding up and down of the posts. swipeUp(), swipeDown(), and
  // moveBack() all slowly change the vertical offsets to create a smooth
  // transition from one post to the next (or to the same post as with
  // moveBack()

  final double _postVerticalOffset;

  double _verticalOffset = 0;
  List<double> offsets;
  int prevIndex, currIndex, nextIndex;

  PostListScrollerProvider({@required double postVerticalOffset})
      : _postVerticalOffset = postVerticalOffset {
    offsets = [-_postVerticalOffset, 0, _postVerticalOffset];
  }

  void findIndexes() {
    prevIndex = offsets.indexOf(-_postVerticalOffset);
    currIndex = offsets.indexOf(0);
    nextIndex = offsets.indexOf(_postVerticalOffset);
  }

  double get verticalOffset {
    return _verticalOffset;
  }

  set verticalOffset(double newVerticalOffset) {
    _verticalOffset = newVerticalOffset;
    notifyListeners();
  }

  void swipeUp() async {
    for (int i = 0; i < 100 * (_postVerticalOffset + _verticalOffset); i++) {
      _updateOffsets(0, -.01, -.01);
      await Future.delayed(Duration(microseconds: 10));
    }
    _setOffsets(_postVerticalOffset, -_postVerticalOffset, 0);
  }

  void swipeDown() async {
    for (int i = 0; i < 100 * (_postVerticalOffset - _verticalOffset); i++) {
      _updateOffsets(.01, .01, 0);
      await Future.delayed(Duration(microseconds: 10));
    }
    _setOffsets(0, _postVerticalOffset, -_postVerticalOffset);
  }

  void moveBack() async {
    double direction = (_verticalOffset > 0) ? -.01 : .01;

    for (int i = 0; i < 100 * _verticalOffset.abs(); i++) {
      _updateOffsets(direction, direction, direction);
      await Future.delayed(Duration(microseconds: 10));
    }
    _setOffsets(-_postVerticalOffset, 0, _postVerticalOffset);
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

class PostListScroller extends StatefulWidget {
  /*Responsible for displaying a scrollable list of post widgets. At any given
    time, this widget holds the previous, current, and next post widget so that
    transition between post widgets is smooth. The previous and next post widget
    are both positioned off-screen. By using a PostListScrollerProvider() and a
    GestureDetector(), this widget listens to the user's vertical drags to 
    continuously update the position of each widget. 
  */

  PostListScroller({@required this.postList});

  final List<dynamic> postList;

  @override
  _PostListScrollerState createState() => _PostListScrollerState();
}

class _PostListScrollerState extends State<PostListScroller> {
  int postListIndex = 0;
  double postVerticalOffset = 650;

  List<Future<PostWidget>> postWidgets;

  @override
  Widget build(BuildContext context) {
    postWidgets = [
      _buildPostWidget(postListIndex - 1),
      _buildPostWidget(postListIndex),
      _buildPostWidget(postListIndex + 1)
    ];
    return ChangeNotifierProvider(
      create: (context) =>
          PostListScrollerProvider(postVerticalOffset: postVerticalOffset),
      child: Consumer<PostListScrollerProvider>(
          builder: (context, provider, child) {
        return Stack(children: [
          Transform.translate(
            offset: Offset(0, provider.verticalOffset + provider.offsets[0]),
            child: _buildGestureDetector(provider, postWidgets[0]),
          ),
          Transform.translate(
            offset: Offset(0, provider.verticalOffset + provider.offsets[1]),
            child: _buildGestureDetector(provider, postWidgets[1]),
          ),
          Transform.translate(
            offset: Offset(0, provider.verticalOffset + provider.offsets[2]),
            child: _buildGestureDetector(provider, postWidgets[2]),
          ),
        ]);
      }),
    );
  }

  Future<PostWidget> _buildPostWidget(int index) async {
    // Looks to see if index is a valid index of widget.postList. If it is,
    // builds and returns a PostWidget() that corresponds to the correct
    // item of widget.postList. If the post is a video, then this function
    // initializes the videoController that will be used to play/pause the
    // video.

    if (index < 0 || index >= widget.postList.length) {
      return null;
    } else {
      Post post = Post.fromJson(widget.postList[index]);
      VideoPlayerController videoController;

      if (post.isImage == false) {
        videoController =
            VideoPlayerController.network((await post.postURL).toString());
        videoController.setLooping(true);
      }

      PostWidget postWidget = PostWidget(
        post: post,
        height: 475,
        aspectRatio: goldenRatio,
        playOnInit: true,
        onlyShowBody: false,
        videoController: videoController,
      );

      return postWidget;
    }
  }

  GestureDetector _buildGestureDetector(
      PostListScrollerProvider provider, Future<PostWidget> postWidget) {
    // Returns a GestureDetector that contains a post widget and updates the
    // provider whenever it detects a vertical drag.

    return GestureDetector(
      child: FutureBuilder(
          future: postWidget,
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
      PostListScrollerProvider provider) async {
    // Responsible for determine what post widget to display whenever a vertical
    // drag is detected. If the user swipes down, then both the current and next
    // post widget are shifted up. The previous post widget is replaced with the
    // next un-built post widget, and is positioned to be below current widget.
    // The same logic applies for the user swiping up. Nothing happens if the
    // current post widget is either the first or last post in postList.

    provider.findIndexes();

    if (postListIndex + 1 < widget.postList.length &&
        provider.verticalOffset < -(postVerticalOffset / 4)) {
      postListIndex++;
      provider.swipeUp();
      await _dealWithVideoControllers(await postWidgets[provider.nextIndex],
          await postWidgets[provider.currIndex]);

      postWidgets[provider.prevIndex] = _buildPostWidget(postListIndex + 1);
    } else if (postListIndex - 1 >= 0 &&
        provider.verticalOffset > (postVerticalOffset / 4)) {
      postListIndex--;
      provider.swipeDown();
      await _dealWithVideoControllers(await postWidgets[provider.prevIndex],
          await postWidgets[provider.currIndex]);

      postWidgets[provider.nextIndex] = _buildPostWidget(postListIndex - 1);
    } else {
      provider.moveBack();
      // TODO: When user runs out of posts to watch, request more posts from server

    }
  }

  Future<void> _dealWithVideoControllers(
      PostWidget postWidgetPlay, PostWidget postWidgetPause) async {
    // This function only applies to video posts. Plays a video if it comes
    // into view. Pauses a video if it goes off screen.

    if (postWidgetPlay != null && postWidgetPlay.videoController != null) {
      await postWidgetPlay.videoController.play();
    }
    if (postWidgetPause != null && postWidgetPause.videoController != null) {
      await postWidgetPause.videoController.pause();
      await postWidgetPause.videoController.seekTo(Duration(microseconds: 0));
    }
  }
}
