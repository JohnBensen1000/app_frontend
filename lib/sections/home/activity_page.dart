import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter/widgets/profile_pic.dart';

import '../../models/user.dart';
import '../../models/post.dart';
import '../../globals.dart' as globals;
import '../../widgets/back_arrow.dart';
import '../../widgets/alert_circle.dart';
import '../../API/handle_requests.dart';
import '../../API/methods/followings.dart';
import '../../API/methods/users.dart';

import '../profile_page/profile_page.dart';
import '../post/post_widget.dart';
import '../post/post_page.dart';

class ActivityPage extends StatelessWidget {
  // Returns a page displaying all recent activity for a user. This page is
  // broken up into a header and a body. The header displays the page's title
  // and a back button. The body displays a list of all activity (comments,
  // new followers, and followers).

  @override
  Widget build(BuildContext context) {
    double headerHeight = .15 * globals.size.height;
    return Scaffold(
        body: Column(
      children: [
        ActivityPageHeader(height: headerHeight),
        ActivityPageBody(
          height: globals.size.height - headerHeight,
        ),
      ],
    ));
  }
}

class ActivityPageHeader extends StatelessWidget {
  // Displays the page's title and a back button.
  ActivityPageHeader({@required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: .03 * globals.size.height, right: .03 * globals.size.height),
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              GestureDetector(
                  child: BackArrow(), onTap: () => Navigator.pop(context)),
            ],
          ),
          Center(
            child: Text("Activity",
                style: TextStyle(fontSize: .05 * globals.size.height)),
          )
        ],
      ),
    );
  }
}

class ActivityPageBody extends StatefulWidget {
  // Returns a ListView of all of a user's activity. Sets up a stream to a
  // firebase collection that contains all of the user's activity. This activity
  // could be: people commenting on the user's post, new followers, and users
  // who have followed the user back. This widget iterates through the
  // collection of activities and: (1) determines what type of activity it is
  // and (2) whether it is a 'new' activity. Returns the approriate widget based
  // on the widget type and displays a circle to indicate the activity is new.
  // Also displays a button for toggling between all activity and only new
  // followers.

  ActivityPageBody({@required this.height});

  final double height;

  @override
  _ActivityPageBodyState createState() => _ActivityPageBodyState();
}

class _ActivityPageBodyState extends State<ActivityPageBody> {
  bool _showOnlyNewFollowers;
  CollectionReference<Map<String, dynamic>> _activityCollection;

  @override
  void initState() {
    _showOnlyNewFollowers = false;

    _activityCollection = FirebaseFirestore.instance
        .collection('ACTIVITY')
        .doc(globals.user.uid)
        .collection('activity');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height,
        padding: EdgeInsets.only(top: .02 * globals.size.height),
        child: Column(children: [
          GestureDetector(
              child: _activityToggleButton(
                (_showOnlyNewFollowers) ? "all activity" : "new followers",
                Colors.white,
              ),
              onTap: () {
                setState(() {
                  _showOnlyNewFollowers = !_showOnlyNewFollowers;
                });
              }),
          StreamBuilder(
              stream: _activityCollection
                  .orderBy('time', descending: true)
                  .snapshots()
                  .map((snapshot) {
                return snapshot.docs.map((snapshot) {
                  Map docData = snapshot.data();

                  if (_showOnlyNewFollowers &&
                      docData['type'] != 'new_follower') return Container();

                  Widget _activityWidget;

                  switch (docData['type']) {
                    case 'comment':
                      _activityWidget =
                          ActivityCommentWidget(snapshot: snapshot);
                      break;
                    case 'new_follower':
                      _activityWidget = ActivityNewFollowerWidget(
                        snapshot: snapshot,
                      );
                      break;
                    case 'follower':
                      _activityWidget = ActivityFollowerWidget(
                        snapshot: snapshot,
                      );
                      break;

                    default:
                      return Container();
                  }

                  return Container(
                    height: .1 * globals.size.height,
                    child: Row(children: [
                      snapshot.data()['isNew']
                          ? Container(
                              width: .05 * globals.size.width,
                              child: Center(
                                  child: AlertCircle(
                                diameter: .01 * globals.size.width,
                              )),
                            )
                          : Container(
                              width: .05 * globals.size.width,
                            ),
                      Expanded(child: Container(child: _activityWidget))
                    ]),
                  );
                }).toList();
              }),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  handleRequest(context, updatedThatUserIsUpdated());

                  return Expanded(
                      child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: .02 * globals.size.width),
                    child: ListView.builder(
                        padding:
                            EdgeInsets.only(top: .02 * globals.size.height),
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) => snapshot.data[index]),
                  ));
                } else {
                  return Container();
                }
              }),
        ]));
  }

  Widget _activityToggleButton(String buttonName, Color color) {
    return Container(
        width: .35 * globals.size.width,
        height: .03 * globals.size.height,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400], width: 2),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Center(
            child: Text(buttonName,
                style: TextStyle(fontSize: .02 * globals.size.height))));
  }
}

class ActivityCommentWidget extends StatelessWidget {
  // Returns a widget containing the commentor's username and the post that the
  // comment was made on. When tapped, takes the user to the post and updates
  // the 'isNew' field in the appropriate document.

  ActivityCommentWidget({@required this.snapshot});

  final QueryDocumentSnapshot<Map<String, dynamic>> snapshot;

  @override
  Widget build(BuildContext context) {
    Map docData = snapshot.data();

    User commenter = User.fromJson(docData['data']['commenter']);
    Post post = Post.fromJson(docData['data']['post']);

    return GestureDetector(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  ProfilePic(
                      diameter: .06 * globals.size.height, user: commenter),
                  Container(
                    padding: EdgeInsets.only(left: .02 * globals.size.width),
                    width: .6 * globals.size.width,
                    child: RichText(
                        text: new TextSpan(
                            style: new TextStyle(
                                fontSize: .0154 * globals.size.height,
                                color: Colors.black),
                            children: <TextSpan>[
                          TextSpan(
                              text: "${commenter.username} ",
                              style: TextStyle(
                                  fontSize: .016 * globals.size.height,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: "has commented on your post",
                              style: TextStyle(
                                  fontSize: .016 * globals.size.height))
                        ])),
                  )
                ],
              ),
            ),
            PostWidget(
                post: post,
                height: .08 * globals.size.height,
                playVideo: false,
                aspectRatio: 4 / 3)
          ],
        ),
        onTap: () async => await _handleOnTap(context, post));
  }

  Future<void> _handleOnTap(BuildContext context, Post post) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostPage(
                  post: post,
                  isFullPost: true,
                  showComments: true,
                )));
    await snapshot.reference.update({'isNew': false});
  }
}

class ActivityNewFollowerWidget extends StatelessWidget {
  // Returns a widget that shows that the user has gotten a new follower. When
  // tapped, takes the user to the new follower's profile page. Allows the user
  // to follow back or not follow back the new follower. When the user decides
  // on one of these two options, this widget deletes the appropriate document.

  ActivityNewFollowerWidget({@required this.snapshot});

  final QueryDocumentSnapshot<Map<String, dynamic>> snapshot;

  @override
  Widget build(BuildContext context) {
    User follower = User.fromJson(
      snapshot.data()['data']['follower'],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
            child: Row(
              children: [
                ProfilePic(diameter: .06 * globals.size.height, user: follower),
                Container(
                  padding: EdgeInsets.only(left: .02 * globals.size.width),
                  width: .5 * globals.size.width,
                  child: RichText(
                      text: new TextSpan(
                          style: new TextStyle(
                              fontSize: .0154 * globals.size.height,
                              color: Colors.black),
                          children: <TextSpan>[
                        TextSpan(
                            text: "${follower.username} ",
                            style: TextStyle(
                                fontSize: .016 * globals.size.height,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: "Started following you.",
                            style:
                                TextStyle(fontSize: .016 * globals.size.height))
                      ])),
                ),
              ],
            ),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(user: follower)))),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                  child: _acceptDeclineButton(.06 * globals.size.height,
                      "Follow Back", const Color(0xff22a2ff)),
                  onTap: () async =>
                      await _followBack(context, follower, true)),
              GestureDetector(
                child: _acceptDeclineButton(.06 * globals.size.height,
                    "Don't Follow Back", const Color(0xffff0000)),
                onTap: () => _followBack(context, follower, false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _acceptDeclineButton(double height, String name, Color color) {
    return Container(
      width: height,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(.0154 * globals.size.height),
        color: color,
        border: Border.all(width: 1.0, color: const Color(0xffffffff)),
      ),
      child: (Center(
          child: Text(name,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: .0142 * globals.size.height)))),
    );
  }

  Future<void> _followBack(
      BuildContext context, User follower, bool willFollowBack) async {
    if (willFollowBack)
      await handleRequest(context, startFollowing(follower));
    else
      await handleRequest(context, dontFollowBack(follower));

    await snapshot.reference.delete();
  }
}

class ActivityFollowerWidget extends StatelessWidget {
  // Returns a widget that shows that of of the creators that the user is
  // following has followed the user back. When tapped, takes the user to the
  // creator's profile page and updates the 'isNew' field in the appropriate
  // document.

  ActivityFollowerWidget({@required this.snapshot});

  final QueryDocumentSnapshot<Map<String, dynamic>> snapshot;

  @override
  Widget build(BuildContext context) {
    User follower = User.fromJson(
      snapshot.data()['data']['follower'],
    );

    return GestureDetector(
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(right: .04 * globals.size.width),
          child: Row(
            children: [
              ProfilePic(diameter: .06 * globals.size.height, user: follower),
              Container(
                padding: EdgeInsets.only(left: .02 * globals.size.width),
                width: .7 * globals.size.width,
                child: RichText(
                    text: new TextSpan(
                        style: new TextStyle(
                            fontSize: .0154 * globals.size.height,
                            color: Colors.black),
                        children: <TextSpan>[
                      TextSpan(
                          text: "${follower.username} ",
                          style: TextStyle(
                              fontSize: .016 * globals.size.height,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: "Followed you back!",
                          style:
                              TextStyle(fontSize: .016 * globals.size.height))
                    ])),
              ),
            ],
          ),
        ),
        onTap: () async => await _handleOnTap(context, follower));
  }

  Future<void> _handleOnTap(BuildContext context, User follower) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ProfilePage(user: follower)));
    await snapshot.reference.update({'isNew': false});
  }
}
