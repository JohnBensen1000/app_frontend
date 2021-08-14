import 'dart:async';

import 'package:test_flutter/sections/personalization/change_username.dart';

import "../../models/user.dart";
import "../../API/methods/users.dart";
import '../../globals.dart' as globals;

import 'repository.dart';

class UserRepository extends Repository<User> {
  Map<String, User> _users = new Map<String, User>();

  Future<User> get(String uid) async {
    if (!_users.containsKey(uid)) {
      var response = await getUserFromUID(uid);
      if (response == null) return null;
      _users[uid] = response;
    }
    return _users[uid];
  }

  Future<void> changeColor(String colorCode) async {
    Map response = await updateColor(colorCode);
    _users[globals.user.uid] = User.fromJson(response);
    super.controller.sink.add(_users[globals.user.uid]);
  }

  Future<void> changeUsername(String newUsername) async {
    Map response = await updateUsername(newUsername);
    _users[globals.user.uid] = User.fromJson(response);
    super.controller.sink.add(_users[globals.user.uid]);
  }
}
