import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../globals.dart' as globals;

import 'home/home_page.dart';

import 'account/sign_up_methods.dart';

class Welcome extends StatefulWidget {
  // Checks to see if the current device is signed in on. If it is, then saves
  // the user data to globals.user and sends the user to the home screen.
  // Otherwise sends the user to WelcomePage(). Listens to account repository
  // and rebuilds every time the user signs out.
  Welcome({
    Key key,
  }) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  Future _registerNotificationsFuture;
  Future _accountUserFuture;

  @override
  void initState() {
    _registerNotificationsFuture = _registerNotifications();
    _signOutCallback();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: FutureBuilder(
          future: _registerNotificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return FutureBuilder(
                  future: _accountUserFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      globals.size = globals.SizeConfig(context: context);

                      if (snapshot.hasData) {
                        globals.uid = snapshot.data.uid;
                        return HomePage();
                      } else {
                        return SignUpMethodsPage();
                      }
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

  Future<void> _registerNotifications() async {
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

  Future<void> _signOutCallback() async {
    _accountUserFuture = globals.accountRepository.getUser();
    globals.accountRepository.stream.listen((_) {
      _accountUserFuture = globals.accountRepository.getUser();

      setState(() {});
    });
  }
}
