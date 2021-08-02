import 'package:flutter/material.dart';
import 'package:test_flutter/widgets/profile_pic.dart';
import 'package:test_flutter/widgets/generic_text_button.dart';

import '../../globals.dart' as globals;
import '../profile_page/profile_page.dart';

import 'blocked_list.dart';
import 'activity_page.dart';

class HomeDrawer extends StatefulWidget {
  // A drawer that is opened from the home screen. Displays the user's profile
  // picture, username and user ID. Displays a list of buttons, including a
  // button that takes a user to their profile page, a button for viewing their
  // activity feed, and a button that lets them unblock the users that they are
  // currently blocking. If isUserUpdated is false, then shows a small circle
  // on the activity button. When the user goes to and returns from the activity
  // page, isUserUpdated is set to true.

  HomeDrawer({@required this.isUserUpdated});

  final bool isUserUpdated;

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  bool isUserUpdated;

  @override
  void initState() {
    super.initState();
    isUserUpdated = widget.isUserUpdated;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: .08 * globals.size.height),
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(bottom: .02 * globals.size.height),
              child: Column(
                children: [
                  ProfilePic(
                      diameter: .2 * globals.size.height, user: globals.user),
                  Text(
                    globals.user.username,
                    style: TextStyle(fontSize: .038 * globals.size.height),
                  ),
                  Text(
                    "@${globals.user.userID}",
                    style: TextStyle(
                        fontSize: .014 * globals.size.height,
                        color: Colors.grey[500]),
                  ),
                ],
              )),
          Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      GenericTextButton(
                          buttonName: "Profile Page",
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProfilePage(user: globals.user)))),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isUserUpdated == false)
                            Transform.translate(
                              offset: Offset(.14 * globals.size.width,
                                  0 * globals.size.height),
                              child: Container(
                                height: .02 * globals.size.height,
                                width: .02 * globals.size.height,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      globals.size.height),
                                  color: globals.user.profileColor,
                                ),
                              ),
                            ),
                          GenericTextButton(
                              buttonName: "Activity",
                              onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ActivityPage())).then((value) {
                                    setState(() {
                                      isUserUpdated = true;
                                    });
                                  })),
                        ],
                      ),
                      GenericTextButton(
                          buttonName: "Unblock Creators",
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BlockedList()))),
                    ],
                  ),
                  Text(
                    "Can't find what you're looking for? Contact user at: entropy.developer1@gmail.com",
                    textAlign: TextAlign.center,
                  )
                ]),
          ),
        ],
      ),
    );
  }
}
