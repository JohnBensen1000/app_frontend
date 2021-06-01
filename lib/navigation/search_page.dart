import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

import '../API/users.dart';

import '../profile/profile_page.dart';

class CreatorsList extends ChangeNotifier {
  List<User> _creatorsList = [];

  List<User> get getCreatorsList {
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
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreatorsList(),
      child: SearchResults(),
    );
  }
}

class SearchResults extends StatelessWidget {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var creatorsList = Provider.of<CreatorsList>(context).getCreatorsList;

    return Scaffold(
        body: Container(
            child: Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  height: 50,
                  width: 260,
                  child: TextField(
                    decoration: new InputDecoration(
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(40.0),
                          ),
                        ),
                        hintText: "Search"),
                    onChanged: (text) =>
                        Provider.of<CreatorsList>(context, listen: false)
                            .searchForCreators(_searchController.text),
                    controller: _searchController,
                  )),
              Container(
                  width: 80,
                  height: 30,
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.grey[300],
                  ),
                  child: FlatButton(
                    child: Center(
                      child: Text(
                        'Exit',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: creatorsList.length,
            itemBuilder: (BuildContext context, int index) {
              return SearchResult(
                  creator: creatorsList[index],
                  searchController: _searchController);
            },
          ),
        ),
      ],
    )));
  }
}

class SearchResult extends StatelessWidget {
  const SearchResult({
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
          width: 200,
          height: 40,
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.grey[200],
          ),
          child: Center(
            child: Text(
              '${creator.username}',
              textAlign: TextAlign.center,
            ),
          )),
      onPressed: () {
        Provider.of<CreatorsList>(context, listen: false).clearSearchList();
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
