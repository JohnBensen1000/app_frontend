import 'dart:io';

import '../../models/profile.dart';
import '../../models/post.dart';
import '../../models/user.dart';

import '../../globals.dart' as globals;
import '../baseAPI.dart';

Future<Map> postNewPost(
    bool isImage, bool isPrivate, File file, String caption) async {
  String downloadURL = await uploadFile(file, globals.user.uid, isImage);

  Map postBody = {
    'isImage': isImage,
    'isPrivate': isPrivate,
    'downloadURL': downloadURL,
    'caption': caption,
  };

  return await globals.baseAPI.post("v2/posts/${globals.user.uid}", postBody);
}

Future<List<Post>> getUsersPosts(User user) async {
  var response = await globals.baseAPI.get('v2/posts/${user.uid}');
  List<Post> postList = [
    for (var postJson in response["posts"]) Post.fromJson(postJson)
  ];
  return postList;
}

Future<Map> uploadProfilePic(bool isImage, File file) async {
  String downloadURL = await uploadFile(file, globals.user.uid, isImage);

  Map postBody = {'isImage': isImage, 'downloadURL': downloadURL};
  return await globals.baseAPI
      .post("v2/posts/${globals.user.uid}/profile", postBody);
}

Future<Post> getProfile(User user) async {
  var response = await globals.baseAPI.get('v2/posts/${user.uid}/profile');
  Profile profile = Profile.fromJson(response);

  if (profile.exists)
    return Post(
        creator: user,
        postID: 'profile',
        isImage: profile.isImage,
        downloadURL: profile.downloadURL);
  else
    return null;
}

Future<Post> getPostFromPostID(User user, Post post) async {
  var response =
      await globals.baseAPI.get('v2/posts/${user.uid}/${post.postID}');

  return Post.fromJson(response);
}

Future<bool> deletePost(Post post) async {
  var response = await globals.baseAPI
      .delete('v2/posts/${globals.user.uid}/${post.postID}');

  return response['deleted'];
}
