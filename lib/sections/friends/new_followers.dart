import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/relations.dart';

import '../../models/user.dart';
import '../../widgets/profile_pic.dart';

import '../profile/profile_page.dart';

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

class NewFollowersPage extends StatelessWidget {
  // Returns a list of all new followers. This widget is updated every time the
  // user decides to "follow back" or "not follow back" a particular new
  // follower.
  NewFollowersPage({@required this.newFollowersList});

  final List<User> newFollowersList;

  final double headHeightPercent = .15;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
        create: (_) => NewFollowersProvider(newFollowersList: newFollowersList),
        child: Consumer<NewFollowersProvider>(
          builder: (consumerContext, provider, child) => Scaffold(
            backgroundColor: const Color(0xffffffff),
            appBar: NewFollowersAppBar(
              height: headHeightPercent * height,
            ),
            body: Container(
              height: (1 - headHeightPercent) * height,
              child: ListView.builder(
                itemCount: provider.newFollowersList.length,
                itemBuilder: (context, index) {
                  return NewFollower(
                    newFollower: provider.newFollowersList[index],
                  );
                },
              ),
            ),
          ),
        ));
  }
}

class NewFollowersAppBar extends PreferredSize {
  final double height;

  NewFollowersAppBar({@required this.height});

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

class NewFollower extends StatelessWidget {
  final User newFollower;

  NewFollower({@required this.newFollower});

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
          delegate: NewFollowerDelegate(
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
                child: AcceptDeclineWidget(
                  size: acceptDeclineSize,
                  newFollower: newFollower,
                )),
          ],
        ));
  }
}

class NewFollowerDelegate extends MultiChildLayoutDelegate {
  final Size profileSize;
  final Size acceptDeclineSize;
  final double padding;

  NewFollowerDelegate(
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
  bool shouldRelayout(NewFollowerDelegate oldDelegate) {
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
              user: newFollower,
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

class AcceptDeclineWidget extends StatefulWidget {
  const AcceptDeclineWidget(
      {Key key, @required this.newFollower, @required this.size})
      : super(key: key);

  final User newFollower;
  final Size size;

  @override
  _AcceptDeclineWidgetState createState() => _AcceptDeclineWidgetState();
}

class _AcceptDeclineWidgetState extends State<AcceptDeclineWidget> {
  bool acceptDeclinePressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
              child: AcceptDeclineButton(
                  size: widget.size,
                  name: "Follow Back",
                  color: const Color(0xff22a2ff)),
              onTap: () async => await _followBack(context, true)),
          GestureDetector(
            child: AcceptDeclineButton(
                size: widget.size,
                name: "Don't Follow Back",
                color: const Color(0xffff0000)),
            onTap: () => _followBack(context, false),
          ),
        ],
      ),
    );
  }

  Future<void> _followBack(BuildContext context, bool willFollowBack) async {
    if (!acceptDeclinePressed) {
      setState(() {
        acceptDeclinePressed = true;
      });
      if (willFollowBack)
        await followBack(widget.newFollower);
      else
        await dontFollowBack(widget.newFollower);

      Provider.of<NewFollowersProvider>(context, listen: false)
          .removeNewFollower(widget.newFollower);
    }
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
