import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../globals.dart' as globals;
import '../../API/relations.dart';
import '../../API/posts.dart';
import '../../models/user.dart';
import '../../models/post.dart';

import '../../widgets/profile_pic.dart';
import '../../widgets/back_arrow.dart';

import '../post/post_view.dart';

class ProfilePageProvider extends ChangeNotifier {
  // Keeps track of whether the user is following or not following a creator.
  // Sends http post to server if the user decideds to start following the
  // creator, and a http delete to server if the user decides to stops following
  // the creator.

  final double height;
  final User user;

  Color followingColor;
  String followingText;
  bool isFollowing;

  ProfilePageProvider({this.height, this.user}) {
    followingText = "Loading...";
    _checkIfFollowing();
  }

  Future<void> _checkIfFollowing() async {
    isFollowing = await checkIfFollowing(user);
    _setFollowingButton();
  }

  Future<void> changeFollowing() async {
    (isFollowing) ? await stopFollowing(user) : await startFollowing(user);

    isFollowing = !isFollowing;
    _setFollowingButton();
  }

  void _setFollowingButton() {
    if (isFollowing) {
      followingColor = Colors.grey[300];
      followingText = "Following";
    } else {
      followingColor = Colors.white;
      followingText = "Follow";
    }
    notifyListeners();
  }
}

class ProfilePage extends StatelessWidget {
  ProfilePage({@required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    double appBarHeight = 50;
    double height = MediaQuery.of(context).size.height - appBarHeight;

    return Scaffold(
        appBar: ProfilePageAppBar(height: appBarHeight),
        body: ChangeNotifierProvider(
            create: (context) =>
                ProfilePageProvider(height: .4 * height, user: user),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ProfilePageHeader(user: user),
                  if (user.uid != globals.user.uid) FollowingButton(),
                  ProfilePostBody(
                      height: .654 * height,
                      sidePadding: 20,
                      betweenPadding: 5),
                ],
              ),
            )));
  }
}

class ProfilePageAppBar extends PreferredSize {
  // Top of profile page. Lets the user access their exit the profile page.

  ProfilePageAppBar({this.height});
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20, left: 20),
      child: Row(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Center(child: BackArrow()))),
        ],
      ),
    );
  }
}

class ProfilePageHeader extends StatelessWidget {
  // Part of profile page that stays static as the user scrolls through the
  // creator's posts. Displays the creator's profile pic, username and userID.
  // Also displays a button that lets the user start/stop following this
  // creator.

  ProfilePageHeader({
    @required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 15,
          ),
          ProfilePic(diameter: 148, user: user),
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
        ]);
  }
}

class FollowingButton extends StatefulWidget {
  // Button that lets you follow/unfollow someone else. The color/text of this
  // button is determined by the ProfilePageProvider. This widget is rebuilt
  // every time the user starts/stops following the other person.

  const FollowingButton({
    Key key,
  }) : super(key: key);

  @override
  _FollowingButtonState createState() => _FollowingButtonState();
}

class _FollowingButtonState extends State<FollowingButton> {
  bool allowChangeFollow = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfilePageProvider>(
      builder: (context, provider, child) {
        return FlatButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            width: 125.0,
            height: 31.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: provider.followingColor,
              border: Border.all(width: 1.0, color: const Color(0xff707070)),
            ),
            child: Center(
              child: Text(
                provider.followingText,
                style: TextStyle(
                  fontFamily: 'Helvetica Neue',
                  fontSize: 20,
                  color: const Color(0xff000000),
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          onPressed: () async {
            if (allowChangeFollow) {
              allowChangeFollow = false;
              await Provider.of<ProfilePageProvider>(context, listen: false)
                  .changeFollowing();
              allowChangeFollow = true;
            }
          },
        );
      },
    );
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
      @required this.sidePadding,
      @required this.betweenPadding});

  final double height;
  final double sidePadding;
  final double betweenPadding;

  @override
  Widget build(BuildContext context) {
    ProfilePageProvider provider =
        Provider.of<ProfilePageProvider>(context, listen: false);
    return FutureBuilder(
        future: getUsersPosts(provider.user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.length == 0)
              return Container();
            else {
              List<Widget> profilePostsList =
                  _getProfilePostsList(context, snapshot.data);

              return Padding(
                padding: EdgeInsets.only(left: sidePadding, right: sidePadding),
                child: SizedBox(
                  height: height,
                  child: new ListView.builder(
                    itemCount: profilePostsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return PostBodyWidget(child: profilePostsList[index]);
                    },
                  ),
                ),
              );
            }
          } else {
            return Center(child: Text("Nothing to display"));
          }
        });
  }

  List<Widget> _getProfilePostsList(BuildContext context, List<Post> postList) {
    // Determines width and height for every post on the profile page. The first
    // widget in the return list is a large ProfilePostWidget(). The remaining
    // posts are broken up into rows of 3 ProfilePostWidget().

    double width = MediaQuery.of(context).size.width;
    double mainPostHeight = (width - 2 * sidePadding) / globals.goldenRatio;
    double bodyPostHeight = (((width - 2 * sidePadding) / 3) - betweenPadding) *
        globals.goldenRatio;

    List<Widget> profilePosts = [
      Padding(
        padding: EdgeInsets.only(bottom: betweenPadding),
        child: PostView(
            post: postList[0],
            height: mainPostHeight,
            aspectRatio: 1 / globals.goldenRatio,
            postStage: PostStage.onlyPost),
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
