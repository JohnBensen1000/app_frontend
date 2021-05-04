import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'models/user.dart';

import 'profile_pic.dart';
import 'profile_page.dart';
import 'backend_connect.dart';
import 'globals.dart' as globals;

ServerAPI serverAPI = new ServerAPI();

class NewFollowersProvider extends ChangeNotifier {
  // Maintains state of newFollowersList. Whenever an item is removed from this
  // list, notifies all listeners.

  NewFollowersProvider({@required this.newFollowersList});

  List<User> newFollowersList;

  void removeNewFollower(User newFollower) {
    newFollowersList.remove(newFollower);

    notifyListeners();
  }
}

class NewFollowersPageState extends StatelessWidget {
  NewFollowersPageState({@required this.newFollowersList});

  final List<User> newFollowersList;

  final double headHeightPercent = .15;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: const Color(0xffffffff),
        appBar: NewFollowerAppBar(
          height: headHeightPercent * height,
        ),
        body: ChangeNotifierProvider(
          create: (_) =>
              NewFollowersProvider(newFollowersList: newFollowersList),
          child: NewFollowersPage(
              headHeightPercent: headHeightPercent, height: height),
        ));
  }
}

class NewFollowersPage extends StatelessWidget {
  const NewFollowersPage({
    Key key,
    @required this.headHeightPercent,
    @required this.height,
  }) : super(key: key);

  final double headHeightPercent;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Consumer<NewFollowersProvider>(
      builder: (consumerContext, provider, child) => Container(
        height: (1 - headHeightPercent) * height,
        child: ListView.builder(
          itemCount: provider.newFollowersList.length,
          itemBuilder: (context, index) {
            return NewFollowerWidget(
              newFollower: provider.newFollowersList[index],
            );
          },
        ),
      ),
    );
  }
}

class NewFollowerAppBar extends PreferredSize {
  final double height;

  NewFollowerAppBar({@required this.height});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
            child: Text(
          "New Followers",
          style: TextStyle(fontSize: 18),
        )),
        Container(
            padding: EdgeInsets.only(top: 40, left: 20),
            child: GestureDetector(
              child: Text(
                "Back",
              ),
              onTap: () => Navigator.pop(context),
            )),
      ],
    );
  }
}

class NewFollowerWidget extends StatelessWidget {
  final User newFollower;

  NewFollowerWidget({@required this.newFollower});

  @override
  Widget build(BuildContext context) {
    Size profileSize = new Size(180, 80);
    Size acceptDeclineSize = new Size(110, 50);

    return Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: Colors.grey[400]),
                bottom: BorderSide(color: Colors.grey[400]))),
        height: 150,
        child: CustomMultiChildLayout(
          delegate: NewFollowingWidgetDelegate(
              profileSize: profileSize,
              acceptDeclineSize: acceptDeclineSize,
              padding: 20),
          children: [
            LayoutId(
                id: 0,
                child: NewFollowerProfile(
                    newFollower: newFollower, size: profileSize)),
            LayoutId(
                id: 1,
                child: NewFollowerAcceptDecline(
                  size: acceptDeclineSize,
                  newFollower: newFollower,
                )),
          ],
        ));
  }
}

class NewFollowingWidgetDelegate extends MultiChildLayoutDelegate {
  final Size profileSize;
  final Size acceptDeclineSize;
  final double padding;

  NewFollowingWidgetDelegate(
      {@required this.profileSize,
      @required this.acceptDeclineSize,
      @required this.padding});

  @override
  void performLayout(Size size) {
    layoutChild(0, BoxConstraints.loose(size));
    layoutChild(1, BoxConstraints.loose(size));

    positionChild(0, Offset(padding, padding));
    positionChild(
        1,
        Offset(size.width - acceptDeclineSize.width - padding,
            size.height - acceptDeclineSize.height - padding));
  }

  @override
  bool shouldRelayout(NewFollowingWidgetDelegate oldDelegate) {
    return false;
  }
}

class NewFollowerProfile extends StatelessWidget {
  const NewFollowerProfile(
      {Key key, @required this.newFollower, @required this.size})
      : super(key: key);

  final User newFollower;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ProfilePic(
              diameter: size.height,
              profileUserID: newFollower.userID,
            ),
            Text(newFollower.username,
                textAlign: TextAlign.left, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilePage(
                  user: User(
                      userID: newFollower.userID,
                      username: newFollower.username)))),
    );
  }
}

class NewFollowerAcceptDecline extends StatelessWidget {
  const NewFollowerAcceptDecline(
      {Key key, @required this.newFollower, @required this.size})
      : super(key: key);

  final User newFollower;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
              child: AcceptDeclineButton(
                  size: size,
                  name: "Follow Back",
                  color: const Color(0xff22a2ff)),
              onTap: () async => await _followBack(context, true)),
          GestureDetector(
            child: AcceptDeclineButton(
                size: size,
                name: "Don't Follow Back",
                color: const Color(0xffff0000)),
            onTap: () => _followBack(context, false),
          ),
        ],
      ),
    );
  }

  Future<void> _followBack(BuildContext context, bool followBack) async {
    String url = serverAPI.url +
        "users/${globals.userID}/following/${newFollower.userID}/";

    Map<dynamic, dynamic> postBody = {"followBack": followBack.toString()};
    var response = await http.post(url, body: postBody);

    if (response.statusCode == 201) {}

    Provider.of<NewFollowersProvider>(context, listen: false)
        .removeNewFollower(newFollower);
  }
}

class AcceptDeclineButton extends StatelessWidget {
  const AcceptDeclineButton({
    Key key,
    @required this.size,
    @required this.name,
    @required this.color,
  }) : super(key: key);

  final Size size;
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.height,
      height: size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13.0),
        color: color,
        border: Border.all(width: 1.0, color: const Color(0xffffffff)),
      ),
      child: (Center(
          child: Text(name,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12)))),
    );
  }
}
