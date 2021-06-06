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
