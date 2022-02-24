import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;

import '../../widgets/alert_circle.dart';
import '../../models/user.dart';
import '../../widgets/profile_pic.dart';
import '../../widgets/generic_text_button.dart';

import '../profile_page/profile_page.dart';

import 'blocked_list.dart';
import 'activity_page.dart';

class HomeDrawerProvider extends ChangeNotifier {
  // Responsible for keeping track of when to show the new activity circle on
  // the "Activity" button. Listens to the new activity repository for updates.

  HomeDrawerProvider({@required BuildContext context}) {
    _showActivityCircle = globals.newActivityRepository.newActivity;
    _newActivityCallback(context);
  }

  bool _showActivityCircle;

  bool get showActivityCircle => _showActivityCircle;

  void _newActivityCallback(BuildContext context) {
    globals.newActivityRepository.stream.listen((bool newActivity) {
      _showActivityCircle = newActivity;
      notifyListeners();
    });
  }
}

class HomeDrawer extends StatelessWidget {
  // Returns a Column broken up into 3 sections. One section contains the user's
  // profile pic, username, and userID. The middle section contains a list
  // of buttons that take the user to other parts of the app. The last section
  // contains information that lets the user contact Entropy's developers.

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => HomeDrawerProvider(context: context),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: .08 * globals.size.height),
          child: Column(
            children: [
              FutureBuilder(
                  future: globals.userRepository.get(globals.uid),
                  builder: (context, snapshot) => Container(
                      padding:
                          EdgeInsets.only(bottom: .02 * globals.size.height),
                      child: Column(
                        children: [
                          snapshot.hasData
                              ? ProfilePic(
                                  diameter: .2 * globals.size.height,
                                  user: snapshot.data,
                                )
                              : Container(),
                          Text(
                            snapshot.hasData ? snapshot.data.username : "",
                            style:
                                TextStyle(fontSize: .038 * globals.size.height),
                          ),
                          Text(
                            snapshot.hasData ? "@${snapshot.data.userID}" : "",
                            style: TextStyle(
                                fontSize: .014 * globals.size.height,
                                color: Colors.grey[500]),
                          ),
                        ],
                      ))),
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          GenericTextButton(
                            buttonName: "Profile Page",
                            onPressed: () async {
                              User user =
                                  await globals.userRepository.get(globals.uid);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ProfilePage(user: user)));
                            },
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Consumer<HomeDrawerProvider>(
                                  builder: (context, provider, child) {
                                if (provider.showActivityCircle)
                                  return Transform.translate(
                                    offset: Offset(.14 * globals.size.width,
                                        0 * globals.size.height),
                                    child: AlertCircle(
                                        diameter: .018 * globals.size.height),
                                  );
                                else
                                  return Container();
                              }),
                              GenericTextButton(
                                  buttonName: "Activity",
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ActivityPage())))
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
        ));
  }
}
