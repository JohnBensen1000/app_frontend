import 'package:shared_preferences/shared_preferences.dart';

import '../API/methods/users.dart';
import '../models/user.dart';

class AccountRepository {
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
  }
}
