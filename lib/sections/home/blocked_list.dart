import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/methods/blocked.dart';

import '../../globals.dart' as globals;
import '../../models/user.dart';
import '../../widgets/profile_pic.dart';
import '../../API/handle_requests.dart';
import '../../widgets/back_arrow.dart';

import '../profile_page/profile_page.dart';

class BlockedListProvider extends ChangeNotifier {
  // Keeps track of all the creator that the user is blocking. When the user
  // wants to unblock a user, the blocked repository is told to remove that user
  // from the blocked list. If this is done successfully, the page is rebuilt to
  // not include the recently unblocked creator.

  BlockedListProvider() {
    this._blockedUsers = globals.blockedRepository.blockedList;
    _blockedListCallback();
  }

  List<User> _blockedUsers;

  List<User> get blockedUsers => _blockedUsers;

  Future<void> unBlockUser(BuildContext context, User user) async {
    if (await globals.blockedRepository.unblock(user)) {
      _blockedUsers = globals.blockedRepository.blockedList;
      notifyListeners();
    }
  }

  Future<void> _blockedListCallback() async {
    globals.blockedRepository.stream.listen((_) {
      _blockedUsers = globals.blockedRepository.blockedList;
      notifyListeners();
    });
  }
}

class BlockedList extends StatelessWidget {
  // Broken up into 2 sections: a back arrow and a list of all blocked creators.
  // This list of blocked creators is rebuilt every time the list of blocked
  // creators changes.

  @override
  Widget build(BuildContext context) {
    double headerHeight = .118 * globals.size.height;
    double bodyHeight = MediaQuery.of(context).size.height - headerHeight;

    return Scaffold(
        body: Column(
      children: [
        Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(
              left: .051 * globals.size.width,
              right: .051 * globals.size.width,
              bottom: .0118 * globals.size.height),
          height: headerHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                  child: BackArrow(), onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
        ChangeNotifierProvider(
            create: (context) => BlockedListProvider(),
            child: Consumer<BlockedListProvider>(
                builder: (context, provider, child) => Container(
                    width: double.infinity,
                    height: bodyHeight,
                    child: ListView.builder(
                        padding:
                            EdgeInsets.only(top: .012 * globals.size.height),
                        itemCount: provider.blockedUsers.length,
                        itemBuilder: (context, index) {
                          return BlockedUserWidget(
                            user: provider.blockedUsers[index],
                          );
                        }))))
      ],
    ));
  }
}

class BlockedUserWidget extends StatelessWidget {
  // Contains a blocked user's profile, username, and userID. Also contains
  // a button that, when pressed, unblocks the blocked user. When the blocked
  // user's profile is pressed, the user is taken to the blocked user's profile
  // page.

  BlockedUserWidget({@required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    BlockedListProvider provider =
        Provider.of<BlockedListProvider>(context, listen: false);

    return Container(
      margin: EdgeInsets.only(
          top: .012 * globals.size.height, bottom: .012 * globals.size.height),
      width: double.infinity,
      height: .142 * globals.size.height,
      padding: EdgeInsets.all(.012 * globals.size.height),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: Colors.grey[400]),
              bottom: BorderSide(color: Colors.grey[400]))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(
            child: Profile(diameter: .083 * globals.size.height, user: user),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(user: user)))),
        GestureDetector(
            child: Container(
              width: .065 * globals.size.height,
              height: .065 * globals.size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(.015 * globals.size.height),
                color: Colors.blueAccent,
                border: Border.all(width: 1.0, color: const Color(0xffffffff)),
              ),
              child: (Center(
                  child: Text("Unblock",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: .014 * globals.size.height)))),
            ),
            onTap: () => provider.unBlockUser(context, user)),
      ]),
    );
  }
}
