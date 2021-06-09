import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import '../../API/authentication.dart';
import '../../models/user.dart';
import '../../widgets/forwad_arrow.dart';

import '../navigation/home_screen.dart';

import 'enter_account.dart';

class Welcome extends StatelessWidget {
  // Checks to see if the current device is signed in on. If it is, then saves
  // the user data to globals.user and sends the user to the home screen.
  // Otherwise sends the user to WelcomePage().
  Welcome({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffffffff),
        body: FutureBuilder(
            future: checkIfDeviceSignedInOn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Map response = snapshot.data;
                if (response['signedIn']) {
                  globals.user = User.fromJson(response['user']);
                  return Home(
                    pageLabel: PageLabel.friends,
                  );
                } else {
                  return WelcomePage();
                }
              } else {
                return Center(
                  child: Text("Entropy"),
                );
              }
            }));
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: Text(
            'Welcome To Entropy ',
            style: TextStyle(
              fontFamily: 'Rockwell',
              fontSize: 35,
              color: const Color(0xff000000),
              letterSpacing: -0.84,
              height: 0.6285714285714286,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          height: 50,
        ),
        FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    settings: RouteSettings(name: "/enterAccount"),
                    builder: (context) => LogInScreen()),
              );
            },
            child: ForwardArrow()),
      ],
    );
  }
}
