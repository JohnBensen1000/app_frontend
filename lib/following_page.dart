import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

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

class PostListScroller extends StatefulWidget {
  PostListScroller({@required this.postList});

  final List<dynamic> postList;

  @override
  _PostListScrollerState createState() => _PostListScrollerState();
}

class _PostListScrollerState extends State<PostListScroller> {
  int postListIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: PostWidget(
          post: Post.fromJson(widget.postList[postListIndex]),
          height: 475,
          aspectRatio: goldenRatio,
          playOnInit: true,
          onlyShowBody: false,
        ),
      ),
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity < 0) {
          if (postListIndex < widget.postList.length - 1) {
            postListIndex += 1;
            setState(() {});
          }
        } else if (details.primaryVelocity > 0) {
          if (postListIndex > 0) {
            postListIndex -= 1;
            setState(() {});
          }
        }
      },
    );
  }
}
