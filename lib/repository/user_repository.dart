import 'dart:collection';

import '../models/user.dart';
import '../API/users.dart';

class UserRepository {
  HashMap users = new HashMap<String, User>();

  Future<User> getUser(String uid) async {
    if (users.containsKey(uid)) return users[uid];

    User user = await getUserFromUID(uid);
    users[uid] = user;

    return user;
  }
}
