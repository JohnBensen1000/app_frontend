import 'package:flutter/material.dart';

import '../API/users.dart';

import '../globals.dart' as globals;

class User {
  String userID;
  String username;
  String uid;
  Color profileColor;

  User({this.userID, this.username, this.uid, this.profileColor});

  User.fromJson(Map userJson) {
    this.userID = userJson['userID'];
    this.username = userJson['username'];
    this.uid = userJson['uid'];
    this.profileColor = globals.colorsMap[userJson['profileColor']];
  }

  User.fromUID(String uid) {
    Future<User> user = getUserFromUID(uid);
  }

  Map toDict() {
    return {
      'userID': this.userID,
      'username': this.username,
      'uid': this.uid,
    };
  }
}
