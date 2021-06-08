import 'dart:collection';

import '../API/users.dart';
import '../models/user.dart';

class UserRepository {
  HashMap users = new HashMap<String, User>();

  Future<User> getUser(String uid, bool saveInMemory) async {
    User user =
        (users.containsKey(uid)) ? users[uid] : await getUserFromUID(uid);

    if (saveInMemory) users[uid] = user;

    return user;
  }
}
