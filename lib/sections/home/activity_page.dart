import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/widgets/profile_pic.dart';

import '../../models/user.dart';
import '../../models/post.dart';
import '../../globals.dart' as globals;
import '../../widgets/back_arrow.dart';
import '../../widgets/alert_circle.dart';
import '../../API/methods/users.dart';

import '../profile_page/profile_page.dart';
import '../post/post_widget.dart';
import '../post/post_page.dart';

class ActivityProvider extends ChangeNotifier {
  bool _onlyShowNewFollowers = false;
  CollectionReference<Map<String, dynamic>> activityCollection =
      FirebaseFirestore.instance
          .collection('ACTIVITY')
          .doc(globals.uid)
          .collection('activity');

  bool get onlyShowNewFollowers => _onlyShowNewFollowers;

  set onlyShowNewFollowers(bool onlyShowNewFollowers) {
    _onlyShowNewFollowers = onlyShowNewFollowers;
    notifyListeners();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get activitiesStream =>
      activityCollection.orderBy('time', descending: true).snapshots();

  void toggleOnyShowNewFollowers() =>
      onlyShowNewFollowers = !onlyShowNewFollowers;

  Future<void> setNotNew(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) async {
    await snapshot.reference.update({'isNew': false});
  }

  Future<void> followBack(snapshot) async {
    User follower = User.fromJson(
      snapshot.data()['data']['follower'],
    );

    await globals.followingRepository.follow(follower);
    await snapshot.reference.delete();
  }

  Future<void> dontFollowBack(snapshot) async {
    User follower = User.fromJson(
      snapshot.data()['data']['follower'],
    );

    await dontFollowBack(follower);
    await snapshot.reference.delete();
  }

  Future<void> setIsUpdated() => globals.newActivityRepository.update();
}

class ActivityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider(
            create: (context) => ActivityProvider(),
            child: Consumer<ActivityProvider>(
                builder: (context, provider, snapshot) => Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: .03 * globals.size.height,
                              right: .03 * globals.size.height),
                          height: .15 * globals.size.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                      child: BackArrow(),
                                      onTap: () => Navigator.pop(context)),
                                ],
                              ),
                              Center(
                                child: Text("Activity",
                                    style: TextStyle(
                                        fontSize: .05 * globals.size.height)),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                            child: Container(
                                width: .35 * globals.size.width,
                                height: .03 * globals.size.height,
                                margin: EdgeInsets.symmetric(
                                    vertical: .01 * globals.size.height),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey[400], width: 2),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Center(
                                    child: Text(
                                        provider.onlyShowNewFollowers
                                            ? "All Activity"
                                            : "New Followers",
                                        style: TextStyle(
                                            fontSize:
                                                .02 * globals.size.height)))),
                            onTap: () => provider.toggleOnyShowNewFollowers()),
                        StreamBuilder(
                            stream: provider.activitiesStream.map((snapshot) {
                          return snapshot.docs.map((snapshot) {
                            return _getActivityItem(
                                snapshot, provider.onlyShowNewFollowers);
                          }).toList();
                        }), builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            provider.setIsUpdated();

                            return Expanded(
                                child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: .02 * globals.size.width),
                              child: ListView.builder(
                                  padding: EdgeInsets.only(top: 0),
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) =>
                                      snapshot.data[index]),
                            ));
                          } else {
                            return Container();
                          }
                        }),
                      ],
                    ))));
  }

  Widget _getActivityItem(var snapshot, bool onlyShowNewFollowers) {
    Map docData = snapshot.data();

    if (onlyShowNewFollowers && docData['type'] != 'new_follower')
      return Container();

    return Container(
        height: .1 * globals.size.height,
        child: Row(children: [
          snapshot.data()['isNew']
              ? Container(
                  width: .05 * globals.size.width,
                  child: Center(
                      child: AlertCircle(
                    diameter: .02 * globals.size.width,
                  )),
                )
              : Container(
                  width: .05 * globals.size.width,
                ),
          Expanded(child: Container(child: _getActivityWidget(snapshot)))
        ]));
  }

  Widget _getActivityWidget(var snapshot) {
    switch (snapshot.data()['type']) {
      case 'comment':
        return ActivityCommentWidget(snapshot: snapshot);
      case 'new_follower':
        return ActivityNewFollowerWidget(
          snapshot: snapshot,
        );
      case 'follower':
        return ActivityFollowerWidget(
          snapshot: snapshot,
        );

      default:
        return Container();
    }
  }
}

class ActivityCommentWidget extends StatelessWidget {
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
    await Provider.of<ActivityProvider>(context, listen: false)
        .setNotNew(snapshot);
  }
}

class ActivityNewFollowerWidget extends StatelessWidget {
  ActivityNewFollowerWidget({@required this.snapshot});

  final QueryDocumentSnapshot<Map<String, dynamic>> snapshot;

  @override
  Widget build(BuildContext context) {
    ActivityProvider provider =
        Provider.of<ActivityProvider>(context, listen: false);

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
                  onTap: () => provider.followBack(snapshot)),
              GestureDetector(
                  child: _acceptDeclineButton(.06 * globals.size.height,
                      "Don't Follow Back", const Color(0xffff0000)),
                  onTap: () => provider.dontFollowBack(snapshot)),
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
}

class ActivityFollowerWidget extends StatelessWidget {
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
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilePage(user: follower)));
          await Provider.of<ActivityProvider>(context, listen: false)
              .setNotNew(snapshot);
        });
  }
}
