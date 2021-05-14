import 'package:flutter/material.dart';

import '../backend_connect.dart';
import '../post/post_view.dart';

ServerAPI serverAPI = ServerAPI();

class ProfilePic extends StatelessWidget {
  // Gets the profile post from google stroage and returns a stack of two
  // widgets: a circular profile post and a blue cicular outline that goes
  // around the profile post.

  ProfilePic({@required this.diameter, @required this.userID});

  final double diameter;
  final String userID;

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
                  future: getProfileURL(userID),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData)
                      return PostView(
                          post: snapshot.data,
                          height: diameter,
                          aspectRatio: 1,
                          postStage: PostStage.onlyPost);
                    else
                      return Container(
                        width: diameter,
                        height: diameter,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.elliptical(9999.0, 9999.0)),
                          border: Border.all(
                              width: .02 * diameter,
                              color: const Color(0xff22a2ff)),
                        ),
                      );
                  })),
          Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                border: Border.all(
                    width: .02 * diameter, color: const Color(0xff22a2ff)),
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
