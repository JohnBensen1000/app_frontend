import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../globals.dart' as globals;
import '../../API/methods/posts.dart';
import '../../API/methods/followings.dart';
import '../../API/methods/blocked.dart';
import '../../models/user.dart';
import '../../models/profile.dart';
import '../../models/post.dart';
import '../../widgets/custom_drawer.dart';

import '../../widgets/profile_pic.dart';
import '../../widgets/back_arrow.dart';
import '../../repositories/profile_repository.dart';

import '../global.dart';
import 'widgets/profile_page_header_button.dart';
import 'profile_page_drawer.dart';

class ProfilePageProvider extends ChangeNotifier {
  ProfilePageProvider({@required this.user});

  final User user;

  bool get isMainUsersProfile => user.uid == globals.user.uid;

  // Future<Post> get profileFuture async => isMainUsersProfile
  //     ? await _profilePost
  //     : await handleRequest(context, getProfile(user));

  // void _profileCallback(BuildContext context) async {
  //   globals.globalRepository.profilePostStream.listen((profilePost) {
  //     _profilePost = profilePost;
  //     notifyListeners();
  //   });
  // }
}

class ProfilePage extends StatelessWidget {
  ProfilePage({@required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    double headerHeight = .42 * globals.size.height;
    double bodyHeight = MediaQuery.of(context).size.height - headerHeight;

    return ChangeNotifierProvider(
        create: (context) => ProfilePageProvider(
              user: user,
            ),
        child: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ProfilePageHeader(
                  height: headerHeight,
                ),
                // ProfilePostBody(
                //     user: user,
                //     height: bodyHeight,
                //     sidePadding: .05 * globals.size.width,
                //     betweenPadding: .01 * globals.size.width),
              ],
            ),
            drawer: Container(
                width: .7 * globals.size.width, child: ProfilePageDrawer())));
  }
}

class ProfilePageHeader extends StatelessWidget {
  const ProfilePageHeader({@required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
            bottom: .02 * globals.size.height, top: .045 * globals.size.height),
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(
                top: .01 * globals.size.height,
                left: .06 * globals.size.width,
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Center(child: BackArrow())),
                ],
              ),
            ),
            Consumer<ProfilePageProvider>(
              builder: (context, provider, child) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ProfilePic(
                      diameter: .18 * globals.size.height,
                      user: provider.user,
                    ),
                    Container(
                      child: Text(
                        '${provider.user.username}',
                        style: TextStyle(
                          fontFamily: 'Helvetica Neue',
                          fontSize: .03 * globals.size.height,
                          color: const Color(0xff000000),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      child: Text(
                        '@${provider.user.userID}',
                        style: TextStyle(
                          fontFamily: 'Helvetica Neue',
                          fontSize: .016 * globals.size.height,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      height: .02 * globals.size.height,
                      child: SvgPicture.string(
                        _svg_jmyh3o,
                        allowDrawingOutsideViewBox: true,
                      ),
                    ),
                    if (provider.user.uid != globals.user.uid)
                      // FollowBlockButtons()
                      Container()
                    else
                      _openDrawerButton(context),
                  ]),
            ),
          ],
        ));
  }

  Widget _openDrawerButton(BuildContext context) {
    return GestureDetector(
        child: ProfilePageHeaderButton(
          width: .32 * globals.size.width,
          name: "Edit Profile",
          color: Colors.transparent,
          borderColor: globals.user.profileColor,
        ),
        onTap: () => Scaffold.of(context).openDrawer());
  }
}

class ProfilePostBody extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: handleRequest(context, getUsersPosts(user)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.length == 0)
              return Center(child: Text("Nothing to display"));
            else {
              // List<Widget> profilePostsList =
              //     _getProfilePostsList(context, snapshot.data);

              return Padding(
                padding: EdgeInsets.only(left: sidePadding, right: sidePadding),
                child: SizedBox(
                  height: height,
                  // child: new ListView.builder(
                  //   padding: EdgeInsets.only(top: .01 * globals.size.height),
                  //   itemCount: profilePostsList.length,
                  //   itemBuilder: (BuildContext context, int index) {
                  //     return profilePostsList[index];
                  //   },
                  // ),
                ),
              );
            }
          } else {
            return Container();
          }
        });
  }
}

const String _svg_cdsk62 =
    '<svg viewBox="289.0 36.0 57.0 11.0" ><path transform="translate(289.0, 36.0)" d="M 6.397959232330322 0 L 50.60204315185547 0 C 54.13554000854492 0 57.00000381469727 2.462433815002441 57.00000381469727 5.5 C 57.00000381469727 8.537566184997559 54.13554000854492 11 50.60204315185547 11 L 6.397959232330322 11 C 2.864464044570923 11 0 8.537566184997559 0 5.5 C 0 2.462433815002441 2.864464044570923 0 6.397959232330322 0 Z" fill="#22a2ff" stroke="#22a2ff" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_jmyh3o =
    '<svg viewBox="119.5 286.0 136.0 1.0" ><path transform="translate(119.5, 286.0)" d="M 0 0 L 136 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
