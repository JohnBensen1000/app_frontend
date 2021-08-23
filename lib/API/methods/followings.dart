import '../baseAPI.dart';

import '../../models/user.dart';
import '../../globals.dart' as globals;

Future<Map> startFollowing(User user) async {
  Map postBody = {'uid': user.uid};
  return await BaseAPI().post('v2/followings/${globals.uid}', postBody);
}

Future<bool> stopFollowing(User user) async {
  var response =
      await BaseAPI().delete('v2/followings/${globals.uid}/${user.uid}');

  return response['deleted'];
}

Future<Map> dontFollowBack(User user) async {
  return await BaseAPI().put('v2/followings/${user.uid}/${globals.uid}', {});
}

Future<bool> getIfFollowing(User user) async {
  var response =
      await BaseAPI().get('v2/followings/${globals.uid}/${user.uid}');
  return response['isFollowing'];
}

Future<List<String>> getFollowings() async {
  var response = await BaseAPI().get('v2/followings/${globals.uid}');

  if (response == null) return null;

  List<String> followingList = [];

  for (Map following in response["followings"])
    followingList.add(following['user']['uid']);

  return followingList;
}
