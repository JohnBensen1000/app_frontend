import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_flutter/profile_page.dart';

import 'user_info.dart';
import 'backend_connect.dart';

final backendConnection = new BackendConnection();

class CreatorsList extends ChangeNotifier {
  List<User> _creatorsList = [];

  List<User> get getCreatorsList {
    return _creatorsList;
  }

  Future<void> searchForCreators(String creatorString) async {
    if (creatorString != '') {
      String newUrl =
          backendConnection.url + "users/search/" + creatorString + "/";
      var response = await http.get(newUrl);

      _creatorsList = [
        for (var creator in json.decode(response.body)["creatorsList"])
          User(userID: creator["userID"], username: creator["username"])
      ];
    } else {
      _creatorsList = [];
    }
    notifyListeners();
  }

  Future<void> clearSearchList() async {
    _creatorsList = [];
    notifyListeners();
  }
}

void startFollowing(String userID, String creatorID) async {
  String newUrl = backendConnection.url + "users/" + userID + "/following/new/";
  var response = await http.post(newUrl, body: {"creatorID": creatorID});

  // if (response.statusCode == 201) print("Started Following!");
  // if (response.statusCode == 204) print("Already following creator");
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [ChangeNotifierProvider.value(value: CreatorsList())],
        child: SearchResults());
  }
}

class SearchResults extends StatelessWidget {
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
                    )),
                    onChanged: (text) {
                      Provider.of<CreatorsList>(context, listen: false)
                          .searchForCreators(text);
                    }),
              ),
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
                        '${creatorsList[index].username}',
                        textAlign: TextAlign.center,
                      ),
                    )),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(user: creatorsList[index])),
                ),
                // onPressed: () {
                //   startFollowing(userID, creatorsList[index].userID);
                //   Provider.of<CreatorsList>(context, listen: false)
                //       .clearSearchList();
                // },
              );
            },
          ),
        ),
      ],
    )));
  }
}
