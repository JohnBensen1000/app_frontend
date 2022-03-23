import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../globals.dart' as globals;
import '../../API/methods/posts.dart';
import '../../models/user.dart';
import '../../models/post.dart';
import '../../widgets/entropy_scaffold.dart';

import '../../widgets/profile_pic.dart';
import '../../widgets/back_arrow.dart';
import '../../widgets/alert_dialog_container.dart';
import '../../widgets/generic_alert_dialog.dart';
import '../../widgets/wide_button.dart';
import '../../widgets/loading_icon.dart';

import '../post/post_widget.dart';
import '../post/post_page.dart';

import 'widgets/profile_page_header_button.dart';
import 'profile_page_drawer.dart';

class ProfilePageProvider extends ChangeNotifier {
  // Keeps track of the list of the creator's posts, whether the profile page
  // belongs to the main user, and if the main user is following the profile
  // page's creator. Also allows the user to start/stop following the creator,
  // and allows the user to block the creator. If the profile page belongs to
  // the user, then allows the user to delete their posts. Rebuilds the profile
  // page whenever the user changes any of their settings.

  ProfilePageProvider({@required this.user}) {
    print(user.uid);
    _allowFollowingChange = true;
    _getUsersPosts();
    _callbacks();
  }

  User user;

  List<Post> _postsList;
  bool _allowFollowingChange;

  List<Post> get postsList => _postsList;
  bool get isMainUsersProfile => user.uid == globals.uid;
  bool get isFollowing => globals.followingRepository.isFollowing(user.uid);

  void toggleFollowing() async {
    if (_allowFollowingChange) {
      _allowFollowingChange = false;
      isFollowing
          ? await globals.followingRepository.unfollow(user)
          : await globals.followingRepository.follow(user);
      _allowFollowingChange = true;
    }
  }

  Future<void> block(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialogContainer(
              dialogText: "Are you sure you want to block ${user.userID}?");
        }).then((isBlockingUser) async {
      if (isBlockingUser) {
        var response = await globals.blockedRepository.block(user);
        switch (response['denied']) {
          default:
            await showDialog(
                context: context,
                builder: (context) => GenericAlertDialog(
                    text:
                        "You have successfully blocked this user, so you will no longer see any content from them."));
            Navigator.pop(context);
        }
      }
    });
  }

  Future<void> delete(Post post) async {
    bool response = await deletePost(post);

    if (response != null && response) {
      _postsList.remove(post);
      notifyListeners();
    }
  }

  void _getUsersPosts() async {
    _postsList = await getUsersPosts(user);
    notifyListeners();
  }

  void _callbacks() async {
    globals.followingRepository.stream.listen((following) {
      notifyListeners();
    });
    globals.userRepository.stream.listen((updatedUser) {
      user = updatedUser;
      notifyListeners();
    });
  }
}

class ProfilePage extends StatelessWidget {
  // Broken up into a header and a body.

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
        child: EntropyScaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ProfilePageHeader(
                  height: headerHeight,
                ),
                ProfilePostBody(
                    user: user,
                    height: bodyHeight,
                    betweenPadding: .015 * globals.size.width),
              ],
            ),
            drawer: Container(
                width: .7 * globals.size.width, child: ProfilePageDrawer())));
  }
}

class ProfilePageHeader extends StatelessWidget {
  // Returns a back button, the creator's profile pic, username, and userID.
  // If the profile page belongs to the user, then returns a button that lets
  // the user open up the settings drawer. If the profile page belongs to
  // someone else, then returns a row of buttons that lets the user start/stop
  // following the creator and block the user.

  const ProfilePageHeader({@required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
            bottom: .02 * globals.size.height, top: .055 * globals.size.height),
        height: height,
        child: Consumer<ProfilePageProvider>(
            builder: (context, provider, child) => Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Center(child: BackArrow())),
                        ],
                      ),
                    ),
                    Column(
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
                          if (provider.user.uid != globals.uid)
                            Container(
                              width: .48 * globals.size.width,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _followBackButton(context),
                                  _blockButton(context)
                                ],
                              ),
                            )
                          else
                            _openDrawerButton(context),
                        ]),
                  ],
                )));
  }

  Widget _openDrawerButton(BuildContext context) {
    return GestureDetector(
        child: ProfilePageHeaderButton(
          width: .32 * globals.size.width,
          name: "Settings",
          color: Colors.transparent,
          borderColor: Provider.of<ProfilePageProvider>(context, listen: false)
              .user
              .profileColor,
        ),
        onTap: () => Scaffold.of(context).openDrawer());
  }

  Widget _followBackButton(BuildContext context) {
    return Consumer<ProfilePageProvider>(builder: (context, provider, child) {
      return GestureDetector(
          child: ProfilePageHeaderButton(
              name: (provider.isFollowing) ? "Following" : "Follow",
              color: (provider.isFollowing)
                  ? Colors.white
                  : provider.user.profileColor,
              borderColor: provider.user.profileColor,
              width: .27 * globals.size.width),
          onTap: () => provider.toggleFollowing());
    });
  }

  Widget _blockButton(BuildContext context) {
    return GestureDetector(
        child: ProfilePageHeaderButton(
          name: "Block",
          borderColor: Colors.black,
          color: Colors.white,
          width: .19 * globals.size.width,
        ),
        onTap: () async =>
            await Provider.of<ProfilePageProvider>(context, listen: false)
                .block(context));
  }
}

class ProfilePostBody extends StatelessWidget {
  // Returns a scrollable list of all of the creator's posts. Breaks it up into:
  // one main post on top, and then rows of three posts at a time.
  ProfilePostBody({
    @required this.user,
    @required this.height,
    @required this.betweenPadding,
    this.rowSize = 3,
  });

  final User user;
  final double height;
  final double betweenPadding;
  final int rowSize;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfilePageProvider>(builder: (context, provider, child) {
      if (provider.postsList == null) {
        return Container(
            width: double.infinity,
            height: height,
            child: Center(child: ProgressCircle()));
      } else if (provider.postsList.length == 0) {
        return Center(child: Text("Nothing to display"));
      } else {
        List<Widget> profilePostsList =
            _getProfilePostsList(context, provider.postsList);

        return SizedBox(
          height: height,
          child: new ListView.builder(
            padding: EdgeInsets.only(top: .01 * globals.size.height),
            itemCount: profilePostsList.length,
            itemBuilder: (BuildContext context, int index) {
              return profilePostsList[index];
            },
          ),
        );
      }
    });
  }

  List<Widget> _getProfilePostsList(BuildContext context, List<Post> postList) {
    // Determines width and height for every post on the profile page. The first
    // widget in the return list is a large ProfilePostWidget(). The remaining
    // posts are broken up into rows of rowSize (int) ProfilePostWidget().

    double width = .96 * globals.size.width;
    double mainPostHeight = width / globals.goldenRatio;
    double bodyPostHeight = .8 * mainPostHeight;

    List<Widget> profilePosts = [
      Padding(
          padding: EdgeInsets.only(bottom: betweenPadding),
          child: ProfilePostWidget(
              post: postList[0],
              height: mainPostHeight,
              aspectRatio: mainPostHeight / width,
              key: UniqueKey()))
    ];

    List<Widget> subPostsList =
        _getSubPostsList(postList, bodyPostHeight, width);

    for (int i = 0; i < subPostsList.length; i += rowSize) {
      profilePosts.add(Padding(
        padding: EdgeInsets.only(bottom: betweenPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: subPostsList.sublist(i, i + rowSize),
        ),
      ));
    }
    return profilePosts;
  }

  List<Widget> _getSubPostsList(
      List<dynamic> postList, double postHeight, double width) {
    // Creates a list of the remaining posts (not the main post). Adds empty
    // containers so that the return list is evenly divisible by rowSize (int).

    List<Widget> subPostsList = [];
    int i = 1;

    while ((i < postList.length) || ((i - 1) % rowSize != 0)) {
      // width of post is 1/3 of total width minus white space (padding)
      double postWidth = (width - 2 * betweenPadding) / 3;

      if (i < postList.length) {
        subPostsList.add(ProfilePostWidget(
            post: postList[i],
            height: postHeight,
            aspectRatio: postHeight / postWidth,
            key: UniqueKey()));
      } else {
        subPostsList.add(
          Container(
            height: postHeight,
            width: postWidth,
          ),
        );
      }
      i++;
    }
    return subPostsList;
  }
}

class ProfilePostWidget extends StatefulWidget {
  // The entire point of this widget is to keep each element in profile body's
  // ListView.builder() alive when scrolling down. That way, it doesn't jump to
  // the top when scrolling up.
  ProfilePostWidget({
    @required this.height,
    @required this.post,
    @required this.aspectRatio,
    Key key,
  }) : super(key: key);

  final double height;
  final Post post;
  final double aspectRatio;

  @override
  _ProfilePostWidgetState createState() => _ProfilePostWidgetState();
}

class _ProfilePostWidgetState extends State<ProfilePostWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: PostWidget(
          post: widget.post,
          height: widget.height,
          aspectRatio: widget.aspectRatio,
          playVideo: false,
        ),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PostPage(isFullPost: true, post: widget.post))),
        onLongPress: () {
          if (widget.post.creator.uid == globals.uid) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ProfilePostAlertDialog(post: widget.post);
                }).then((willDelete) async {
              if (willDelete != null && willDelete) {
                await Provider.of<ProfilePageProvider>(context, listen: false)
                    .delete(widget.post);
              }
            });
          }
        });
  }
}

class ProfilePostAlertDialog extends StatelessWidget {
  const ProfilePostAlertDialog({@required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Container(
            height: .32 * globals.size.height,
            width: .4 * globals.size.width,
            padding: EdgeInsets.all(.02 * globals.size.height),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(.9),
                border: Border.all(
                  color: Colors.grey[800].withOpacity(.9),
                ),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PostWidget(
                    post: post,
                    height: .2 * globals.size.height,
                    aspectRatio: globals.goldenRatio),
                GestureDetector(
                    child: WideButton(buttonName: "Delete"),
                    onTap: () => showDialog(
                            context: context,
                            builder: (BuildContext _) => AlertDialogContainer(
                                dialogText:
                                    "Are you sure you want to delete this post? It will be permanently removed from the app."))
                        .then(
                            (willDelete) => Navigator.pop(context, willDelete)))
              ],
            )));
  }
}

const String _svg_cdsk62 =
    '<svg viewBox="289.0 36.0 57.0 11.0" ><path transform="translate(289.0, 36.0)" d="M 6.397959232330322 0 L 50.60204315185547 0 C 54.13554000854492 0 57.00000381469727 2.462433815002441 57.00000381469727 5.5 C 57.00000381469727 8.537566184997559 54.13554000854492 11 50.60204315185547 11 L 6.397959232330322 11 C 2.864464044570923 11 0 8.537566184997559 0 5.5 C 0 2.462433815002441 2.864464044570923 0 6.397959232330322 0 Z" fill="#22a2ff" stroke="#22a2ff" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_jmyh3o =
    '<svg viewBox="119.5 286.0 136.0 1.0" ><path transform="translate(119.5, 286.0)" d="M 0 0 L 136 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
