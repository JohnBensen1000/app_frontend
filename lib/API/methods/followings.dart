import '../baseAPI.dart';

import '../../models/user.dart';
import '../../globals.dart' as globals;

Future<Map> startFollowing(User user) async {
  Map postBody = {'uid': user.uid};
  return await BaseAPI().post('v2/followings/${globals.user.uid}', postBody);
}

Future<bool> stopFollowing(User user) async {
  var response =
      await BaseAPI().delete('v2/followings/${globals.user.uid}/${user.uid}');

  return response['deleted'];
}

Future<Map> dontFollowBack(User user) async {
  return await BaseAPI()
      .put('v1/followings/${user.uid}/${globals.user.uid}', {});
}

Future<bool> getIfFollowing(User user) async {
  var response =
      await BaseAPI().get('v2/followings/${globals.user.uid}/${user.uid}');
  return response['isFollowing'];
}
