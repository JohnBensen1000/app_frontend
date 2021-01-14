import 'package:flutter/material.dart';
import 'main.dart';
import 'backend_connect.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'Homescreen.dart';
import 'page_labels.dart';

final backendConnection = new BackendConnection();

class User {
  String userID;
  String username;

  User({this.userID, this.username});
}

class FriendsList extends ChangeNotifier {
  final UserInfo userInfo;

  List<User> friendsList = [];

  FriendsList({this.userInfo});

  Future<void> getFriendsList() async {
    String newUrl =
        backendConnection.url + "users/${this.userInfo.userID}/friends/";
    var response = await http.get(newUrl);
    for (var friendJson in json.decode(response.body)["friends"]) {
      friendsList.add(
          User(userID: friendJson['userID'], username: friendJson['username']));
    }
    notifyListeners();
  }
}

class LoadUserInfo extends StatefulWidget {
  @override
  _LoadUserInfoState createState() => _LoadUserInfoState();
}

class _LoadUserInfoState extends State<LoadUserInfo> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
              value: FriendsList(userInfo: UserInfo.of(context)))
        ],
        child: Homescreen(
          pageLabel: PageLabel.friends,
        ));
  }
}
