import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter/widgets/profile_pic.dart';

import '../../models/user.dart';
import '../../models/post.dart';
import '../../globals.dart' as globals;
import '../../widgets/back_arrow.dart';
import '../../API/handle_requests.dart';
import '../../API/methods/followings.dart';

import '../post/post_view.dart';
import '../post/post.dart';

class ActivityPage extends StatelessWidget {
  // Returns a page with all of a user's activities. This page is broken up into
  // two parts: a header and a body. The header displays the page's name and a
  // button that returns to the previous page. The body contains a list of all
  // of the user's activities.
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
  // The activity page's header. Displays a back button and the page's name.
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
  // Sets up a stream that connects to a firebase collection containing all of
  // the user's activity. There are different types of documents in this
  // collection, each corresponding to a different type of activity. This widget
  // determines which StatelessWidget to build based on the document's type.
  // Displays a button on the top of the widget that lets the user change
  // between showing all activity or only new followers.

  ActivityPageBody({@required this.height});

  final double height;

  @override
  _ActivityPageBodyState createState() => _ActivityPageBodyState();
}

class _ActivityPageBodyState extends State<ActivityPageBody> {
  bool showOnlyNewFollowers;

  @override
  void initState() {
    super.initState();
    showOnlyNewFollowers = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
            top: .02 * globals.size.height,
            left: .04 * globals.size.width,
            right: .04 * globals.size.width),
        height: widget.height,
        child: Column(
          children: [
            GestureDetector(
                child: ActivityToggleButton(
                  buttonName:
                      (showOnlyNewFollowers) ? "all activity" : "new followers",
                  color: Colors.white,
                ),
                onTap: () {
                  setState(() {
                    showOnlyNewFollowers = !showOnlyNewFollowers;
                  });
                }),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('ACTIVITY')
                  .doc(globals.user.uid)
                  .collection('activity')
                  .orderBy('time')
                  .snapshots()
                  .map((snapshot) {
                return snapshot.docs.map((doc) {
                  Map docData = doc.data();
                  if (showOnlyNewFollowers && docData['type'] != 'new_follower')
                    return Container();

                  switch (docData['type']) {
                    case 'comment':
                      return ActivityCommentWidget(
                          commenter:
                              User.fromJson(docData['data']['commenter']),
                          post: Post.fromJson(docData['data']['post']));
                    case 'new_follower':
                      return ActivityNewFollowerWidget(
                          follower: User.fromJson(
                            docData['data']['follower'],
                          ),
                          firestoreDocId: doc.id);
                    case 'follower':
                      return ActivityFollowerWidget(
                          follower: User.fromJson(docData['data']['follower']));

                    default:
                      return Container();
                  }
                }).toList();
              }),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: .02 * globals.size.height),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return snapshot.data[index];
                      },
                    ),
                  );
                } else {
                  return Container();
                }
              },
            )
          ],
        ));
  }
}

class ActivityToggleButton extends StatelessWidget {
  // Stateless widget that lets user change between showing all activity or only
  // new followers.
  ActivityToggleButton({@required this.buttonName, @required this.color});
  final String buttonName;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
  // Stateless widget responsible for showing that a commenter has commented on
  // on of the user's posts. When tapped, takes the user to the post that has
  // been commented on.

  ActivityCommentWidget({@required this.commenter, @required this.post});

  final User commenter;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          color: Colors.transparent,
          height: .1 * globals.size.height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ProfilePic(
                      diameter: .06 * globals.size.height, user: commenter),
                  Container(
                    padding: EdgeInsets.only(left: .02 * globals.size.width),
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
              PostView(
                  post: post,
                  height: .08 * globals.size.height,
                  aspectRatio: 4 / 3,
                  postStage: PostStage.onlyPost)
            ],
          ),
        ),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostPage(
                      post: post,
                    ))));
  }
}

class ActivityNewFollowerWidget extends StatelessWidget {
  // Shows that a new person has started following the user. Allows the user to
  // follow/not follow back the new follower. When one of these options are
  // selected, deletes the document containing the new follower activity from
  // firestore.
  ActivityNewFollowerWidget(
      {@required this.follower, @required this.firestoreDocId});

  final User follower;
  final String firestoreDocId;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: .1 * globals.size.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(right: .04 * globals.size.width),
              child: Row(
                children: [
                  ProfilePic(
                      diameter: .06 * globals.size.height, user: follower),
                  Container(
                    padding: EdgeInsets.only(left: .02 * globals.size.width),
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
                              text: "Started following you",
                              style: TextStyle(
                                  fontSize: .016 * globals.size.height))
                        ])),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                      child: AcceptDeclineButton(
                          height: .06 * globals.size.height,
                          name: "Follow Back",
                          color: const Color(0xff22a2ff)),
                      onTap: () async => await _followBack(context, true)),
                  GestureDetector(
                    child: AcceptDeclineButton(
                        height: .06 * globals.size.height,
                        name: "Don't Follow Back",
                        color: const Color(0xffff0000)),
                    onTap: () => _followBack(context, false),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Future<void> _followBack(BuildContext context, bool willFollowBack) async {
    if (willFollowBack)
      await handleRequest(context, startFollowing(follower));
    else
      await handleRequest(context, dontFollowBack(follower));

    await FirebaseFirestore.instance
        .collection('ACTIVITY')
        .doc(globals.user.uid)
        .collection('activity')
        .doc(firestoreDocId)
        .delete();
  }
}

class AcceptDeclineButton extends StatelessWidget {
  const AcceptDeclineButton({
    Key key,
    @required this.height,
    @required this.name,
    @required this.color,
  }) : super(key: key);

  final double height;
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
}

class ActivityFollowerWidget extends StatelessWidget {
  // Simply displays that someone started following the user.
  ActivityFollowerWidget({@required this.follower});
  final User follower;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: .1 * globals.size.height,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: EdgeInsets.only(right: .04 * globals.size.width),
            child: Row(
              children: [
                ProfilePic(diameter: .06 * globals.size.height, user: follower),
                Container(
                  padding: EdgeInsets.only(left: .02 * globals.size.width),
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
          )
        ]));
  }
}
