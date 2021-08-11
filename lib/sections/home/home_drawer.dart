import 'package:flutter/material.dart';
import 'package:test_flutter/widgets/profile_pic.dart';
import 'package:test_flutter/widgets/generic_text_button.dart';
import 'package:provider/provider.dart';

import '../../repositories/new_activity_repository.dart';
import '../../globals.dart' as globals;
import '../global.dart';

import '../../widgets/alert_circle.dart';

// import '../profile_page/profile_page.dart';

// import 'blocked_list.dart';
// import 'activity_page.dart';

class HomeDrawerProvider extends ChangeNotifier {
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
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => HomeDrawerProvider(context: context),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: .08 * globals.size.height),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(bottom: .02 * globals.size.height),
                  child: Column(
                    children: [
                      ProfilePic(
                        diameter: .2 * globals.size.height,
                        user: globals.user,
                      ),
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
                            // onPressed: () => Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             ProfilePage(user: globals.user)))),
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
                                        color: globals.user.profileColor,
                                        diameter: .018 * globals.size.height),
                                  );
                                else
                                  return Container();
                              }),
                              GenericTextButton(
                                buttonName: "Activity",
                                // onPressed: () => Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //             builder: (context) =>
                                //                 ActivityPage())).then((value) {
                                //       setState(() {
                                //         isUserUpdated = true;
                                //       });
                                // }
                              ),
                            ],
                          ),
                          GenericTextButton(
                            buttonName: "Unblock Creators",
                            // onPressed: () => Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => BlockedList()))
                          ),
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
