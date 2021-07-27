import '../../models/user.dart';

import '../../globals.dart' as globals;

Future<Map> createNewAccount(Map postBody) async {
  return await globals.baseAPI.post("v2/users", postBody);
}

Future<bool> checkIfUserIdTaken(String userID) async {
  var response = await globals.baseAPI
      .get('v2/users', queryParameters: {'contains': userID});

  return response["creatorsList"].length > 0;
}

Future<List<User>> getUsersFromSearchString(String searchString) async {
  var response = await globals.baseAPI.get("v2/users",
      queryParameters: {'contains': searchString, 'uid': globals.user.uid});

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
