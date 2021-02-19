import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adobe_xd/pinned.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'user_info.dart';
import 'backend_connect.dart';

final serverAPI = new ServerAPI();

class ProfilePage extends StatefulWidget {
  ProfilePage({this.user});

  final User user;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final double topPadding = 50;
  final double sidePadding = 20;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height - topPadding;

    return Scaffold(
        body: Container(
      padding: EdgeInsets.only(
          top: topPadding, left: sidePadding, right: sidePadding),
      child: Column(
        children: <Widget>[
          ChangeNotifierProvider(
            create: (context) => ProfilePageHeaderProvider(
                height: .4 * height, user: widget.user),
            child: ProfilePageHeader(),
          ),
          ProfilePostScroll(height: .6 * height),
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
    _isFollowing();
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

  Future<void> _isFollowing() async {
    String url = serverAPI.url + "users/$userID/following/${user.userID}/";
    var response = await http.get(url);

    if (json.decode(response.body)["following_bool"] == true) {
      _updateToFollowing();
    }
  }

  Future<void> _startFollowing() async {
    String url = serverAPI.url + "users/" + userID + "/following/new/";
    var response = await http.post(url, body: {"creatorID": user.userID});

    if (response.statusCode == 201) {
      _updateToFollowing();
    }
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
                    ._startFollowing();
              },
            ),
          ]);
    });
  }
}

class ProfilePostScroll extends StatelessWidget {
  ProfilePostScroll({this.height});

  final double height;

  Future<List<Widget>> _getProfilePosts() async {
    List<Widget> profilePosts = [ProfileMainPost()];
    for (int i = 0; i < 20; i++)
      profilePosts.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[ProfilePost(), ProfilePost(), ProfilePost()],
      ));

    return profilePosts;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getProfilePosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return SizedBox(
              height: height,
              child: new ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return snapshot.data[index];
                },
              ),
            );
          } else {
            return Center(child: Text("Loading..."));
          }
        });
  }
}

class ProfileMainPost extends StatelessWidget {
  const ProfileMainPost({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Container(
        height: 201.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            // image: DecorationImage(
            //   image: const AssetImage(''),
            //   fit: BoxFit.cover,
            // ),
            border: Border.all(width: 1.0, color: const Color(0xff707070))),
      ),
    );
  }
}

class ProfilePost extends StatelessWidget {
  const ProfilePost({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = (MediaQuery.of(context).size.width - 60) / 3;

    return Container(
      width: width,
      height: width * goldenRatio,
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Container(
          decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        // image: DecorationImage(
        //   image: const AssetImage(''),
        //   fit: BoxFit.cover,
        // ),
        border: Border.all(width: 1.0, color: const Color(0xff707070)),
      )),
    );
  }
}

const String _svg_cdsk62 =
    '<svg viewBox="289.0 36.0 57.0 11.0" ><path transform="translate(289.0, 36.0)" d="M 6.397959232330322 0 L 50.60204315185547 0 C 54.13554000854492 0 57.00000381469727 2.462433815002441 57.00000381469727 5.5 C 57.00000381469727 8.537566184997559 54.13554000854492 11 50.60204315185547 11 L 6.397959232330322 11 C 2.864464044570923 11 0 8.537566184997559 0 5.5 C 0 2.462433815002441 2.864464044570923 0 6.397959232330322 0 Z" fill="#22a2ff" stroke="#22a2ff" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_jmyh3o =
    '<svg viewBox="119.5 286.0 136.0 1.0" ><path transform="translate(119.5, 286.0)" d="M 0 0 L 136 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
