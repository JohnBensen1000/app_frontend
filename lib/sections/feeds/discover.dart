import 'dart:core';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:test_flutter/API/handle_requests.dart';

import '../../API/methods/new_content.dart';

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
      padding: EdgeInsets.only(top: 10),
      child: PostList(
        function: getRecommendations,
        // future: handleRequest(context, getRecommendations()),
        height: height,
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return FutureBuilder(
  //       future: handleRequest(context, getRecommendations()),
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.done &&
  //             snapshot.hasData) {
  //           return Container(
  //             padding: EdgeInsets.only(top: 10),
  //             child: PostList(
  //               postList: snapshot.data,
  //               height: height,
  //             ),
  //           );
  //         } else {
  //           return Center(child: Text("Loading...."));
  //         }
  //       });
  // }
}
