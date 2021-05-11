import 'package:flutter/material.dart';

import 'models/user.dart';

import 'globals.dart' as globals;
import 'profile_pic.dart';
import 'profile_page.dart';
import 'camera/camera.dart';

class SettingsDrawer extends StatelessWidget {
  SettingsDrawer({
    this.width = 250,
    Key key,
  }) : super(key: key);

  final double width;

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
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: ProfilePic(
                  diameter: 200,
                  profileUserID: globals.userID,
                )),
            Text(
              globals.username,
              style: TextStyle(fontSize: 32),
            ),
            Text(
              "@${globals.userID}",
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            SettingsButton(
              buttonName: "Change Profile Picture",
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Camera(
                            cameraUsage: CameraUsage.profile,
                          ))),
            ),
            SettingsButton(
              buttonName: "Go To Profile Page",
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                          user: User(
                              userID: globals.userID,
                              username: globals.username)))),
            ),
          ],
        ),
      ),
    );
  }
}

// class NewProfilePic extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(children: <Widget>[
//         Camera(
//           cameraUsage: CameraUsage.profile,
//         )
//       ]),
//     );
//   }
// }

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
