import 'dart:core';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../backend_connect.dart';
import 'post_list.dart';
import '../API/new_content.dart';

FirebaseStorage storage = FirebaseStorage.instance;

class FollowingPage extends StatelessWidget {
  // Main widget for the following page. Returns a FutureBuilder() that waits
  // for a list of posts from the server. Once this widget recieves this list,
  // it builds PostListScroller().
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getFollowingPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return PostList(postList: snapshot.data);
          } else {
            return Center(child: Text("Loading...."));
          }
        });
  }
}
