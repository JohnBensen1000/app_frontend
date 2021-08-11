import 'package:flutter/material.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:test_flutter/widgets/generic_alert_dialog.dart';

import '../sections/post/post_widget.dart';

import '../models/user.dart';
import '../models/post.dart';
import '../widgets/alert_dialog_container.dart';
import '../API/methods/reports.dart';
import '../API/methods/posts.dart';

import '../globals.dart' as globals;

class Profile extends StatelessWidget {
  Profile({@required this.diameter, @required this.user});

  final double diameter;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ProfilePic(
          diameter: diameter,
          user: user,
        ),
        Container(
          padding: EdgeInsets.only(left: diameter / 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.username, style: TextStyle(fontSize: .4 * diameter)),
              Text(
                "@${user.userID}",
                style:
                    TextStyle(fontSize: .2 * diameter, color: Colors.grey[500]),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ProfilePic extends StatelessWidget {
  ProfilePic({
    @required this.diameter,
    @required this.user,
  });

  final double diameter;
  final User user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: diameter,
        height: diameter,
        child: Stack(
          children: <Widget>[
            ClipPath(
                clipper: ProfilePicClip(
                  diameter: diameter,
                  heightOffset: 0,
                ),
                child: FutureBuilder(
                    future: globals.profileRepository.get(user),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        if (user.uid == globals.user.uid) {
                          return StreamBuilder(
                              stream: globals.profileRepository.stream,
                              builder: (context, streamSnapshot) {
                                return PostWidget(
                                    post: streamSnapshot.hasData
                                        ? streamSnapshot.data
                                        : snapshot.data,
                                    height: diameter,
                                    aspectRatio: 1);
                              });
                        } else {
                          return PostWidget(
                              post: snapshot.data,
                              height: diameter,
                              aspectRatio: 1);
                        }
                      } else
                        return Container();
                    })),
            Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius:
                      BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                  border: Border.all(
                      width: .02 * diameter, color: user.profileColor),
                )),
          ],
        ),
      ),
      onLongPress: () async {
        if (user.uid != globals.user.uid) await _reportProfile(context);
      },
    );
  }

  Future<void> _reportProfile(BuildContext context) async {
    await (showDialog(
            context: context,
            builder: (context) => AlertDialogContainer(
                dialogText: "Do you want to report this profile picture?")))
        .then((willReportProfile) {
      if (willReportProfile) {
        reportProfile(user);
        showDialog(
            context: context,
            builder: (context) => GenericAlertDialog(
                text:
                    "Thank you for reporting this user's profile picture. We will review the picture to see if it violates any of our guidelines."));
      }
    });
  }
}

class ProfilePicClip extends CustomClipper<Path> {
  ProfilePicClip({@required this.diameter, @required this.heightOffset});

  final double diameter;
  final double heightOffset;

  @override
  Path getClip(Size size) {
    return new Path()
      ..addOval(Rect.fromLTWH(0, heightOffset, diameter, diameter));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
