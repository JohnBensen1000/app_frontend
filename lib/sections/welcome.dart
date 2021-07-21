import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import '../globals.dart' as globals;
import '../API/methods/authentication.dart';
import '../models/user.dart';
import '../widgets/forward_arrow.dart';
import '../API/handle_requests.dart';

import 'navigation/home_screen.dart';

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
            future: Firebase.initializeApp(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return FutureBuilder(
                  future: globals.accountRepository.getUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      globals.size = globals.SizeConfig(context: context);

                      if (snapshot.hasData) {
                        globals.user = snapshot.data;

                        return Home();
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
            }));
  }
}
