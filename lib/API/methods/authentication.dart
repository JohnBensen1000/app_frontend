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
