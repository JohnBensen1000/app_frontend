import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter/repositories/repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../API/methods/users.dart';
import '../models/user.dart';

import '../../globals.dart' as globals;
import '../../API/methods/users.dart';

import 'repository.dart';

firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

class AccountRepository extends Repository<String> {
  String uidKey = 'username';

  Future<SharedPreferences> prefsFuture = SharedPreferences.getInstance();

  Future<bool> createAccount(String uid, String userId, String username) async {
    print(" [DEBUG] creating account");

    Map newAccount = {
      'uid': uid,
      'userID': userId,
      'username': username,
      'email': "",
    };
    print(" [DEBUG] Posting new account");
    var response = await postNewAccount(newAccount);
    print(" [DEBUG] response recieved: $response");
    if (response != null) {
      print(" [DEBUG] response is not null");
      globals.isNewUser = false;

      globals.uid = uid;

      await FirebaseMessaging.instance.requestPermission();
      await updateDeviceToken(await FirebaseMessaging.instance.getToken());

      print(" [DEBUG] updated device token");

      await globals.accountRepository.setUid(uid: uid);
      return true;
    }
    return false;
  }

  Future<bool> signIn(String uid) async {
    if ((await FirebaseMessaging.instance.getNotificationSettings())
            .authorizationStatus !=
        AuthorizationStatus.authorized)
      await FirebaseMessaging.instance.requestPermission();

    globals.uid = uid;

    updateDeviceToken(await FirebaseMessaging.instance.getToken());

    await globals.accountRepository.setUid(uid: uid);

    return true;
  }

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
