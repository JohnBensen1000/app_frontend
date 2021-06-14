import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../API/users.dart';
import '../../models/user.dart';
import '../../widgets/back_arrow.dart';
import '../../widgets/profile_pic.dart';
import '../../components/bottom_box_shadow.dart';

import '../profile_page.dart';

class SearchPageProvider extends ChangeNotifier {
  // Used to keep track of a the searched creators. Gets a list of all users
  // who's userID contains the search string. Notifies listeners whenever this
  // list changes.
  List<User> _creatorsList = [];

  List<User> get creatorsList {
    return _creatorsList;
  }

  Future<void> searchForCreators(String creatorString) async {
    if (creatorString != '') {
      _creatorsList = await searchUsers(creatorString);
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
    double headerHeight = 120;

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
      padding: EdgeInsets.only(top: 50, left: 20, right: 20),
      decoration:
          BoxDecoration(color: Colors.white, boxShadow: [bottomBoxShadow]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            child: BackArrow(),
            onTap: () => Navigator.of(context).pop(),
          ),
          Container(
              height: 50,
              width: 300,
              child: TextField(
                decoration: new InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(40.0),
                      ),
                    ),
                    hintText: "Who Are you looking for?"),
                onChanged: (text) =>
                    provider.searchForCreators(_searchController.text),
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
    return new FlatButton(
      child: Container(
          margin: EdgeInsets.only(bottom: 20),
          width: double.infinity,
          height: 120,
          decoration: new BoxDecoration(
            border: Border(
                top: BorderSide(color: Colors.grey[400]),
                bottom: BorderSide(color: Colors.grey[400])),
          ),
          child: Profile(
            diameter: 80,
            user: creator,
          )),
      onPressed: () {
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
