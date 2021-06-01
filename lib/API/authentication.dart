import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/user.dart';

import '../globals.dart' as globals;
import 'baseAPI.dart';

Future<Map> signIn(String uid) async {
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  return await BaseAPI().post("v1/authentication/$uid/signedInStatus/",
      {'signIn': true, 'deviceToken': await firebaseMessaging.getToken()});
}

Future<Map> signOut(String deviceToken) async {
  return await BaseAPI().post(
      "v1/authentication/${globals.user.uid}/signedInStatus/",
      {'signIn': false});
}
