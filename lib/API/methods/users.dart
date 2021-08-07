import '../../models/user.dart';

import '../../globals.dart' as globals;

Future<Map> createNewAccount(Map postBody) async {
  return await globals.baseAPI.post("v2/users", postBody);
}

Future<List<User>> getUsersFromSearchString(String searchString) async {
  Map<String, dynamic> queryParameters = {'contains': searchString};
  if (globals.user != null) queryParameters['uid'] = globals.user.uid;
  var response =
      await globals.baseAPI.get("v2/users", queryParameters: queryParameters);

  return [
    for (var userJson in response["creatorsList"]) User.fromJson(userJson)
  ];
}

Future<User> getUserFromUID(String uid) async {
  var response = await globals.baseAPI.get('v2/users/$uid');

  return User.fromJson(response);
}

Future<bool> deleteAccount() async {
  var response = await globals.baseAPI.delete('v2/users/${globals.user.uid}');

  return response['deleted'];
}

Future<Map> updateDeviceToken(String deviceToken) async {
  return await globals.baseAPI
      .put('v2/users/${globals.user.uid}', {'deviceToken': deviceToken});
}

Future<Map> updateColor(String profileColor) async {
  return await globals.baseAPI
      .put('v2/users/${globals.user.uid}', {'profileColor': profileColor});
}

Future<bool> getIfUserIsUpdated() async {
  var response =
      await globals.baseAPI.get('v2/users/${globals.user.uid}/activity');

  return response['isUpdated'];
}

Future<Map> updatedThatUserIsUpdated() async {
  return await globals.baseAPI.put('v2/users/${globals.user.uid}/activity', {});
}

Future<Map> changeUsername(String username) async {
  return await globals.baseAPI
      .put('v2/users/${globals.user.uid}', {'username': username});
}
