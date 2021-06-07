import 'dart:core';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../API/new_content.dart';

import 'post_list.dart';

FirebaseStorage storage = FirebaseStorage.instance;

class DiscoverPage extends StatelessWidget {
  // Main widget for the following page. Returns a FutureBuilder() that waits
  // for a list of posts from the server. Once this widget recieves this list,
  // it builds PostListScroller().
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getRecommendations(),
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
