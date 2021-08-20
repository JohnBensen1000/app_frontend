import 'dart:async';
import 'dart:io';

import 'package:test_flutter/API/methods/posts.dart';

import '../../models/user.dart';
import '../../models/post.dart';
import '../../globals.dart' as globals;

import 'repository.dart';

class ProfileRepository extends Repository<Post> {
  Map<String, Post> _profilePostsMap = new Map<String, Post>();

  bool contains(User user) => _profilePostsMap.containsKey(user.uid);
  Post get(User user) => _profilePostsMap.containsKey(user.uid)
      ? _profilePostsMap[user.uid]
      : null;

  Future<Post> getFuture(User user) async {
    if (!_profilePostsMap.containsKey(user.uid))
      _profilePostsMap[user.uid] = await getProfile(user);

    return _profilePostsMap[user.uid];
  }

  Future<Map> update(bool isImage, File file) async {
    Map response = await uploadProfilePic(isImage, file);

    if (response.containsKey("denied")) return response;

    User user = await globals.userRepository.get(globals.uid);

    _profilePostsMap[globals.uid] = Post(
        creator: user,
        postID: 'profile',
        isImage: response['isImage'],
        downloadURL: response['downloadURL']);

    super.controller.sink.add(_profilePostsMap[globals.uid]);

    return {};
  }
}
