import '../models/post.dart';

import '../globals.dart' as globals;
import 'baseAPI.dart';

Future<List<Post>> getFollowingPosts() async {
  var response =
      await BaseAPI().get('v1/new_content/${globals.user.uid}/following/');

  List<Post> postList = [
    for (var postJson in response["posts"]) Post.fromJson(postJson)
  ];
  return postList;
}

Future<List<Post>> getRecommendations() async {
  var response = await BaseAPI()
      .get('v1/new_content/${globals.user.uid}/recommendations/');

  List<Post> postList = [
    for (var postJson in response["posts"]) Post.fromJson(postJson)
  ];
  return postList;
}
