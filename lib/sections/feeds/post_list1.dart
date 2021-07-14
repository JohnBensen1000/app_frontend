import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../API/methods/posts.dart';
import '../../API/handle_requests.dart';
import '../../API/methods/relations.dart';
import '../../models/post.dart';

import '../navigation/home_screen.dart';
import '../post/post_view.dart';

import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../API/methods/posts.dart';
import '../../API/handle_requests.dart';
import '../../API/methods/relations.dart';
import '../../models/post.dart';

import '../navigation/home_screen.dart';
import '../post/post_view.dart';

class PostListProvider extends ChangeNotifier {
  List<Post> _postsList;
  int _currentPostIndex;

  PostListProvider({@required List<Post> postsList}) {
    _postsList = postsList;
    _currentPostIndex = 0;
  }

  set currentPostIndex(int newCurrentPostIndex) {
    _currentPostIndex = newCurrentPostIndex;
  }

  void refreshPostsList() {
    notifyListeners();
  }

  void reportPost() {
    notifyListeners();
  }

  void blockCreator() {
    notifyListeners();
  }
}

class PostList extends StatelessWidget {
  PostList({@required this.height, @required this.future});

  final double height;
  final Future future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return ChangeNotifierProvider(
              create: (context) => PostListProvider(postsList: snapshot.data),
              child: Consumer<PostListProvider>(
                  builder: (context, provider, child) {
                List<Post> postsList = provider._postsList;
                int currentIndex = provider._currentPostIndex;

                return PostListPage(
                    prevPostView: _buildPostView(postsList, currentIndex - 1),
                    currentPostView: _buildPostView(postsList, currentIndex),
                    nextPostView: _buildPostView(postsList, currentIndex + 1),
                    height: height);
              }));
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildPostView(List<Post> postList, int index) {
    if (index < 0 || index == postList.length) {
      return null;
    } else {
      return PostView(
        post: postList[index],
        height: .75 * height,
        aspectRatio: globals.goldenRatio,
        postStage: PostStage.fullWidget,
        playOnInit: true,
      );
    }
  }
}

class PostListPage extends StatefulWidget {
  PostListPage({
    @required this.prevPostView,
    @required this.currentPostView,
    @required this.nextPostView,
    @required this.height,
  });

  final PostView prevPostView;
  final PostView currentPostView;
  final PostView nextPostView;
  final double height;

  @override
  _PostListPageState createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  double offset;

  @override
  void initState() {
    super.initState();
    offset = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostListProvider>(builder: (context, provider, child) {
      return GestureDetector(
        child: Container(
          height: widget.height,
          width: double.infinity,
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                  offset: Offset(0, offset - widget.height),
                  child: widget.prevPostView),
              Transform.translate(
                  offset: Offset(0, offset), child: widget.currentPostView),
              Transform.translate(
                  offset: Offset(0, offset + widget.height),
                  child: widget.nextPostView)
            ],
          ),
        ),
        onVerticalDragUpdate: (value) {
          setState(() {
            offset += value.delta.dy;
          });
        },
        onVerticalDragEnd: (value) {
          List<Post> postsList = provider._postsList;
          int currentIndex = provider._currentPostIndex;
          if (currentIndex == postsList.length - 1 && offset < -.25) {}
        },
      );
    });
  }

  void swipeUp() {}
}
