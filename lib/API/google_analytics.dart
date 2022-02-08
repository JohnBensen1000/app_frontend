import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../globals.dart' as globals;

class GoogleAnalyticsAPI {
  Future<String> firebaseTokenFuture = FirebaseMessaging.instance.getToken();

  Future<void> logEvent(String name, [Map<String, Object> parameters]) async {
    print(" [DEBUG] Event $name, Is new user: ${globals.isNewUser}");

    if (globals.isNewUser) {
      name = "new_user_" + name;
    }

    FirebaseAnalytics().logEvent(name: name, parameters: parameters);
  }

  Future<void> logCreateAccountPageVisited() async {
    await logEvent("create_account_page_visited");
  }

  Future<void> logCreatedAccount() async {
    await logEvent("created_account");
  }

  Future<void> logAgreedToRules() async {
    await logEvent("agreed_to_rules");
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

  Future<void> logChoseInterests() async {
    await logEvent("chose_interests");
  }
}
