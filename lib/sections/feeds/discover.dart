import 'dart:core';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../globals.dart' as globals;

import 'post_list.dart';

FirebaseStorage storage = FirebaseStorage.instance;

class DiscoverPage extends StatelessWidget {
  // Main widget for the following page. Returns a FutureBuilder() that waits
  // for a list of posts from the server. Once this widget recieves this list,
  // it builds PostListScroller().

  DiscoverPage({@required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: .0118 * globals.size.height),
      child: PostList(
          repository: globals.recommendationPostsRepository,
          height: height,
          emptyListText: "We ran out of posts to recommend you!"),
    );
  }
}
