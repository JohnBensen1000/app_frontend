import 'dart:core';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../API/methods/feeds.dart';
import '../../globals.dart' as globals;

import 'post_list.dart';

FirebaseStorage storage = FirebaseStorage.instance;

class FollowingPage extends StatelessWidget {
  // Main widget for the following page. Returns a FutureBuilder() that waits
  // for a list of posts from the server. Once this widget recieves this list,
  // it builds PostListScroller().

  FollowingPage({@required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: .0118 * globals.size.height),
      child: PostList(
        function: getFollowingPosts,
        height: height,
      ),
    );
  }
}
