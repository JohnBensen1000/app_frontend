import 'dart:math';

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

class ProfilePic extends StatefulWidget {
  ProfilePic({
    @required this.diameter,
    @required this.user,
  });

  final double diameter;
  final User user;

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: widget.diameter,
        height: widget.diameter,
        child: Stack(
          children: <Widget>[
            ClipPath(
                clipper: ProfilePicClip(
                  diameter: widget.diameter,
                  heightOffset: 0,
                ),
                child: globals.profileRepository.contains(widget.user)
                    ? _profileBody(globals.profileRepository.get(widget.user))
                    : FutureBuilder(
                        future:
                            globals.profileRepository.getFuture(widget.user),
                        builder: (context, snapshot) =>
                            _profileBody(snapshot.data))),
            if (widget.user.uid == globals.uid)
              StreamBuilder(
                  stream: globals.userRepository.stream,
                  builder: (context, snapshot) {
                    return FutureBuilder(
                        future: globals.userRepository.get(widget.user.uid),
                        builder: (context, snapshot) => _profileBorder(
                            snapshot.hasData
                                ? snapshot.data.profileColor
                                : Colors.transparent));
                  })
            else
              _profileBorder(widget.user.profileColor)
          ],
        ),
      ),
      onLongPress: () async {
        if (widget.user.uid != globals.uid) await _reportProfile(context);
      },
    );
  }

  Widget _profileBody(Post profile) {
    return widget.user.uid == globals.uid
        ? StreamBuilder(
            stream: globals.profileRepository.stream,
            builder: (context, streamSnapshot) {
              return profile != null
                  ? PostWidget(
                      post: streamSnapshot.hasData
                          ? streamSnapshot.data
                          : profile,
                      height: widget.diameter,
                      aspectRatio: 1)
                  : _profileBase();
            })
        : profile != null
            ? PostWidget(post: profile, height: widget.diameter, aspectRatio: 1)
            : _profileBase();
  }

  Widget _profileBorder(Color color) {
    return Container(
        width: widget.diameter,
        height: widget.diameter,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
          border: Border.all(width: .02 * widget.diameter, color: color),
        ));
  }

  Widget _profileBase() {
    return widget.user.uid == globals.uid
        ? StreamBuilder(
            stream: globals.userRepository.stream,
            builder: (context, snapshot) => _profileSolidBackground(
                snapshot.hasData ? snapshot.data : widget.user))
        : _profileSolidBackground(widget.user);
  }

  Widget _profileSolidBackground(User user) {
    return Container(
        color: user.profileColor,
        child: Center(
            child: Text(
          widget.user.username.substring(
              0,
              min(
                2,
                widget.user.username.length,
              )),
          style: TextStyle(fontSize: .4 * widget.diameter, color: Colors.white),
        )));
  }

  Future<void> _reportProfile(BuildContext context) async {
    await (showDialog(
            context: context,
            builder: (context) => AlertDialogContainer(
                dialogText: "Do you want to report this profile picture?")))
        .then((willReportProfile) {
      if (willReportProfile) {
        reportProfile(widget.user);
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
