import '../../models/post.dart';

import '../../globals.dart' as globals;

Future<List<Post>> getFollowingPosts() async {
  var response = await globals.baseAPI
      .get('v1/new_content/${globals.user.uid}/following/');

  return [for (var postJson in response["posts"]) Post.fromJson(postJson)];
}

Future<List<Post>> getRecommendations() async {
  var response = await globals.baseAPI
      .get('v1/new_content/${globals.user.uid}/recommendations/');

  return [for (var postJson in response["posts"]) Post.fromJson(postJson)];
}
