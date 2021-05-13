import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'models/post.dart';

import 'backend_connect.dart';
import 'post/post_view.dart';

ServerAPI serverAPI = ServerAPI();

class ProfilePic extends StatelessWidget {
  // Gets the profile post from google stroage and returns a stack of two
  // widgets: a circular profile post and a blue cicular outline that goes
  // around the profile post.

  ProfilePic({@required this.diameter, @required this.profileUserID});

  final double diameter;
  final String profileUserID;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getProfileURL(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: <Widget>[
                if (snapshot.data != null)
                  ClipPath(
                      clipper:
                          ProfilePicClip(diameter: diameter, heightOffset: 0),
                      child: PostView(
                          post: snapshot.data,
                          height: diameter,
                          aspectRatio: 1,
                          postStage: PostStage.onlyPost)),
                Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                      border: Border.all(
                          width: .02 * diameter,
                          color: const Color(0xff22a2ff)),
                    )),
              ],
            );
          } else {
            return Container();
          }
        });
  }

  Future<Post> getProfileURL() async {
    String newUrl = serverAPI.url + "users/$profileUserID/profile/";
    var response = await http.get(newUrl);

    if (json.decode(response.body)["profileType"] == "none") return null;

    return Post.fromProfile(
        json.decode(response.body)["profileType"], profileUserID);
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
