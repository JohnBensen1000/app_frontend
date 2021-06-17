import '../../models/user.dart';

import '../../globals.dart' as globals;
import '../baseAPI.dart';

Future<Map> postSignIn(String uid) async {
  return await BaseAPI().post("v1/authentication/$uid/signedInStatus/",
      {'signIn': true, 'deviceToken': ""});
}

Future<Map> postSignOut() async {
  return await BaseAPI().post(
      "v1/authentication/${globals.user.uid}/signedInStatus/",
      {'signIn': false});
}

// Future<Map> getIfDeviceSignedInOn() async {
//   String deviceToken = await FirebaseMessaging.instance.getToken();
//   return await BaseAPI()
//       .get('v1/authentication/deviceSignedInOn/?deviceToken=$deviceToken');
// }
