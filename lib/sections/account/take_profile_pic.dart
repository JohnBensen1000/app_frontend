import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/widgets/profile_pic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../globals.dart' as globals;
import '../../API/methods/users.dart';
import '../../widgets/wide_button.dart';

import '../personalization/choose_color.dart';
import '../personalization/preferences.dart';
import '../home/home_page.dart';
import '../camera/camera.dart';

import 'widgets/account_submit_button.dart';
import 'widgets/account_input_page.dart';

class SlideRightRoute extends PageRouteBuilder {
  // Custon PageRouteBuilder. Routes slide to the left when popped.

  final Widget page;

  SlideRightRoute({this.page})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                page,
            transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) =>
                SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child));
}

class TakeProfilePage extends StatefulWidget {
  // Returns a page that asks the user if they want to take a profile picture.
  // Then displays two options: take profile and skip.

  @override
  State<TakeProfilePage> createState() => _TakeProfilePageState();
}

class _TakeProfilePageState extends State<TakeProfilePage> {
  bool _hasTakenProfile;

  @override
  void initState() {
    _hasTakenProfile = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: AccountInputPageWrapper(
          showBackArrow: false,
          headerText: "Take\nYour Profile\nPicture",
          onTap: null,
          height: .29,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: .35 * globals.size.height,
                  alignment: Alignment.center,
                  child: FutureBuilder(
                      future: globals.userRepository.get(globals.uid),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return ProfilePic(
                              diameter: .3 * globals.size.height,
                              user: snapshot.data);
                        } else {
                          return Container();
                        }
                      }),
                ),
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(bottom: .02 * globals.size.height),
                    child: WideButton(
                      buttonName: !_hasTakenProfile
                          ? "Take profile picture"
                          : "Retake picture",
                    ),
                  ),
                  onTap: () {
                    globals.googleAnalyticsAPI.logTakeProfilePageVisited();

                    Navigator.push(
                        context,
                        SlideRightRoute(
                            page: Camera(
                          cameraUsage: CameraUsage.profile,
                        ))).then((_) {
                      globals.googleAnalyticsAPI.logPickColorPageVisited();
                      _hasTakenProfile = true;
                      setState(() {});
                    });
                  },
                ),
                GestureDetector(
                    child: WideButton(
                      buttonName: !_hasTakenProfile ? "Skip" : "Continue",
                    ),
                    onTap: () {
                      globals.googleAnalyticsAPI.logPickColorPageVisited();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    }),
              ],
            ),
          ),
        ));
  }
}
