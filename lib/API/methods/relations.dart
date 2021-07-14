import '../baseAPI.dart';

import '../../models/user.dart';
import '../../globals.dart' as globals;

Future<bool> getIfFollowing(User user) async {
  var response = await BaseAPI()
      .get('v1/relationships/${globals.user.uid}/following/${user.uid}/');
  return response['isFollowing'];
}

Future<bool> postStartFollowing(User user) async {
  Map postBody = {'uid': user.uid};
  return await BaseAPI()
      .post('v1/relationships/${globals.user.uid}/following/', postBody);
}

Future<bool> postStopFollowing(User user) async {
  return await BaseAPI()
      .delete('v1/relationships/${globals.user.uid}/following/${user.uid}/');
}

Future<List<User>> getNewFollowers() async {
  Map response = await BaseAPI()
      .get('v1/relationships/${globals.user.uid}/followers/new/');
  return [
    for (var userJson in response["followerList"]) User.fromJson(userJson)
  ];
}

Future<bool> postFollowBack(User user) async {
  Map postBody = {'followBack': true};
  return await BaseAPI().post(
      'v1/relationships/${user.uid}/following/${globals.user.uid}/', postBody);
}

Future<bool> postDontFollowBack(User user) async {
  Map postBody = {'followBack': false};
  return await BaseAPI().post(
      'v1/relationships/${user.uid}/following/${globals.user.uid}/', postBody);
}

Future<bool> postBlockedUser(User user) async {
  Map postBody = {'uid': user.uid};
  return await BaseAPI()
      .post('v1/relationships/${globals.user.uid}/blocked/', postBody);
}

Future<bool> deleteBlockedUser(User user) async {
  return await BaseAPI()
      .delete('v1/relationships/${globals.user.uid}/blocked/${user.uid}/');
}

Future<List<User>> getBlockedUsers() async {
  Map response =
      await BaseAPI().get('v1/relationships/${globals.user.uid}/blocked/');

  List<User> blockedUsers = [];

  for (var userJson in response["blocked"]) {
    blockedUsers.add(User.fromJson(userJson));
  }

  return blockedUsers;
}
