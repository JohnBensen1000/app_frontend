import 'dart:io';

import '../../models/profile.dart';
import '../../models/post.dart';
import '../../models/user.dart';

import '../../globals.dart' as globals;
import '../baseAPI.dart';

Future<bool> uploadPost(bool isImage, bool isPrivate, File file) async {
  String downloadURL = await uploadFile(file, globals.user.uid, isImage);

  Map postBody = {
    'isImage': isImage,
    'isPrivate': isPrivate,
    'downloadURL': downloadURL
  };
  return await globals.baseAPI.post("v1/posts/${globals.user.uid}/", postBody);
}

Future<Post> getProfile(User user) async {
  var response = await globals.baseAPI.get('v1/posts/${user.uid}/profile/');
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

Future<bool> uploadProfilePic(bool isImage, File file) async {
  String downloadURL = await uploadFile(file, globals.user.uid, isImage);

  Map postBody = {'isImage': isImage, 'downloadURL': downloadURL};
  return await globals.baseAPI
      .post("v1/posts/${globals.user.uid}/profile/", postBody);
}

Future<List<Post>> getUsersPosts(User user) async {
  var response = await globals.baseAPI.get('v1/posts/${user.uid}/');
  List<Post> postList = [
    for (var postJson in response["posts"]) Post.fromJson(postJson)
  ];
  return postList;
}

Future<bool> postRecordWatched(String postID, int userRating) async {
  Map postJson = {'uid': globals.user.uid, 'userRating': userRating};
  return await globals.baseAPI.post('v1/posts/$postID/watched_list/', postJson);
}
