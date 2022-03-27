import 'package:flutter/material.dart';
import 'dart:io';

import '../models/post.dart';
import '../models/user.dart';
import '../API/methods/posts.dart';
import '../globals.dart' as globals;

import 'repository.dart';

class UsersPostsRepository extends Repository<List<Post>> {
  UsersPostsRepository() {
    _geUsersPosts();
  }

  List<Post> get usersPosts => _usersPosts;

  List<Post> _usersPosts;

  Future<void> _geUsersPosts() async {
    _usersPosts = await getUsersPosts(globals.uid);
    super.controller.sink.add(_usersPosts);
  }

  Future<void> deletePostFromRepository(Post post) async {
    await deletePost(post);
    _usersPosts.removeWhere((_post) => _post.postID == post.postID);
    super.controller.sink.add(_usersPosts);
  }

  Future<Map> uploadNewPost(
      bool isImage, bool isPrivate, File file, String caption) async {
    Map response = await postNewPost(isImage, isPrivate, file, caption);

    if (response != null && !response.containsKey("denied")) {
      Post newPost = Post.fromJson(response);
      _usersPosts = [newPost] + _usersPosts;
      super.controller.sink.add(_usersPosts);
    }

    return response;
  }
}
