import '../../models/post.dart';

import '../../globals.dart' as globals;

Future<List<Post>> getFollowingPosts() async {
  var response = await globals.baseAPI
      .get('v1/new_content/${globals.user.uid}/following/');

  if (response["posts"].length == 0) return null;

  return [for (var postJson in response["posts"]) Post.fromJson(postJson)];
}

Future<List<Post>> getRecommendations() async {
  var response = await globals.baseAPI
      .get('v1/new_content/${globals.user.uid}/recommendations/');

  if (response["posts"].length == 0) return null;

  return [for (var postJson in response["posts"]) Post.fromJson(postJson)];
}
