import '../../models/user.dart';

import '../../globals.dart' as globals;

Future<Map> postNewAccount(Map postBody) async {
  return await globals.baseAPI.post("v1/users/new/", postBody);
}

Future<List<User>> getUsersFromSearchString(String searchString) async {
  var response = await globals.baseAPI
      .get("v1/users/", queryParameters: {'contains': searchString});

  return [
    for (var userJson in response["creatorsList"]) User.fromJson(userJson)
  ];
}

Future<bool> postNewColor(String profileColor) async {
  Map<String, String> postBody = {'profileColor': profileColor};

  return await globals.baseAPI.post('v1/users/${globals.user.uid}/', postBody);
}

Future<User> getUserFromUID(String uid) async {
  var response = await globals.baseAPI.get('v1/users/$uid/');

  return User.fromJson(response['user']);
}

Future<List<String>> getPreferenceFields() async {
  var response = await globals.baseAPI.get('v1/users/preferences/');

  return [for (var field in response['fields']) field.toString()];
}

Future<bool> postUserPreferences(List<String> updatePreferences) async {
  Map<String, List<String>> postBody = {'preferences': updatePreferences};

  return await globals.baseAPI
      .post('v1/users/${globals.user.uid}/preferences/', postBody);
}

Future<bool> deleteAccount() async {
  return await globals.baseAPI.delete('v1/users/${globals.user.uid}/');
}
