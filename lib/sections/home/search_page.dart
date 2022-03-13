import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;

import '../../API/methods/users.dart';
import '../../models/user.dart';
import '../../widgets/back_arrow.dart';
import '../../widgets/profile_pic.dart';
import '../../API/handle_requests.dart';
import '../../widgets/input_field.dart';
import '../../widgets/entropy_scaffold.dart';

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
    double headerHeight = .18 * globals.size.height;

    return ChangeNotifierProvider(
        create: (context) => SearchPageProvider(),
        child: Consumer<SearchPageProvider>(
            builder: (context, provider, child) => EntropyScaffold(
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

class SearchPageHeader extends StatefulWidget {
  const SearchPageHeader(
      {Key key,
      @required TextEditingController searchController,
      @required this.height})
      : _searchController = searchController,
        super(key: key);

  final TextEditingController _searchController;
  final double height;

  @override
  State<SearchPageHeader> createState() => _SearchPageHeaderState();
}

class _SearchPageHeaderState extends State<SearchPageHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: EdgeInsets.only(
        top: .059 * globals.size.height,
        // left: .0513 * globals.size.width,
        // right: .0513 * globals.size.width),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            child: BackArrow(),
            onTap: () => Navigator.of(context).pop(),
          ),
          Container(
              height: .059 * globals.size.height,
              width: .9 * globals.size.width,
              child: TextInputWidget(
                  hintText: "Who are you looking for?",
                  textEditingController: widget._searchController,
                  widthFraction: .9,
                  onChange: _onChange))
        ],
      ),
    );
  }

  Future<void> _onChange(String text) async {
    Provider.of<SearchPageProvider>(context, listen: false)
        .searchForCreators(context, widget._searchController.text);
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
          margin: EdgeInsets.only(bottom: .02 * globals.size.height),
          width: double.infinity,
          height: .1 * globals.size.height,
          decoration: new BoxDecoration(
            border: Border(
                top: BorderSide(color: Colors.grey[400]),
                bottom: BorderSide(color: Colors.grey[400])),
          ),
          child: Profile(
            diameter: .06 * globals.size.height,
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
