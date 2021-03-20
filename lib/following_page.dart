import 'package:flutter/material.dart';
import 'dart:convert';
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
    String newUrl = backendConnection.url + "posts/$userID/following/new/";
    var response = await http.get(newUrl);
    return json.decode(response.body)["postsList"];
  }
}

class PostListScrollerProvider extends ChangeNotifier {
  // Keeps track of the vertical offset of the posts in PostListScroller. Allows
  // for smooth sliding up and down of the posts.

  double _verticalOffset = 0;

  double get verticalOffset {
    return _verticalOffset;
  }

  set verticalOffset(double newVerticalOffset) {
    _verticalOffset = newVerticalOffset;
    notifyListeners();
  }

  void addToVerticalOffset(double changeInVerticaloffset) {
    _verticalOffset += changeInVerticaloffset;
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
  List<double> offsets;

  @override
  Widget build(BuildContext context) {
    postWidgets = [
      buildPostWidget(postListIndex - 1),
      buildPostWidget(postListIndex),
      buildPostWidget(postListIndex + 1)
    ];

    offsets = [-postVerticalOffset, 0, postVerticalOffset];

    return ChangeNotifierProvider(
      create: (context) => PostListScrollerProvider(),
      child: Consumer<PostListScrollerProvider>(
          builder: (context, provider, child) {
        return Stack(children: [
          Transform.translate(
            offset: Offset(0, provider.verticalOffset + offsets[0]),
            child: buildGestureDetector(provider, postWidgets[0]),
          ),
          Transform.translate(
            offset: Offset(0, provider.verticalOffset + offsets[1]),
            child: buildGestureDetector(provider, postWidgets[1]),
          ),
          Transform.translate(
            offset: Offset(0, provider.verticalOffset + offsets[2]),
            child: buildGestureDetector(provider, postWidgets[2]),
          ),
        ]);
      }),
    );
  }

  Future<PostWidget> buildPostWidget(int index) async {
    // Looks to see if index is a valid index of widget.postList. If it is,
    // builds and returns a PostWidget() that corresponds to the correct
    // item of widget.postList.

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
      if (post.isImage == false) {
        videoController.pause();
      }
      return postWidget;
    }
  }

  GestureDetector buildGestureDetector(
      PostListScrollerProvider provider, Future<PostWidget> postWidget) {
    // Returns a GestureDetector that contains a post widget and updates the
    // provider whenever it detects a vertical drag.

    GestureDetector gestureDetector = GestureDetector(
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
          provider.addToVerticalOffset(value.delta.dy),
      onVerticalDragEnd: (_) {
        handleVerticalDragStop(provider.verticalOffset);
        provider.verticalOffset = 0;
      },
    );
    return gestureDetector;
  }

  void handleVerticalDragStop(double verticalOffset) {
    // Responsible for determine what post widget to display whenever a vertical
    // drag is detected. If the user swipes down, then both the current and next
    // post widget are shifted up. The previous post widget is replaced with the
    // next un-built post widget, and is positioned to be below current widget.
    // The same logic applies for the user swiping up. Nothing happens if the
    // current post widget is either the first or last post in postList.

    int prevIndex = offsets.indexOf(-postVerticalOffset);
    int currIndex = offsets.indexOf(0);
    int nextIndex = offsets.indexOf(postVerticalOffset);

    if (verticalOffset < -(postVerticalOffset / 4)) {
      // DOWN
      if (postListIndex + 1 < widget.postList.length) {
        postListIndex++;
        offsets[currIndex] = -postVerticalOffset;
        offsets[nextIndex] = 0;

        postWidgets[prevIndex] = buildPostWidget(postListIndex + 1);
        offsets[prevIndex] = postVerticalOffset;
      } else {
        // TODO: When user runs out of posts to watch, request more posts from server
      }
    } else if (verticalOffset > (postVerticalOffset / 4)) {
      // UP
      if (postListIndex - 1 >= 0) {
        postListIndex--;
        offsets[prevIndex] = 0;
        offsets[currIndex] = postVerticalOffset;

        postWidgets[nextIndex] = buildPostWidget(postListIndex - 1);
        offsets[nextIndex] = -postVerticalOffset;
      } else {
        // TODO: When user runs out of posts to watch, request more posts from server
      }
    }
  }
}
