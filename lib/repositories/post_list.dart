import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../globals.dart' as globals;

import 'repository.dart';

class PostListRepository extends Repository<List<Post>> {
  PostListRepository({@required this.function}) {
    refreshPostList();
    _blockedCreatorCallback();
  }

  final Function function;

  int _index;
  List<Post> _postsList;
  bool _hasRecievedList;

  bool get isListNotEmpty => _postsList != null ? _postsList.isNotEmpty : false;
  bool get hasRecievedList => _hasRecievedList;

  Post get previousPost => _index - 1 >= 0 ? _postsList[_index - 1] : null;
  Post get currentPost => _postsList[_index];
  Post get nextPost =>
      _index + 1 < _postsList.length ? _postsList[_index + 1] : null;
  Post get nextNextPost =>
      _index + 2 < _postsList.length ? _postsList[_index + 2] : null;

  void moveUp() {
    if (_index < _postsList.length - 1) _index++;
    if (_index >= _postsList.length - 2) _getNextPostList();
    super.controller.sink.add(_postsList);
  }

  void moveDown() {
    if (_index > 0) _index--;
    super.controller.sink.add(_postsList);
  }

  void removeCurrentPost() {
    _postsList.remove(currentPost);
    if (_index == _postsList.length) _index--;
    if (_index >= _postsList.length - 2) _getNextPostList();

    super.controller.sink.add(_postsList);
  }

  void getNextPostList() => _getNextPostList();

  // resets the post list
  void refreshPostList() async {
    _index = 0;
    _postsList = null;
    _hasRecievedList = false;
    super.controller.sink.add(_postsList);
    var response = await function();

    if (response == null) return null;

    List<Post> newPosts = response;
    _postsList = newPosts;
    _hasRecievedList = true;
    super.controller.sink.add(_postsList);
  }

  // gets a new post list to append to the current post list
  void _getNextPostList() async {
    var response = await function();

    if (response == null) return null;

    List<Post> newPosts = response;
    _postsList += newPosts;
    _hasRecievedList = true;

    super.controller.sink.add(_postsList);
  }

  void _blockedCreatorCallback() {
    globals.blockedRepository.stream.listen((List<User> blockedUsers) {
      if (_postsList == null || _postsList.length == 0) return;

      for (User user in blockedUsers) {
        for (int i = _postsList.length - 1; i >= 0; i--) {
          if (_postsList[i].creator.uid == user.uid) {
            _postsList.removeAt(i);
            _index--;
          }
        }

        if (_index < 0)
          _index = 0;
        else if (_index >= _postsList.length - 1)
          _index = _postsList.length - 1;
        else
          _index = _index + 1;
      }
      if (_index >= _postsList.length - 2) _getNextPostList();
      super.controller.sink.add(_postsList);
    });
  }
}
