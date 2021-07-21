import 'package:flutter/material.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:test_flutter/API/methods/users.dart';

import '../../globals.dart' as globals;
import '../../widgets/profile_pic.dart';
import '../../main.dart';
import '../../widgets/alert_dialog_container.dart';

import '../camera/camera.dart';

import '../personalization/choose_color.dart';
import '../personalization/preferences.dart';

import 'blocked_list.dart';

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
      padding: EdgeInsets.only(
          top: .047 * globals.size.height, bottom: .047 * globals.size.height),
      width: widget.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
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
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PreferencesPage())).then((value) {
                  setState(() {});
                }),
              ),
              SettingsButton(
                  buttonName: "Delete account",
                  onPressed: () async => await handleDeleteAccount()),
              SettingsButton(
                  buttonName: "Unblock creators",
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BlockedList()))),
            ],
          ),
          Text(
            "Contact support at: entropy.developer1@gmail.com",
            textAlign: TextAlign.center,
          )
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
          return AlertDialogContainer(
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
            padding: EdgeInsets.only(
                top: .024 * globals.size.height,
                bottom: .024 * globals.size.height),
            child: ProfilePic(
              diameter: .24 * globals.size.height,
              user: globals.user,
            )),
        Text(
          globals.user.username,
          style: TextStyle(fontSize: .038 * globals.size.height),
        ),
        Text(
          "@${globals.user.userID}",
          style: TextStyle(
              fontSize: .014 * globals.size.height, color: Colors.grey[500]),
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
        padding: EdgeInsets.only(
            top: .012 * globals.size.height,
            bottom: .012 * globals.size.height),
        child: Container(
          width: .536 * globals.size.width,
          height: .036 * globals.size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(globals.size.height),
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
