import 'dart:async';
import 'dart:io';

import 'package:test_flutter/API/methods/posts.dart';

import '../../models/user.dart';
import '../../models/post.dart';
import '../../globals.dart' as globals;

class ProfileRepository {
  Map<String, Post> _profilePostsMap = new Map<String, Post>();
  final _controller = StreamController<Post>.broadcast();

  ProfileRepository() {
    _getInitialValues();
  }

  Stream<Post> get stream => _controller.stream;

  Future<Post> get(User user) async {
    if (!_profilePostsMap.containsKey(user.uid))
      _profilePostsMap[user.uid] = await getProfile(user);

    return _profilePostsMap[user.uid];
  }

  Future<Map> update(bool isImage, File file) async {
    Map response = await uploadProfilePic(isImage, file);

    if (response.containsKey("denied")) return response;

    _profilePostsMap[globals.user.uid] = Post(
        creator: globals.user,
        postID: 'profile',
        isImage: response['isImage'],
        downloadURL: response['downloadURL']);

    _controller.sink.add(_profilePostsMap[globals.user.uid]);

    return {};
  }

  void dispose() {
    _controller.close();
  }

  Future<void> _getInitialValues() async {
    _profilePostsMap[globals.user.uid] = await getProfile(globals.user);
    _controller.sink.add(_profilePostsMap[globals.user.uid]);
  }
}
