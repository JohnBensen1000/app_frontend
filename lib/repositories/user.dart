import 'dart:async';

import "../../models/user.dart";
import "../../API/methods/users.dart";

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
}
