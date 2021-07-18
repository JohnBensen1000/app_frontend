import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/handle_requests.dart';

import '../../globals.dart' as globals;
import '../../API/methods/relations.dart';
import '../../API/methods/posts.dart';
import '../../models/user.dart';
import '../../models/post.dart';

import '../../widgets/profile_pic.dart';
import '../../widgets/back_arrow.dart';
import '../../widgets/alert_dialog_container.dart';
import '../../widgets/generic_alert_dialog.dart';

import '../post/post_view.dart';
import 'settings_drawer.dart';

class ProfileProvider extends ChangeNotifier {
  // Simply keeps track of if the setting should be open or closed.
  bool _isSettingsOpen = false;

  bool get isSettingsOpen => _isSettingsOpen;

  set isSettingsOpen(newIsSettingsOpen) {
    _isSettingsOpen = newIsSettingsOpen;
    notifyListeners();
  }
}

class ProfilePage extends StatelessWidget {
  // Returns a stack of the profile page and the settings drawer. Only displays
  // the settings drawer if it has been opened. The settings drawer contains
  // a Settings widget that is placed on top of the profile page (hence the need
  // for a stack).
  ProfilePage({@required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    double headerHeight = 350;
    double settingsWidth = 275;

    double bodyHeight = MediaQuery.of(context).size.height - headerHeight;

    return ChangeNotifierProvider(
        create: (context) => ProfileProvider(),
        child: Scaffold(
            body: Stack(
          children: [
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ProfilePageHeader(
                    user: user,
                    height: headerHeight,
                  ),
                  ProfilePostBody(
                      user: user,
                      height: bodyHeight,
                      sidePadding: 20,
                      betweenPadding: 5),
                ],
              ),
            ),
            Consumer<ProfileProvider>(
                builder: (context, provider, child) => (provider.isSettingsOpen)
                    ? SettingsDrawer(width: settingsWidth)
                    : Container())
          ],
        )));
  }
}

class ProfilePageHeader extends StatelessWidget {
  // Part of profile page that stays static as the user scrolls through the
  // creator's posts. Displays the creator's profile pic, username and userID.
  // Also displays a button that lets the user start/stop following this
  // creator.

  ProfilePageHeader({
    @required this.user,
    @required this.height,
  });

  final User user;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 10),
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.only(top: 40, left: 20, bottom: 20),
              child: Row(
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Center(child: BackArrow()))),
                ],
              ),
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Consumer<ProfileProvider>(
                      builder: (context, provider, child) =>
                          ProfilePic(diameter: 148, user: user)),
                  Container(
                    child: Text(
                      '${user.username}',
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
                      '@${user.userID}',
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
                  if (user.uid != globals.user.uid)
                    FollowBlockButtons(user: user)
                  else
                    OpenSettingsButton(),
                ]),
          ],
        ));
  }
}

class FollowBlockButtons extends StatefulWidget {
  // Returns a row of two buttons: Follow/Following and Block.
  // The Follow/Following button allows the user to follow the creator if they
  // are currently not following them, and allows the user to unfollower the
  // creator if they are currently following them. This widget is rebuilt every
  // time this button is pressed. The Block button allows the user to block the
  // creator. When pressed, an alert dialog is displayed to confirm the user's
  // decision. When confirmed, the profile page is popped.

  const FollowBlockButtons({
    @required this.user,
    Key key,
  }) : super(key: key);

  final User user;

  @override
  _FollowBlockButtonsState createState() => _FollowBlockButtonsState();
}

class _FollowBlockButtonsState extends State<FollowBlockButtons> {
  bool allowChangeFollow = true;
  bool isFollowing;

  @override
  Widget build(BuildContext context) {
    double followButtonWidth = 100;

    return Container(
      width: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FutureBuilder(
              future: handleRequest(context, getIfFollowing(widget.user)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  isFollowing = snapshot.data;
                  return GestureDetector(
                    child: ProfilePageHeaderButton(
                        name: (isFollowing) ? "Following" : "Follow",
                        color: (isFollowing)
                            ? Colors.white
                            : widget.user.profileColor,
                        borderColor: widget.user.profileColor,
                        width: followButtonWidth),
                    onTap: () async {
                      if (allowChangeFollow) {
                        allowChangeFollow = false;
                        await changeFollowing(context);
                        allowChangeFollow = true;
                      }
                    },
                  );
                } else
                  return Container(
                    height: 28.0,
                    width: followButtonWidth,
                  );
              }),
          GestureDetector(
            child: ProfilePageHeaderButton(
              name: "Block",
              borderColor: Colors.black,
              color: Colors.white,
              width: 75,
            ),
            onTap: () => showDialog(
                context: context,
                builder: (context) {
                  return AlertDialogContainer(
                      dialogText:
                          "Are you sure you want to block ${widget.user.userID}?");
                }).then((isBlockingUser) async {
              if (isBlockingUser) {
                await handleRequest(context, postBlockedUser(widget.user));
                await showDialog(
                    context: context,
                    builder: (context) => GenericAlertDialog(
                        text:
                            "You have successfully blocked this user, so you will no longer see any content from them."));
                Navigator.pop(context);
              }
            }),
          )
        ],
      ),
    );
  }

  Future<void> changeFollowing(BuildContext context) async {
    (isFollowing)
        ? await handleRequest(context, postStopFollowing(widget.user))
        : await handleRequest(context, postStartFollowing(widget.user));

    isFollowing = !isFollowing;

    setState(() {});
  }
}

class OpenSettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ProfileProvider provider =
        Provider.of<ProfileProvider>(context, listen: false);

    return GestureDetector(
        child: ProfilePageHeaderButton(
          width: 125,
          name: "Settings",
          color: Colors.grey[200],
          borderColor: Colors.grey[200],
        ),
        onTap: () => provider.isSettingsOpen = true);
  }
}

class ProfilePageHeaderButton extends StatelessWidget {
  const ProfilePageHeaderButton(
      {Key key,
      @required this.name,
      @required this.color,
      @required this.borderColor,
      @required this.width})
      : super(key: key);

  final String name;
  final Color color;
  final Color borderColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28.0,
      width: width,
      decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2.0),
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Center(
        child: Text(
          name,
          style: TextStyle(
            fontFamily: 'Helvetica Neue',
            fontSize: 20,
            color: const Color(0xff000000),
          ),
        ),
      ),
    );
  }
}

class ProfilePostBody extends StatefulWidget {
  // Gets and returns a all of the creator's publics posts. The posts are
  // organized into a list of widgets. This list runs vertically and starts off
  // with a big ProfilePostWidget() that takes up the entire width of the page.
  // The rest of the list is a series of Rows(), each row is made of up 3
  // ProfilePostWidget().

  ProfilePostBody({
    @required this.user,
    @required this.height,
    @required this.sidePadding,
    @required this.betweenPadding,
    this.rowSize = 3,
  });

  final User user;
  final double height;
  final double sidePadding;
  final double betweenPadding;
  final int rowSize;

  @override
  _ProfilePostBodyState createState() => _ProfilePostBodyState();
}

class _ProfilePostBodyState extends State<ProfilePostBody> {
  Future<dynamic> postListFuture;

  @override
  void initState() {
    super.initState();
    postListFuture = handleRequest(context, getUsersPosts(widget.user));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.length == 0)
              return Center(child: Text("Nothing to display"));
            else {
              List<Widget> profilePostsList =
                  _getProfilePostsList(context, snapshot.data);

              return Padding(
                padding: EdgeInsets.only(
                    left: widget.sidePadding, right: widget.sidePadding),
                child: SizedBox(
                  height: widget.height,
                  child: new ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    itemCount: profilePostsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return PostBodyWidget(child: profilePostsList[index]);
                    },
                  ),
                ),
              );
            }
          } else {
            return Container();
          }
        });
  }

  List<Widget> _getProfilePostsList(BuildContext context, List<Post> postList) {
    // Determines width and height for every post on the profile page. The first
    // widget in the return list is a large ProfilePostWidget(). The remaining
    // posts are broken up into rows of rowSize (int) ProfilePostWidget().

    double width = MediaQuery.of(context).size.width;
    double mainPostHeight =
        (width - 2 * widget.sidePadding) / globals.goldenRatio;
    double bodyPostHeight =
        (((width - 2 * widget.sidePadding) / widget.rowSize) -
                widget.betweenPadding) *
            globals.goldenRatio;

    List<Widget> profilePosts = [
      Padding(
        padding: EdgeInsets.only(bottom: widget.betweenPadding),
        child: PostView(
            post: postList[0],
            height: mainPostHeight,
            aspectRatio: 1 / globals.goldenRatio,
            postStage: PostStage.onlyPost),
      )
    ];

    List<Widget> subPostsList = _getSubPostsList(postList, bodyPostHeight);

    for (int i = 0; i < subPostsList.length; i += widget.rowSize) {
      profilePosts.add(Padding(
        padding: EdgeInsets.only(bottom: widget.betweenPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: subPostsList.sublist(i, i + widget.rowSize),
        ),
      ));
    }
    return profilePosts;
  }

  List<Widget> _getSubPostsList(List<dynamic> postList, double postHeight) {
    // Creates a list of the remaining posts (not the main post). Adds empty
    // containers so that the return list is evenly divisible by rowSize (int).

    List<Widget> subPostsList = [];
    int i = 1;

    while ((i < postList.length) || ((i - 1) % widget.rowSize != 0)) {
      if (i < postList.length) {
        subPostsList.add(
          PostView(
              post: postList[i],
              height: postHeight,
              aspectRatio: globals.goldenRatio,
              postStage: PostStage.onlyPost),
        );
      } else {
        subPostsList.add(
          Container(
            height: postHeight,
            width: postHeight / globals.goldenRatio,
          ),
        );
      }
      i++;
    }
    return subPostsList;
  }
}

class PostBodyWidget extends StatefulWidget {
  // The entire point of this widget is to keep each element in profile body's
  // ListView.builder() alive when scrolling down. That way, it doesn't jump to
  // the top when scrolling up.
  PostBodyWidget({@required this.child});

  final Widget child;

  @override
  _PostBodyWidgetState createState() => _PostBodyWidgetState();
}

class _PostBodyWidgetState extends State<PostBodyWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

const String _svg_cdsk62 =
    '<svg viewBox="289.0 36.0 57.0 11.0" ><path transform="translate(289.0, 36.0)" d="M 6.397959232330322 0 L 50.60204315185547 0 C 54.13554000854492 0 57.00000381469727 2.462433815002441 57.00000381469727 5.5 C 57.00000381469727 8.537566184997559 54.13554000854492 11 50.60204315185547 11 L 6.397959232330322 11 C 2.864464044570923 11 0 8.537566184997559 0 5.5 C 0 2.462433815002441 2.864464044570923 0 6.397959232330322 0 Z" fill="#22a2ff" stroke="#22a2ff" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_jmyh3o =
    '<svg viewBox="119.5 286.0 136.0 1.0" ><path transform="translate(119.5, 286.0)" d="M 0 0 L 136 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
