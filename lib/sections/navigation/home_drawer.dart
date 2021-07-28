import 'package:flutter/material.dart';
import 'package:test_flutter/widgets/profile_pic.dart';
import 'package:test_flutter/widgets/generic_text_button.dart';

import '../../globals.dart' as globals;
import '../profile_page/profile_page.dart';

import 'blocked_list.dart';
import 'activity_page.dart';

class HomeDrawer extends StatelessWidget {
  // A drawer that is opened from the home screen. Displays the user's profile
  // picture, username and user ID. Displays a list of buttons, including a
  // button that takes a user to their profile page, a button for viewing their
  // activity feed, and a button that lets them unblock the users that they are
  // currently blocking.

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
                      GenericTextButton(
                          buttonName: "Activity",
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ActivityPage()))),
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
