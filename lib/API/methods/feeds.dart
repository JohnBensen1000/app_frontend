import '../../models/post.dart';

import '../../globals.dart' as globals;

Future<List<Post>> getFollowingPosts() async {
  var response = await globals.baseAPI
      .get('v2/feeds/following', queryParameters: {'uid': globals.uid});

  if (response["posts"].length == 0) return null;

  return [for (var postJson in response["posts"]) Post.fromJson(postJson)];
}

Future<List<Post>> getRecommendations() async {
  var response = await globals.baseAPI
      .get('v2/feeds/recommendations', queryParameters: {'uid': globals.uid});

  if (response == null || response["posts"].length == 0) return null;

  return [for (var postJson in response["posts"]) Post.fromJson(postJson)];
}
