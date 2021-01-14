import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../backend_connect.dart';
import 'main_2.dart';

final backendConnection = new BackendConnection();

class User {
  String username;
  String userID;

  User({this.username, this.userID});
}

class CreatorsList extends ChangeNotifier {
  List<User> _creatorsList = [];

  List<User> get getCreatorsList {
    return _creatorsList;
  }

  Future<void> searchForCreators(String creatorString) async {
    // Sends an http request for all creators with userIDs that contain
    // creatorString, creates a list of User objects
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

class Following extends StatelessWidget {
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
    final userInfo = UserInfo.of(context);
    var creatorsList = Provider.of<CreatorsList>(context).getCreatorsList;

    return Container(
        child: Column(
      children: <Widget>[
        TextField(onChanged: (text) {
          Provider.of<CreatorsList>(context, listen: false)
              .searchForCreators(text);
        }),
        Container(
          height: 200.0,
          width: 100.0,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: creatorsList.length,
            itemBuilder: (BuildContext context, int index) {
              return new RaisedButton(
                child: Text('${creatorsList[index].username}'),
                onPressed: () {
                  startFollowing(userInfo.userID, creatorsList[index].userID);
                  Provider.of<CreatorsList>(context, listen: false)
                      .clearSearchList();
                },
              );
            },
          ),
        ),
      ],
    ));
  }
}
