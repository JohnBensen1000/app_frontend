import '../models/profile.dart';
import '../models/post.dart';
import '../models/user.dart';

import '../globals.dart' as globals;
import 'baseAPI.dart';

Future<bool> uploadPost(bool isImage, bool isPrivate, String filePath) async {
  Map postBody = {'isImage': isImage, 'isPrivate': isPrivate};
  return await BaseAPI()
      .postFile("v1/posts/${globals.user.uid}/", postBody, filePath);
}

Future<Post> getProfile(User user) async {
  var response = await BaseAPI().get('v1/posts/${user.uid}/profile/');
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

Future<bool> uploadProfilePic(bool isImage, String filePath) async {
  Map postBody = {'isImage': isImage};
  return await BaseAPI()
      .postFile("v1/posts/${globals.user.uid}/profile/", postBody, filePath);
}

Future<List<Post>> getUsersPosts(User user) async {
  var response = await BaseAPI().get('v1/posts/${user.uid}/');
  List<Post> postList = [
    for (var postJson in response["posts"]) Post.fromJson(postJson)
  ];
  return postList;
}

Future<bool> recordWatched(String postID, int userRating) async {
  Map postJson = {'uid': globals.user.uid, 'userRating': userRating};
  return await BaseAPI().post('v1/posts/$postID/watched_list/', postJson);
}
