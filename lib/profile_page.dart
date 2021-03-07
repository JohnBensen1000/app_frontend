import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'user_info.dart';
import 'backend_connect.dart';
import 'view_post.dart';

import 'package:firebase_storage/firebase_storage.dart';

FirebaseStorage storage = FirebaseStorage.instance;
final serverAPI = new ServerAPI();

class ProfilePage extends StatelessWidget {
  // Main widget for a user's profile page. This page shows all of a user's
  // public posts, and allows visitors to start following the user.

  ProfilePage({this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height - 50;

    return Scaffold(
        body: Container(
      padding: EdgeInsets.only(top: 50),
      child: Column(
        children: <Widget>[
          ChangeNotifierProvider(
            create: (context) =>
                ProfilePageHeaderProvider(height: .4 * height, user: user),
            child: ProfilePageHeader(),
          ),
          ProfilePostBody(
              height: .6 * height,
              user: user,
              sidePadding: 20,
              betweenPadding: 5),
        ],
      ),
    ));
  }
}

class ProfilePageHeaderProvider extends ChangeNotifier {
  final double height;
  final User user;

  Color followingColor;
  String followingText;

  ProfilePageHeaderProvider({this.height, this.user}) {
    _updateToNotFollowing();
    isFollowing();
  }

  Future<void> isFollowing() async {
    String url = serverAPI.url + "users/$userID/following/${user.userID}/";
    var response = await http.get(url);

    if (json.decode(response.body)["following_bool"] == true) {
      _updateToFollowing();
    }
  }

  Future<void> startFollowing() async {
    String url = serverAPI.url + "users/" + userID + "/following/new/";
    var response = await http.post(url, body: {"creatorID": user.userID});

    if (response.statusCode == 201) {
      _updateToFollowing();
    }
  }

  void _updateToFollowing() {
    followingColor = Colors.grey[300];
    followingText = "Following";
    notifyListeners();
  }

  void _updateToNotFollowing() {
    followingColor = Colors.white;
    followingText = "Follow";
    notifyListeners();
  }
}

class ProfilePageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfilePageHeaderProvider>(
        builder: (context, profileHeader, child) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 24.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        // image: DecorationImage(
                        //   image: const AssetImage(''),
                        //   fit: BoxFit.cover,
                        // ),
                        border: Border.all(
                            width: 1.0, color: const Color(0xff707070)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                          width: 80,
                          height: 25,
                          decoration: new BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Colors.grey[300],
                          ),
                          child: FlatButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Center(
                                child: Text(
                                  'Exit',
                                  textAlign: TextAlign.center,
                                ),
                              ))),
                    ),
                  ],
                ),
                Stack(
                  children: <Widget>[
                    Container(
                      width: 73.0,
                      height: 11.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        color: const Color(0xffffffff),
                        border: Border.all(
                            width: 1.0, color: const Color(0xff22a2ff)),
                      ),
                    ),
                    SvgPicture.string(
                      _svg_cdsk62,
                      allowDrawingOutsideViewBox: true,
                    ),
                  ],
                )
              ],
            ),
            Container(
              height: 15,
            ),
            Container(
              width: 148.0,
              height: 148.0,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                // image: DecorationImage(
                //   image: const AssetImage(''),
                //   fit: BoxFit.cover,
                // ),
                border: Border.all(width: 3.0, color: const Color(0xff22a2ff)),
              ),
            ),
            Container(
              child: Text(
                '${profileHeader.user.username}',
                style: TextStyle(
                  fontFamily: 'Helvetica Neue',
                  fontSize: 25,
                  color: const Color(0xff000000),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              child: Text(
                '${profileHeader.user.userID}',
                style: TextStyle(
                  fontFamily: 'Helvetica Neue',
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              height: 20,
              child: SvgPicture.string(
                _svg_jmyh3o,
                allowDrawingOutsideViewBox: true,
              ),
            ),
            FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                width: 125.0,
                height: 31.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  // color: const Color(0xffffffff),
                  color: profileHeader.followingColor,
                  border:
                      Border.all(width: 1.0, color: const Color(0xff707070)),
                ),
                child: Center(
                  child: Text(
                    profileHeader.followingText,
                    style: TextStyle(
                      fontFamily: 'Helvetica Neue',
                      fontSize: 20,
                      color: const Color(0xff000000),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              onPressed: () {
                Provider.of<ProfilePageHeaderProvider>(context, listen: false)
                    .startFollowing();
              },
            ),
          ]);
    });
  }
}

class ProfilePostBody extends StatelessWidget {
  // Gets and returns a all of the creator's publics posts. The posts are
  // organized into a list of widgets. This list runs vertically and starts off
  // with a big ProfilePostWidget() that takes up the entire width of the page.
  // The rest of the list is a series of Rows(), each row is made of up 3
  // ProfilePostWidget().

  ProfilePostBody(
      {@required this.height,
      @required this.user,
      @required this.sidePadding,
      @required this.betweenPadding});

  final double height;
  final User user;
  final double sidePadding;
  final double betweenPadding;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getProfilePosts(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.only(left: sidePadding, right: sidePadding),
              child: SizedBox(
                height: height,
                child: new ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return snapshot.data[index];
                  },
                ),
              ),
            );
          } else {
            return Center(child: Text("Loading..."));
          }
        });
  }

  Future<List<Widget>> _getProfilePosts(BuildContext context) async {
    // Sends a request to the server to get a list of the creator's posts. When
    // this list is recieved, _getProfilePostsList() is called to build a list
    // of ProfilePostWidget().
    var response =
        await http.get(serverAPI.url + "posts/${user.userID}/posts/");
    List<dynamic> postList = json.decode(response.body)["userPosts"];

    if (postList.length == 0) {
      return null;
    }
    return _getProfilePostsList(context, postList);
  }

  List<Widget> _getProfilePostsList(
      BuildContext context, List<dynamic> postList) {
    // Determines width and height for every post on the profile page. The first
    // widget in the return list is a large ProfilePostWidget(). The remaining
    // posts are broken up into rows of 3 ProfilePostWidget().

    double width = MediaQuery.of(context).size.width;
    double mainPostHeight = (width - 2 * sidePadding) / goldenRatio;
    double bodyPostHeight =
        (((width - 2 * sidePadding) / 3) - betweenPadding) * goldenRatio;

    List<Widget> profilePosts = [
      Padding(
        padding: EdgeInsets.only(bottom: betweenPadding),
        child: ProfilePostWidget(
            postJson: postList[0],
            postHeight: mainPostHeight,
            aspectRatio: 1 / goldenRatio),
      )
    ];

    List<Widget> subPostsList = _getSubPostsList(postList, bodyPostHeight);

    for (int i = 0; i < subPostsList.length; i += 3) {
      profilePosts.add(Padding(
        padding: EdgeInsets.only(bottom: betweenPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: subPostsList.sublist(i, i + 3),
        ),
      ));
    }
    return profilePosts;
  }

  List<Widget> _getSubPostsList(List<dynamic> postList, double postHeight) {
    // Creates a list of the remaining posts (not the main post). Adds empty
    // containers so that the return list is evenly divisible by 3.

    List<Widget> subPostsList = [];
    int i = 1;

    while ((i < postList.length) || ((i - 1) % 3 != 0)) {
      if (i < postList.length) {
        subPostsList.add(
          ProfilePostWidget(
              postJson: postList[i],
              postHeight: postHeight,
              aspectRatio: goldenRatio),
        );
      } else {
        subPostsList.add(
          Container(
            height: postHeight,
            width: postHeight / goldenRatio,
          ),
        );
      }
      i++;
    }
    return subPostsList;
  }
}

class ProfilePostWidget extends StatelessWidget {
  // Returns a stack. This stack has a PostWidget() on the bottom, and adds a
  // Text widget that says "Video" if the post is indeed a video.

  ProfilePostWidget(
      {@required this.postJson,
      @required this.postHeight,
      @required this.aspectRatio});

  final postJson;
  final double postHeight;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    Post post = Post.fromJson(postJson);

    return SizedBox(
      height: postHeight,
      width: postHeight / aspectRatio,
      child: Stack(
        children: <Widget>[
          PostWidget(
            post: post,
            height: postHeight,
            containerHeight: postHeight,
            aspectRatio: aspectRatio,
          ),
          if (post.isVideo)
            Container(
                padding: EdgeInsets.all(5),
                alignment: Alignment.topRight,
                child: Text("Video")),
        ],
      ),
    );
  }
}

const String _svg_cdsk62 =
    '<svg viewBox="289.0 36.0 57.0 11.0" ><path transform="translate(289.0, 36.0)" d="M 6.397959232330322 0 L 50.60204315185547 0 C 54.13554000854492 0 57.00000381469727 2.462433815002441 57.00000381469727 5.5 C 57.00000381469727 8.537566184997559 54.13554000854492 11 50.60204315185547 11 L 6.397959232330322 11 C 2.864464044570923 11 0 8.537566184997559 0 5.5 C 0 2.462433815002441 2.864464044570923 0 6.397959232330322 0 Z" fill="#22a2ff" stroke="#22a2ff" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_jmyh3o =
    '<svg viewBox="119.5 286.0 136.0 1.0" ><path transform="translate(119.5, 286.0)" d="M 0 0 L 136 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
