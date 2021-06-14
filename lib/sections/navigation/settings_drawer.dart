import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import '../../API/methods/authentication.dart';
import '../../widgets/profile_pic.dart';
import '../../main.dart';

import '../profile_page.dart';
import '../camera/camera.dart';

import '../personalization/choose_color.dart';
import '../personalization/preferences.dart';

class SettingsDrawer extends StatefulWidget {
  // The SettingsDrawer pops out from the left side of the screen. It contains
  // the user's profile, username, and userID. Below that is a list of buttons.

  SettingsDrawer({
    this.width = 250,
    Key key,
  }) : super(key: key);

  final double width;

  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(width: 1.0, color: Colors.black),
          ),
        ),
        padding: EdgeInsets.only(top: 40, bottom: 40),
        width: widget.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SettingsDrawerProfile(),
            SettingsButton(
              buttonName: "Change Profile Picture",
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Camera(
                            cameraUsage: CameraUsage.profile,
                          ))).then((value) {
                setState(() {});
              }),
            ),
            SettingsButton(
                buttonName: "Sign Out",
                onPressed: () async {
                  await showDialog(
                      barrierColor: null,
                      context: context,
                      builder: (BuildContext context) {
                        return LogOutAlertDialog();
                      }).then((confirmLogOut) async {
                    if (confirmLogOut != null && confirmLogOut) {
                      await signOut();
                      Navigator.popUntil(context, (route) => route.isFirst);

                      runApp(MyApp());
                    }
                  });
                }),
            SettingsButton(
              buttonName: "Choose color",
              onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ColorsPage()))
                  .then((value) {
                setState(() {});
              }),
            ),
            SettingsButton(
              buttonName: "Set preferences",
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PreferencesPage())).then((value) {
                setState(() {});
              }),
            )
          ],
        ),
      ),
    );
  }
}

class SettingsDrawerProfile extends StatelessWidget {
  // Displays user's profile, username, and userID on the top of the Settings
  // Drawer.
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: ProfilePic(
              diameter: 200,
              user: globals.user,
            )),
        Text(
          globals.user.username,
          style: TextStyle(fontSize: 32),
        ),
        Text(
          "@${globals.user.userID}",
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

class LogOutAlertDialog extends StatelessWidget {
  // Alert dialog that is used to confirm that the user does want to sign out.
  // Displays two buttons: "yes" or "no". If the user clicks "yes", returns true
  // (indicating that the user does want to sign out). If the user clicks "no",
  // then returns false.
  const LogOutAlertDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: Container(
        height: 160,
        width: 320,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(25))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: EdgeInsets.only(bottom: 20, left: 25, right: 25),
                child: Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child:
                      LougOutAlertDialogButton(color: Colors.red, text: 'Yes'),
                  onTap: () => Navigator.pop(context, true),
                ),
                Container(
                  width: 20,
                ),
                GestureDetector(
                  child: LougOutAlertDialogButton(
                      color: Colors.grey[200], text: 'No'),
                  onTap: () => Navigator.pop(context, false),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class LougOutAlertDialogButton extends StatelessWidget {
  const LougOutAlertDialogButton({
    @required this.color,
    @required this.text,
    Key key,
  }) : super(key: key);

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 95,
        height: 36,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.all(Radius.circular(14))),
        child: Center(child: Text(text)));
  }
}

class SettingsButton extends StatelessWidget {
  SettingsButton({@required this.buttonName, @required this.onPressed});

  final String buttonName;
  final onPressed;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Container(
          width: 209.0,
          height: 30.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: const Color(0xffffffff),
            border: Border.all(width: 1.0, color: const Color(0xff707070)),
          ),
          child: Center(child: Text(buttonName)),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
