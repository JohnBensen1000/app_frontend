import 'dart:io';

import '../../models/profile.dart';
import '../../models/post.dart';
import '../../models/user.dart';
import '../../models/comment.dart';

import '../../globals.dart' as globals;
import '../baseAPI.dart';

Future<Map> reportPost(Post post) async {
  return await globals.baseAPI
      .post('v2/reports/${globals.uid}/post', {"postID": post.postID});
}

Future<Map> reportProfile(User user) async {
  return await globals.baseAPI
      .post('v2/reports/${globals.uid}/profile', {"uid": user.uid});
}

Future<Map> reportComment(Post post, Comment comment) async {
  return await BaseAPI().post(
      'v2/reports/${globals.uid}/${post.postID}/comment', comment.toJson());
}
