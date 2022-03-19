import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../API/methods/feeds.dart';
import '../../repositories/post_list.dart';
import '../feeds/following.dart';
import '../../API/methods/posts.dart';
import '../../models/post.dart';
import '../../models/user.dart';
import '../post/post_page.dart';
import '../../globals.dart' as globals;
import '../../models/user.dart';
import '../../widgets/alert_circle.dart';

import 'search_page.dart';
import '../friends/chats_list.dart';

import '../profile_page/profile_page.dart';
import '../camera/camera.dart';
import '../feeds/discover.dart';
import 'activity_page.dart';
import '../../widgets/entropy_scaffold.dart';

enum PageLabel {
  discover,
  following,
  friends,
}

class HomePageProvider extends ChangeNotifier {
  // Controls the position of the home page body. When the the user scrolls
  // left or right, updates the horizontal position of the home page body. When
  // the user stops scrolling, decides if the user scrolled far enough to move
  // to a new section of the home page body and acts accordingly.

  PageLabel pageLabel = PageLabel.discover;
  double _offset = 0;

  double get offset {
    return _offset;
  }

  set offset(double offsetVelocity) {
    _offset = offsetVelocity;

    if (_offset < -.33)
      this.pageLabel = PageLabel.friends;
    else if (_offset > .33)
      this.pageLabel = PageLabel.following;
    else
      this.pageLabel = PageLabel.discover;

    notifyListeners();
  }

  void handleHorizontalDragEnd() {
    if (_offset < -.33) {
      setMainPage(PageLabel.friends);
    } else if (_offset > .33) {
      setMainPage(PageLabel.following);
    } else {
      setMainPage(PageLabel.discover);
    }
  }

  void setMainPage(PageLabel newPageLabel) {
    if (newPageLabel == PageLabel.following) {
      _offset = 1.0;
      pageLabel = PageLabel.following;
    } else if (newPageLabel == PageLabel.discover) {
      _offset = 0.0;
      pageLabel = PageLabel.discover;
    } else {
      _offset = -1.0;
      pageLabel = PageLabel.friends;
    }
    notifyListeners();
  }
}

class HomePage extends StatefulWidget {
  // The home page is broken into 2 sections: header and body. The header
  // contains all the buttons needed to navigate to other parts of the app. The
  // body contains 3 sections: discover, friends and following. Only one of
  // these sections are shown at a time, the other two are hidden. The user
  // can navigate between these sections by swiping left or right or by pressing
  // on the corresponding button found in the header.

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    globals.setUpRepositorys();
    globals.recommendationPostsRepository =
        new PostListRepository(function: getRecommendations);
    globals.followingPostsRepository =
        new PostListRepository(function: getFollowingPosts);
    _listenForFirebaseMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double headerHeight = .18 * globals.size.height;
    double bodyHeight = globals.size.height - headerHeight;

    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: ChangeNotifierProvider(
            create: (context) => HomePageProvider(),
            child: EntropyScaffold(
              body: Stack(
                children: [
                  Container(
                      // offset to put post list under nav bar
                      padding: EdgeInsets.only(top: headerHeight),
                      child: HomePageBody(height: bodyHeight)),
                  HomePageHeader(
                    height: headerHeight,
                  ),
                ],
              ),
            )));
  }

  Future<void> _listenForFirebaseMessages() async {
    await Firebase.initializeApp();

    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    _handleFirebaseMessage(initialMessage);
    FirebaseMessaging.onMessageOpenedApp
        .listen((message) => _handleFirebaseMessage(message));
  }

  Future<void> _handleFirebaseMessage(RemoteMessage message) async {
    if (message == null) {
      return;
    }
    Map data = message.data;
    globals.newActivityRepository.update();

    switch (data["type"]) {
      case "comment":
        Post post = Post.fromJson(json.decode(data["data"])["post"]);

        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostPage(
                      post: post,
                      isFullPost: true,
                      showComments: true,
                    )));
        break;
      case "new_follower":
      case "follower":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ActivityPage()),
        );
        break;
    }
  }
}

class HomePageHeader extends StatelessWidget {
  // Returns a column of header buttons and the header navigator. The buttons
  // take the user to other parts of the app, the navigator allows the user to
  // switch between the 3 sections of the home page body.

  final double height;

  HomePageHeader({this.height});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // makes the entire top navigation bar white, and makes sure that it
        // overlaps the padded areas.
        Transform(
          transform: Matrix4.diagonal3Values(4.0, 1.0, 1.0),
          child: Transform.translate(
            offset: Offset(-.5 * globals.size.width, 0),
            child: Container(
              color: Colors.white,
              height: height,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: .05 * globals.size.height),
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              HomePageHeaderButtons(),
              HomePageHeaderNavigator(),
            ],
          ),
        ),
      ],
    );
  }
}

class HomePageHeaderButtons extends StatelessWidget {
  // Returns a sandwich button that opens the home page drawer, the Entropy logo
  // that takes the user to their profile page, and a search button and a camera
  // button.
  @override
  Widget build(BuildContext context) {
    double buttonsHeight = .05 * globals.size.height;

    return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                width: .001 * globals.size.height, color: Colors.black),
          ),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                child: Container(
                    height: .8 * buttonsHeight,
                    child: Image.asset('assets/images/entropy_v1.png')),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    _cameraButton(context, buttonsHeight),
                    _activityButton(context, buttonsHeight),
                    _searchButton(context, buttonsHeight),
                    _profileButton(context, buttonsHeight),
                  ],
                ),
              )
            ]));
  }

  Widget _cameraButton(BuildContext context, double buttonsHeight) {
    return GestureDetector(
      child: _iconContainer(
          SvgPicture.asset(
            'assets/images/camera_2.svg',
          ),
          .9 * buttonsHeight),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Camera(
                  cameraUsage: CameraUsage.post,
                )),
      ),
    );
  }

  Widget _activityButton(BuildContext context, double buttonsHeight) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          child: _iconContainer(
              SvgPicture.asset('assets/images/fire.svg'), buttonsHeight),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ActivityPage()),
          ),
        ),
        StreamBuilder(
            stream: globals.newActivityRepository.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data) {
                return Transform.translate(
                  // offset for activity circle
                  offset: Offset(
                      .008 * globals.size.height, -.012 * globals.size.height),
                  child: AlertCircle(diameter: .016 * globals.size.height),
                );
              } else {
                return Container();
              }
            })
      ],
    );
  }

  Widget _searchButton(BuildContext context, double buttonsHeight) {
    return GestureDetector(
      child: _iconContainer(
          Image.asset('assets/images/search_icon.png'), buttonsHeight),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchPage()),
      ),
    );
  }

  Widget _profileButton(BuildContext context, double buttonsHeight) {
    return GestureDetector(
        child: _iconContainer(
            SvgPicture.asset('assets/images/profile.svg'), buttonsHeight),
        onTap: () async {
          User user = await globals.userRepository.get(globals.uid);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ProfilePage(user: user)));
        });
  }

  Widget _iconContainer(Widget image, double buttonsHeight) {
    return Container(
      width: buttonsHeight,
      height: buttonsHeight,
      padding: EdgeInsets.symmetric(vertical: .0075 * globals.size.height),
      child: image,
    );
  }
}

class HomePageHeaderNavigator extends StatelessWidget {
  // Resposible for letting the user switch between the 3 sections of the home
  // page body.
  const HomePageHeaderNavigator({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomePageProvider provider = Provider.of<HomePageProvider>(context);

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: .68 * globals.size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  width: .225 * globals.size.width,
                  child: _navigationButton(
                    "Following",
                    PageLabel.following,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: .225 * globals.size.width,
                  child: _navigationButton(
                    "Discover",
                    PageLabel.discover,
                  ),
                ),
                Container(
                    alignment: Alignment.center,
                    width: .225 * globals.size.width,
                    child: _navigationButton(
                      "Friends",
                      PageLabel.friends,
                    )),
              ],
            ),
          ),
          Container(
              child: Transform.translate(
                  offset: Offset(0, -.015 * globals.size.height),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: .68 * globals.size.width,
                        height: .01 * globals.size.height,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(globals.size.height),
                          color: const Color(0xffffffff),
                          border: Border.all(
                              width: 1.0, color: const Color(0xff707070)),
                        ),
                      ),
                      Transform.translate(
                          offset: Offset(
                              max(-1.0, min(-provider.offset, 1.0)) *
                                  .24 *
                                  (globals.size.width - 12),
                              0),
                          child: Container(
                            height: .00829 * globals.size.height,
                            width: .21 * globals.size.width,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          )),
                    ],
                  )))
        ],
      ),
    );
  }

  Widget _navigationButton(String pageName, PageLabel pageLabel) {
    return Consumer<HomePageProvider>(builder: (context, provider, child) {
      Color textColor = (pageLabel == provider.pageLabel)
          ? Color(0xFF000000)
          : Color(0x73000000);

      return Container(
        child: GestureDetector(
          child: Container(
            height: .04 * globals.size.height,
            child: Text(
              pageName,
              style: TextStyle(
                fontFamily: '.AppleSystemUIFont',
                fontSize: .0172 * globals.size.height,
                color: textColor,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          onTap: () {
            provider.setMainPage(pageLabel);
          },
        ),
      );
    });
  }
}

class HomePageBody extends StatefulWidget {
  // Returns the three sections of the home page body. 2 of these sections are
  // off screen at any given time. When the user swipes horizontally, this
  // widget updates the provider.
  const HomePageBody({@required this.height});

  final double height;

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  Widget _discover, _chats, _following;

  @override
  void initState() {
    _discover = Center(child: DiscoverPage(height: widget.height));
    _chats = Center(
        child: Chats(
      height: widget.height,
    ));
    _following = Center(child: FollowingPage(height: widget.height));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Consumer<HomePageProvider>(builder: (context, provider, child) {
      return GestureDetector(
        child: Container(
          height: widget.height,
          width: width,
          color: Colors.white,
          child: Stack(children: [
            Transform.translate(
                offset: Offset(width * (provider.offset - 1), 0),
                child: _following),
            Transform.translate(
                offset: Offset(width * (provider.offset), 0), child: _discover),
            Transform.translate(
                offset: Offset(width * (provider.offset + 1), 0),
                child: _chats),
          ]),
        ),
        onHorizontalDragUpdate: (value) =>
            provider.offset += 2.0 * (value.delta.dx / width),
        onHorizontalDragEnd: (_) => provider.handleHorizontalDragEnd(),
      );
    });
  }
}

const String _svg_cayeaa =
    '<svg viewBox="152.0 94.0 59.1 7.0" ><path transform="translate(152.0, 94.0)" d="M 3.691642761230469 0 L 55.37464141845703 0 C 57.41348266601562 0 59.0662841796875 1.56700325012207 59.0662841796875 3.5 C 59.0662841796875 5.43299674987793 57.41348266601562 7 55.37464141845703 7 L 3.691642761230469 7 C 1.652804613113403 7 0 5.43299674987793 0 3.5 C 0 1.56700325012207 1.652804613113403 0 3.691642761230469 0 Z" fill="#000000" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_eqwtyu =
    '<svg viewBox="9.0 11.3 17.9 15.5" ><path transform="translate(9.04, 11.25)" d="M 0 0 L 17.92163467407227 0" fill="none" stroke="#000000" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(9.04, 19.0)" d="M 0 0 L 17.92163467407227 0" fill="none" stroke="#000000" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(9.04, 26.75)" d="M 0 0 L 17.92163467407227 0" fill="none" stroke="#000000" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
