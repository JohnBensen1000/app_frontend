import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:upgrader/upgrader.dart';

import '../globals.dart' as globals;
import '../../sections/global.dart';

import 'account/enter_account.dart';

import '../repositories/account_repository.dart';

class Welcome extends StatefulWidget {
  // Checks to see if the current device is signed in on. If it is, then saves
  // the user data to globals.user and sends the user to the home screen.
  // Otherwise sends the user to WelcomePage().
  Welcome({
    Key key,
  }) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffffffff),
        body: UpgradeAlert(
          child: FutureBuilder(
              future: registerNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return FutureBuilder(
                    future: AccountRepository().getUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        globals.size = globals.SizeConfig(context: context);

                        if (snapshot.hasData) {
                          globals.user = snapshot.data;
                          return Global();
                        } else
                          return LogInScreen();
                      } else
                        return Center(
                          child: Container(
                              child: Image.asset('assets/images/Entropy.jpg')),
                        );
                    },
                  );
                } else
                  return Center(
                    child: Container(
                        child: Image.asset('assets/images/Entropy.jpg')),
                  );
              }),
        ));
  }

  Future<void> registerNotifications() async {
    await Firebase.initializeApp();

    FirebaseMessaging _messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await _messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
}
