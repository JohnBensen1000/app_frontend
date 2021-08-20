import 'dart:async';

import 'package:test_flutter/sections/personalization/change_username.dart';

import "../../models/user.dart";
import "../../API/methods/users.dart";
import '../../globals.dart' as globals;

import 'repository.dart';

class UserRepository extends Repository<User> {
  Map<String, Future<User>> _users = {};

  Future<User> get(String uid) async {
    if (!_users.containsKey(uid)) {
      _users[uid] = getUserFromUID(uid);
    }
    return await _users[uid];
  }

  Future<void> changeColor(String colorCode) async {
    Map response = await updateColor(colorCode);
    _users[globals.uid] = _getUserFromJson(response);
    super.controller.sink.add(await _users[globals.uid]);
  }

  Future<void> changeUsername(String newUsername) async {
    Map response = await updateUsername(newUsername);
    _users[globals.uid] = _getUserFromJson(response);
    super.controller.sink.add(await _users[globals.uid]);
  }

  Future<User> _getUserFromJson(Map response) async {
    return User.fromJson(response);
  }
}
