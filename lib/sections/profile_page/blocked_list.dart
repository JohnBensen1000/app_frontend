import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../widgets/profile_pic.dart';
import '../../API/methods/relations.dart';
import '../../API/handle_requests.dart';
import '../../widgets/back_arrow.dart';

import '../profile_page/profile_page.dart';

class BlockedListProvider extends ChangeNotifier {
  // Contains a list of blocked users. Also contains a function used to unblock
  // a user. This function sends a request to the server to unblock the user.
  // If this request is successful, the user is removed from list of blocked
  // users.

  List<User> blockedUsers;

  BlockedListProvider({@required List<User> blockedUsers}) {
    this.blockedUsers = blockedUsers;
  }

  Future<void> unBlockUser(BuildContext context, User user) async {
    if (await handleRequest(context, deleteBlockedUser(user))) {
      blockedUsers.remove(user);
      notifyListeners();
    }
  }
}

class BlockedList extends StatelessWidget {
  // Seperates the blocked list page into a header and a body. Gets a list of
  // blocked users from the server and uses that list to initialize the
  // provider. The page's body is the child to this provider.

  @override
  Widget build(BuildContext context) {
    double headerHeight = 100;
    double bodyHeight = MediaQuery.of(context).size.height - headerHeight;

    return Scaffold(
        body: Column(
      children: [
        BlockedListHeader(height: headerHeight),
        FutureBuilder(
            future: getBlockedUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return ChangeNotifierProvider(
                    create: (context) =>
                        BlockedListProvider(blockedUsers: snapshot.data),
                    child: BlockedListBody(height: bodyHeight));
              } else
                return Center(
                  child: Text("Loading"),
                );
            })
      ],
    ));
  }
}

class BlockedListHeader extends StatelessWidget {
  // contains a button for returning to the previous page.

  BlockedListHeader({@required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30,
            child: GestureDetector(
                child: BackArrow(), onTap: () => Navigator.pop(context)),
          ),
        ],
      ),
    );
  }
}

class BlockedListBody extends StatelessWidget {
  // Returns a list view of all blocked users. This widget is rebuilt anytime
  // the user unblocks another user.

  BlockedListBody({@required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Consumer<BlockedListProvider>(
        builder: (context, provider, child) => Container(
            width: double.infinity,
            height: height,
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: provider.blockedUsers.length,
                itemBuilder: (context, index) {
                  return BlockedUserWidget(
                    user: provider.blockedUsers[index],
                  );
                })));
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
      margin: EdgeInsets.only(top: 10, bottom: 10),
      width: double.infinity,
      height: 120,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: Colors.grey[400]),
              bottom: BorderSide(color: Colors.grey[400]))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(
            child: Profile(diameter: 70, user: user),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(user: user)))),
        GestureDetector(
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13.0),
                color: Colors.blueAccent,
                border: Border.all(width: 1.0, color: const Color(0xffffffff)),
              ),
              child: (Center(
                  child: Text("Unblock",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12)))),
            ),
            onTap: () => provider.unBlockUser(context, user)),
      ]),
    );
  }
}
