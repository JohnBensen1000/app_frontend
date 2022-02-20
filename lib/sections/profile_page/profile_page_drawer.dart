import 'package:flutter/material.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:test_flutter/API/methods/users.dart';

import '../../globals.dart' as globals;
import '../../widgets/profile_pic.dart';
import '../../main.dart';
import '../../widgets/alert_dialog_container.dart';
import 'package:test_flutter/widgets/generic_text_button.dart';

import '../camera/camera.dart';

import '../personalization/choose_color.dart';
import '../personalization/change_username.dart';
import '../personalization/terms_and_services.dart';
import '../personalization/preferences.dart';

// import 'blocked_list.dart';

class ProfilePageDrawer extends StatefulWidget {
  // The profile widget pops out from the left side of the screen. It contains
  // the user's profile picture and a list of buttons. Each button allows the
  // user to change a different aspect of their their profile.

  ProfilePageDrawer({
    Key key,
  }) : super(key: key);

  @override
  _ProfilePageDrawerState createState() => _ProfilePageDrawerState();
}

class _ProfilePageDrawerState extends State<ProfilePageDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
          top: .047 * globals.size.height, bottom: .1 * globals.size.height),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfileDrawerHeader(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: [
                    GenericTextButton(
                        buttonName: "Choose color",
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ColorsPage()))),
                    GenericTextButton(
                        buttonName: "Set preferences",
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PreferencesPage()))),
                    GenericTextButton(
                        buttonName: "Change username",
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChangeUsernamePage()))),
                    GenericTextButton(
                        buttonName: "Terms & Services",
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TermsAndServicesPage()))),
                  ],
                ),
                Column(
                  children: [
                    GenericTextButton(
                        buttonName: "Sign Out",
                        onPressed: () async {
                          await showAlertDialog(
                                  "Are you sure you want to log out?")
                              .then((confirmLogOut) async {
                            if (confirmLogOut != null && confirmLogOut) {
                              await updateDeviceToken(null);
                              await globals.accountRepository.removeUid();
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                            }
                          });
                        }),
                    GenericTextButton(
                        buttonName: "Delete account",
                        fontColor: Colors.red,
                        onPressed: () async => await handleDeleteAccount()),
                  ],
                ),
              ],
            ),
          ),
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
            // Navigator.popUntil(context, (route) => route.isFirst);

            // runApp(MyApp());
          }
        });
    });
  }
}

class ProfileDrawerHeader extends StatefulWidget {
  // Displays the user's profile. Allows the user to change their profile by
  // tapping on it.
  @override
  _ProfileDrawerHeaderState createState() => _ProfileDrawerHeaderState();
}

class _ProfileDrawerHeaderState extends State<ProfileDrawerHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: .3 * globals.size.height,
      margin: EdgeInsets.only(bottom: .02 * globals.size.height),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                top: .02 * globals.size.height,
                bottom: .02 * globals.size.height),
            child: GestureDetector(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    FutureBuilder(
                        future: globals.userRepository.get(globals.uid),
                        builder: (context, snapshot) => snapshot.hasData
                            ? ProfilePic(
                                diameter: .2 * globals.size.height,
                                user: snapshot.data)
                            : Container()),
                    Text("Take New Photo",
                        style: TextStyle(
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(0, 0),
                                blurRadius: 1.0,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ],
                            color: Colors.grey[200],
                            fontSize: .02 * globals.size.height)),
                  ],
                ),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Camera(
                              cameraUsage: CameraUsage.profile,
                            )))),
          ),
          Text(
            "Edit Profile",
            style: TextStyle(
                fontSize: .04 * globals.size.height,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
