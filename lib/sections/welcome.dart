import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../globals.dart' as globals;

import 'home/home_page.dart';

import 'account/enter_account.dart';

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
      body: FutureBuilder(
          future: registerNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return FutureBuilder(
                  future: globals.accountRepository.getUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      globals.size = globals.SizeConfig(context: context);

                      if (snapshot.hasData) {
                        globals.uid = snapshot.data.uid;
                        return HomePage();
                      } else {
                        return Center(
                          child: Container(
                            height: .4 * MediaQuery.of(context).size.height,
                            width: .4 * MediaQuery.of(context).size.height,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: const AssetImage(
                                      'assets/images/Entropy.PNG'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    } else {
                      return Container();
                    }
                  });
            } else {
              return Center(
                  child: Container(
                      height: .4 * MediaQuery.of(context).size.height,
                      width: .4 * MediaQuery.of(context).size.height,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                                const AssetImage('assets/images/Entropy.PNG'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )));
            }
          }),
    );
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
