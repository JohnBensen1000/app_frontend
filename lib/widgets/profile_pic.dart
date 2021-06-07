import 'package:flutter/material.dart';

import '../sections/post/post_view.dart';
import '../models/user.dart';
import '../API/posts.dart';

class Profile extends StatelessWidget {
  // Displays the user's profile image/video, username, and userID. The user's
  // profile image/video is inside of a colored circle. The color of this circle
  // is determined by the user.

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
              Text(user.username, style: TextStyle(fontSize: diameter / 4)),
              Text(
                "@${user.userID}",
                style:
                    TextStyle(fontSize: diameter / 8, color: Colors.grey[500]),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ProfilePic extends StatelessWidget {
  // Gets the profile post from google stroage and returns a stack of two
  // widgets: a circular profile post and a blue cicular outline that goes
  // around the profile post.

  ProfilePic({@required this.diameter, @required this.user});

  final double diameter;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      child: Stack(
        children: <Widget>[
          ClipPath(
              clipper: ProfilePicClip(diameter: diameter, heightOffset: 0),
              child: FutureBuilder(
                  future: getProfile(user),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData)
                      return PostView(
                          post: snapshot.data,
                          height: diameter,
                          aspectRatio: 1,
                          playOnInit: true,
                          playWithVolume: false,
                          saveInMemory: true,
                          postStage: PostStage.onlyPost);
                    else
                      return Container(
                        width: diameter,
                        height: diameter,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.elliptical(9999.0, 9999.0)),
                          border: Border.all(
                              width: .02 * diameter, color: user.profileColor),
                        ),
                      );
                  })),
          Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                border:
                    Border.all(width: .02 * diameter, color: user.profileColor),
              )),
        ],
      ),
    );
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
