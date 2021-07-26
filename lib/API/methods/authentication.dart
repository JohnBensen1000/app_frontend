import '../../globals.dart' as globals;
import '../baseAPI.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;

Future<Map> postSignIn(String uid) async {
  // AuthorizationStatus authStatus =
  //     (await messaging.getNotificationSettings()).authorizationStatus;

  // String deviceToken = (authStatus == AuthorizationStatus.authorized)
  //     ? await messaging.getToken()
  //     : null;

  String deviceToken = await messaging.getToken();

  return await BaseAPI().post("v1/authentication/$uid/signedInStatus/",
      {'signIn': true, 'deviceToken': deviceToken});
}

Future<Map> postSignOut() async {
  return await BaseAPI().post(
      "v1/authentication/${globals.user.uid}/signedInStatus/",
      {'signIn': false});
}
