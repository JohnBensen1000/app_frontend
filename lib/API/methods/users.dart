import '../../models/user.dart';

import '../../globals.dart' as globals;

Future<Map> postNewAccount(Map postBody) async {
  return await globals.baseAPI.post("v2/users", postBody);
}

Future<List<User>> getUsersFromSearchString(String searchString) async {
  Map<String, dynamic> queryParameters = {'contains': searchString};
  if (globals.uid != null) queryParameters['uid'] = globals.uid;
  var response =
      await globals.baseAPI.get("v2/users", queryParameters: queryParameters);

  if (response == null) {
    return null;
  }

  return [
    for (var userJson in response["creatorsList"]) User.fromJson(userJson)
  ];
}

Future<User> getUserFromUID(String uid) async {
  var response = await globals.baseAPI.get('v2/users/$uid');

  if (response == null) return null;

  return User.fromJson(response);
}

Future<bool> deleteAccount() async {
  var response = await globals.baseAPI.delete('v2/users/${globals.uid}');

  return response['deleted'];
}

Future<Map> updateDeviceToken(String deviceToken) async {
  return await globals.baseAPI
      .put('v2/users/${globals.uid}', {'deviceToken': deviceToken});
}

Future<Map> updateColor(String profileColor) async {
  return await globals.baseAPI
      .put('v2/users/${globals.uid}', {'profileColor': profileColor});
}

Future<bool> getIfUserIsUpdated() async {
  var response = await globals.baseAPI.get('v2/users/${globals.uid}/activity');

  if (response == null) return null;
  return response['isUpdated'];
}

Future<Map> updatedThatUserIsUpdated() async {
  return await globals.baseAPI.put('v2/users/${globals.uid}/activity', {});
}

Future<Map> updateUsername(String username) async {
  return await globals.baseAPI
      .put('v2/users/${globals.uid}', {'username': username});
}
