import 'baseAPI.dart';

import '../models/user.dart';
import '../globals.dart' as globals;

Future<bool> getIfFollowing(User user) async {
  var response = await BaseAPI()
      .get('v1/relationships/${globals.user.uid}/following/${user.uid}/');
  return response['isFollowing'];
}

Future<bool> startFollowing(User user) async {
  Map postBody = {'uid': user.uid};
  return await BaseAPI()
      .post('v1/relationships/${globals.user.uid}/following/', postBody);
}

Future<bool> stopFollowing(User user) async {
  return await BaseAPI()
      .delete('v1/relationships/${globals.user.uid}/following/${user.uid}/');
}

Future<List<User>> getNewFollowers() async {
  Map response = await BaseAPI()
      .get('v1/relationships/${globals.user.uid}/followers/new/');
  List<User> userList = [
    for (var userJson in response["followerList"]) User.fromJson(userJson)
  ];
  return userList;
}

Future<bool> followBack(User user) async {
  Map postBody = {'followBack': true};
  return await BaseAPI().post(
      'v1/relationships/${user.uid}/following/${globals.user.uid}/', postBody);
}

Future<bool> dontFollowBack(User user) async {
  Map postBody = {'followBack': false};
  return await BaseAPI().post(
      'v1/relationships/${user.uid}/following/${globals.user.uid}/', postBody);
}
