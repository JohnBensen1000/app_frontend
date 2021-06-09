import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/user.dart';

import '../globals.dart' as globals;
import 'baseAPI.dart';

Future<Map> createAccount(Map postBody) async {
  return await BaseAPI().post("v1/users/new/", postBody);
}

Future<List<User>> searchUsers(String searchString) async {
  var response = await BaseAPI().get("v1/users/?contains=$searchString");

  List<User> creatorsList = [
    for (var userJson in response["creatorsList"]) User.fromJson(userJson)
  ];

  return creatorsList;
}

Future<bool> updateColor(String profileColor) async {
  Map<String, String> postBody = {'profileColor': profileColor};

  return await BaseAPI().post('v1/users/${globals.user.uid}/', postBody);
}

Future<User> getUserFromUID(String uid) async {
  var response = await BaseAPI().get('v1/users/$uid/');

  return User.fromJson(response['user']);
}

Future<List<String>> getPreferenceFields() async {
  var response = await BaseAPI().get('v1/users/preferences/');

  return [for (var field in response['fields']) field.toString()];
}

Future<bool> updateUserPreferences(List<String> updatePreferences) async {
  Map<String, List<String>> postBody = {'preferences': updatePreferences};

  return await BaseAPI()
      .post('v1/users/${globals.user.uid}/preferences/', postBody);
}
