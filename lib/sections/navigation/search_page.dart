import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/handle_requests.dart';

import '../../globals.dart' as globals;

import '../../API/methods/users.dart';
import '../../models/user.dart';
import '../../widgets/back_arrow.dart';
import '../../widgets/profile_pic.dart';

import '../profile_page/profile_page.dart';

class SearchPageProvider extends ChangeNotifier {
  // Used to keep track of a the searched creators. Gets a list of all users
  // who's userID contains the search string. Notifies listeners whenever this
  // list changes.
  List<User> _creatorsList = [];

  List<User> get creatorsList {
    return _creatorsList;
  }

  Future<void> searchForCreators(
      BuildContext context, String creatorString) async {
    if (creatorString != '') {
      List<User> tempCreatorsList = await handleRequest(
        context,
        getUsersFromSearchString(creatorString),
      );

      _creatorsList = (tempCreatorsList != null) ? tempCreatorsList : [];
    } else {
      _creatorsList = [];
    }
    notifyListeners();
  }

  void clearSearchList() {
    _creatorsList = [];
    notifyListeners();
  }
}

class SearchPage extends StatelessWidget {
  // Allows a user to search for creators. Displays a list of all creators that
  // match the search criteria.

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double headerHeight = .142 * globals.size.height;

    return ChangeNotifierProvider(
        create: (context) => SearchPageProvider(),
        child: Consumer<SearchPageProvider>(
            builder: (context, provider, child) => Scaffold(
                    body: Container(
                        child: Column(
                  children: <Widget>[
                    SearchPageHeader(
                      searchController: _searchController,
                      height: headerHeight,
                    ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: provider.creatorsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SearchResultWidget(
                              creator: provider.creatorsList[index],
                              searchController: _searchController);
                        },
                      ),
                    ),
                  ],
                )))));
  }
}

class SearchPageHeader extends StatelessWidget {
  const SearchPageHeader(
      {Key key,
      @required TextEditingController searchController,
      @required this.height})
      : _searchController = searchController,
        super(key: key);

  final TextEditingController _searchController;
  final double height;

  @override
  Widget build(BuildContext context) {
    SearchPageProvider provider =
        Provider.of<SearchPageProvider>(context, listen: false);

    return Container(
      height: height,
      padding: EdgeInsets.only(
          top: .059 * globals.size.height,
          left: .0513 * globals.size.width,
          right: .0513 * globals.size.width),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            child: BackArrow(),
            onTap: () => Navigator.of(context).pop(),
          ),
          Container(
              height: .059 * globals.size.height,
              width: .769 * globals.size.width,
              child: TextField(
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(.0118 * globals.size.height),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(globals.size.height),
                      ),
                    ),
                    hintText: "Who are you looking for?"),
                onChanged: (text) =>
                    provider.searchForCreators(context, _searchController.text),
                controller: _searchController,
              )),
        ],
      ),
    );
  }
}

class SearchResultWidget extends StatelessWidget {
  // Displays a user's profile, username, and userID. When pressed, takes the
  // user to the user's profile page.
  const SearchResultWidget({
    Key key,
    @required this.creator,
    @required TextEditingController searchController,
  })  : _searchController = searchController,
        super(key: key);

  final User creator;
  final TextEditingController _searchController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          padding: EdgeInsets.only(left: .05 * globals.size.width),
          margin: EdgeInsets.only(bottom: .0237 * globals.size.height),
          width: double.infinity,
          height: .142 * globals.size.height,
          decoration: new BoxDecoration(
            border: Border(
                top: BorderSide(color: Colors.grey[400]),
                bottom: BorderSide(color: Colors.grey[400])),
          ),
          child: Profile(
            diameter: .0947 * globals.size.height,
            user: creator,
          )),
      onTap: () {
        Provider.of<SearchPageProvider>(context, listen: false)
            .clearSearchList();
        _searchController.clear();
        FocusScope.of(context).unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(user: creator)),
        );
      },
    );
  }
}
