import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test_flutter/API/methods/feeds.dart';
import 'package:test_flutter/repositories/post_list.dart';
import 'package:test_flutter/sections/feeds/following.dart';

import '../../repositories/blocked.dart';
import '../../repositories/chats.dart';
import '../../repositories/following.dart';
import '../../repositories/new_activity.dart';
import '../../repositories/profile.dart';
import '../../repositories/user.dart';

import '../../globals.dart' as globals;
import '../../models/user.dart';
import '../../widgets/alert_circle.dart';

import 'home_drawer.dart';
import 'search_page.dart';
import '../friends/chats_list.dart';

import '../profile_page/profile_page.dart';
import '../camera/camera.dart';
import '../feeds/discover.dart';

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

  PageLabel pageLabel = PageLabel.following;
  double _offset = 0;

  double get offset {
    return _offset;
  }

  set offset(double offsetVelocity) {
    _offset = offsetVelocity;

    if (_offset < -.33)
      this.pageLabel = PageLabel.friends;
    else if (_offset > .33)
      this.pageLabel = PageLabel.discover;
    else
      this.pageLabel = PageLabel.following;

    notifyListeners();
  }

  void handleHorizontalDragEnd() {
    if (_offset < -.33) {
      setMainPage(PageLabel.friends);
    } else if (_offset > .33) {
      setMainPage(PageLabel.discover);
    } else {
      setMainPage(PageLabel.following);
    }
  }

  void setMainPage(PageLabel newPageLabel) {
    if (newPageLabel == PageLabel.following) {
      _offset = 0.0;
      pageLabel = PageLabel.following;
    } else if (newPageLabel == PageLabel.discover) {
      _offset = 1.0;
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double headerHeight = .18 * globals.size.height;
    double bodyHeight = MediaQuery.of(context).size.height - headerHeight;

    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: ChangeNotifierProvider(
            create: (context) => HomePageProvider(),
            child: Scaffold(
              body: Stack(
                children: [
                  Container(
                      padding: EdgeInsets.only(top: headerHeight),
                      child: HomePageBody(height: bodyHeight)),
                  HomePageHeader(
                    height: headerHeight,
                  ),
                ],
              ),
              drawer: Container(
                  width: .7 * globals.size.width,
                  child: Drawer(child: HomeDrawer())),
            )));
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
    return Container(
      padding: EdgeInsets.only(top: .05 * globals.size.height),
      height: height,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          HomePageHeaderButtons(),
          HomePageHeaderNavigator(),
        ],
      ),
    );
  }
}

class HomePageHeaderButtons extends StatelessWidget {
  // Returns a sandwich button that opens the home page drawer, the Entropy logo
  // that takes the user to their profile page, and a search button and a camera
  // button.
  @override
  Widget build(BuildContext context) {
    double buttonsWidth = .12 * globals.size.width;

    return Container(
        padding: EdgeInsets.only(
          left: .0512 * globals.size.width,
          right: .0512 * globals.size.width,
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _openDrawerButton(context),
              GestureDetector(
                  child: Container(
                      height: .065 * globals.size.height,
                      child: Image.asset('assets/images/Entropy.PNG')),
                  onTap: () async {
                    User user = await globals.userRepository.get(globals.uid);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfilePage(user: user)));
                  }),
              Container(
                height: .06 * globals.size.height,
                width: buttonsWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      child: _iconContainer(
                        Image.asset('assets/images/search_icon.png'),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchPage()),
                      ),
                    ),
                    GestureDetector(
                      child: _iconContainer(
                          Image.asset('assets/images/camera_icon.png')),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Camera(
                                  cameraUsage: CameraUsage.post,
                                )),
                      ),
                    )
                  ],
                ),
              )
            ]));
  }

  Widget _openDrawerButton(BuildContext context) {
    return GestureDetector(
        child: Container(
            child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: Colors.transparent,
              padding: EdgeInsets.all(.01 * globals.size.height),
              height: .045 * globals.size.height,
              width: .045 * globals.size.height,
              child: SvgPicture.string(
                _svg_eqwtyu,
                allowDrawingOutsideViewBox: true,
              ),
            ),
            StreamBuilder(
                stream: globals.newActivityRepository.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data) {
                    return Transform.translate(
                      offset: Offset(.012 * globals.size.height,
                          -.012 * globals.size.height),
                      child: AlertCircle(diameter: .018 * globals.size.height),
                    );
                  } else {
                    return Container();
                  }
                })
          ],
        )),
        onTap: () => Scaffold.of(context).openDrawer());
  }

  Widget _iconContainer(Image image) {
    return Container(
      width: .12 * globals.size.width,
      height: .0273 * globals.size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(globals.size.height),
        color: const Color(0xffffffff),
        border: Border.all(width: 1.0, color: const Color(0xff000000)),
      ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          width: .58 * globals.size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _navigationButton(
                "Discover",
                PageLabel.discover,
              ),
              _navigationButton(
                "Following",
                PageLabel.following,
              ),
              _navigationButton(
                "Friends",
                PageLabel.friends,
              ),
            ],
          ),
        ),
        Container(
          child: Transform.translate(
            offset: Offset(0, -.0118 * globals.size.height),
            child: Container(
              width: .55 * globals.size.width,
              height: .00829 * globals.size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(globals.size.height),
                color: const Color(0xffffffff),
                border: Border.all(width: 1.0, color: const Color(0xff707070)),
              ),
              child: Transform.translate(
                offset: Offset(
                    max(-1.0, min(-provider.offset, 1.0)) *
                        .225 *
                        (globals.size.width - 12),
                    0),
                child: SvgPicture.string(
                  _svg_cayeaa,
                  allowDrawingOutsideViewBox: true,
                ),
              ),
            ),
          ),
        ),
      ],
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
                fontSize: .0178 * globals.size.height,
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
    return Consumer<HomePageProvider>(builder: (context, provider, child) {
      return GestureDetector(
        child: Container(
          height: widget.height,
          width: globals.size.width,
          color: Colors.white,
          child: Stack(children: [
            Transform.translate(
                offset: Offset(globals.size.width * (provider.offset - 1), 0),
                child: _discover),
            Transform.translate(
                offset: Offset(globals.size.width * (provider.offset), 0),
                child: _following),
            Transform.translate(
                offset: Offset(globals.size.width * (provider.offset + 1), 0),
                child: _chats),
          ]),
        ),
        onHorizontalDragUpdate: (value) =>
            provider.offset += 2.0 * (value.delta.dx / globals.size.width),
        onHorizontalDragEnd: (_) => provider.handleHorizontalDragEnd(),
      );
    });
  }
}

const String _svg_cayeaa =
    '<svg viewBox="152.0 94.0 59.1 7.0" ><path transform="translate(152.0, 94.0)" d="M 3.691642761230469 0 L 55.37464141845703 0 C 57.41348266601562 0 59.0662841796875 1.56700325012207 59.0662841796875 3.5 C 59.0662841796875 5.43299674987793 57.41348266601562 7 55.37464141845703 7 L 3.691642761230469 7 C 1.652804613113403 7 0 5.43299674987793 0 3.5 C 0 1.56700325012207 1.652804613113403 0 3.691642761230469 0 Z" fill="#000000" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_eqwtyu =
    '<svg viewBox="9.0 11.3 17.9 15.5" ><path transform="translate(9.04, 11.25)" d="M 0 0 L 17.92163467407227 0" fill="none" stroke="#000000" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(9.04, 19.0)" d="M 0 0 L 17.92163467407227 0" fill="none" stroke="#000000" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(9.04, 26.75)" d="M 0 0 L 17.92163467407227 0" fill="none" stroke="#000000" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
