import '../baseAPI.dart';

import '../../models/user.dart';
import '../../globals.dart' as globals;

Future<Map> blockUser(User user) async {
  Map postBody = {'uid': user.uid};
  return await BaseAPI().post('v2/blocked/${globals.user.uid}', postBody);
}

Future<List<User>> getBlockedUsers() async {
  Map response = await BaseAPI().get('v2/blocked/${globals.user.uid}');

  List<User> blockedUsers = [];

  for (var userJson in response["blocked"]) {
    blockedUsers.add(User.fromJson(userJson));
  }

  return blockedUsers;
}

Future<bool> unblockUser(User user) async {
  var response =
      await BaseAPI().delete('v2/blocked/${globals.user.uid}/${user.uid}');

  return response['deleted'];
}
