import 'package:flutter/material.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:test_flutter/API/methods/users.dart';

import '../../globals.dart' as globals;
import '../../widgets/profile_pic.dart';
import '../../main.dart';

import '../camera/camera.dart';

import '../personalization/choose_color.dart';
import '../personalization/preferences.dart';

class Settings extends StatefulWidget {
  // The Settings widget pops out from the left side of the screen. It contains
  // the user's profile, username, and userID. Below that is a list of buttons.

  Settings({
    @required this.width,
    Key key,
  }) : super(key: key);

  final double width;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
          SettingsProfile(),
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
                await showAlertDialog("Are you sure you want to log out?")
                    .then((confirmLogOut) async {
                  if (confirmLogOut != null && confirmLogOut) {
                    await globals.accountRepository.removeUid();
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
            onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PreferencesPage()))
                .then((value) {
              setState(() {});
            }),
          ),
          SettingsButton(
              buttonName: "Delete account",
              onPressed: () async => await handleDeleteAccount())
        ],
      ),
    );
  }

  Future<bool> showAlertDialog(String dialogText) {
    // Displays a generic alert dialog. This alert dialog asks a yes or no
    // question, and returns a boolean.
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SettingsAlertDialog(
            dialogText: dialogText,
          );
        });
  }

  Future<void> handleDeleteAccount() async {
    // Asks the user twice to make sure that they want to delete their account.
    // If they respond with 'yes' both times, deletes their account and restarts
    // the app.
    await showAlertDialog("Are you sure that you want to delete your account?")
        .then((confirmDelete) async {
      if (confirmDelete != null && confirmDelete)
        showAlertDialog(
                "Your account will be deleted permanently. Are you sure you want to delete it?")
            .then((confirmDelete) async {
          if (confirmDelete != null && confirmDelete) {
            await handleRequest(context, deleteAccount());
            await globals.accountRepository.removeUid();
            Navigator.popUntil(context, (route) => route.isFirst);

            runApp(MyApp());
          }
        });
    });
  }
}

class SettingsProfile extends StatelessWidget {
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

class SettingsButton extends StatelessWidget {
  // Generic widget used for all buttons on the settings page.
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

class SettingsAlertDialog extends StatelessWidget {
  // A generic alert dialog used for confirming certain actions. Displays a
  // question (given by the String dialogText). Displays two buttons, 'yes' and
  // 'no'. When either is pressed, the alert dialog is popped and a boolean is
  // returned (true if yes, false if no).

  const SettingsAlertDialog({
    @required this.dialogText,
    Key key,
  }) : super(key: key);

  final String dialogText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: Container(
        child: Center(
          child: Container(
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
                      dialogText,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: SettingsAlertDialogButton(
                          color: Colors.red, text: 'Yes'),
                      onTap: () => Navigator.pop(context, true),
                    ),
                    Container(
                      width: 20,
                    ),
                    GestureDetector(
                      child: SettingsAlertDialogButton(
                          color: Colors.grey[200], text: 'No'),
                      onTap: () => Navigator.pop(context, false),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsAlertDialogButton extends StatelessWidget {
  // Stateless widget used for 'yes' and 'no' buttons in SettingsAlertDialog.
  const SettingsAlertDialogButton({
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
