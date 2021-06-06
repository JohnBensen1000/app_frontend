import 'package:flutter/material.dart';
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

  Map toDict() {
    return {
      'userID': this.userID,
      'username': this.username,
      'uid': this.uid,
    };
  }
}
