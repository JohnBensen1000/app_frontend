import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../globals.dart' as globals;

class GoogleAnalyticsAPI {
  Future<String> firebaseTokenFuture = FirebaseMessaging.instance.getToken();

  Future<void> logEvent(String name, [Map<String, Object> parameters]) async {
    name = "v1_5_3_new_user_" + name;
    print(" [DEBUG] Logging Event: $name");

    FirebaseAnalytics().logEvent(name: name, parameters: parameters);
  }

  Future<void> logCreatedFirebaseAccount() async {
    await logEvent("created_firebase_account");
  }

  Future<void> logCreatedAccount() async {
    await logEvent("created_account");
  }

  Future<void> logTakeProfilePageVisited() async {
    await logEvent("take_profile_page_visited");
  }

  Future<void> logPickColorPageVisited() async {
    await logEvent("pick_color_page_visted");
  }

  Future<void> logPickedColor() async {
    await logEvent("picked_color");
  }
}
