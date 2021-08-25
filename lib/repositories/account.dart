import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:test_flutter/repositories/repository.dart';

import '../API/methods/users.dart';
import '../models/user.dart';

class AccountRepository extends Repository<String> {
  String uidKey = 'username';

  Future<SharedPreferences> prefsFuture = SharedPreferences.getInstance();

  Future<void> setUid({String uid}) async {
    SharedPreferences prefs = await prefsFuture;

    prefs.setString(uidKey, uid);
  }

  Future<User> getUser() async {
    SharedPreferences prefs = await prefsFuture;

    String uid = prefs.getString(uidKey);

    if (uid == null)
      return null;
    else {
      try {
        return await getUserFromUID(uid);
      } catch (e) {
        return null;
      }
    }
  }

  Future<void> removeUid() async {
    SharedPreferences prefs = await prefsFuture;

    prefs.remove(uidKey);

    super.controller.sink.add(null);
  }
}
