import 'package:flutter/material.dart';
import 'backend_connect.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'Homescreen.dart';

final backendConnection = new BackendConnection();

String userID = "John1000";

class User {
  String userID;
  String username;

  User({this.userID, this.username});
}

class FriendsList extends ChangeNotifier {
  List<User> friendsList = [];

  Future<void> getFriendsList() async {
    String newUrl = backendConnection.url + "users/$userID/friends/";
    var response = await http.get(newUrl);
    for (var friendJson in json.decode(response.body)["friends"]) {
      friendsList.add(
          User(userID: friendJson['userID'], username: friendJson['username']));
    }
    notifyListeners();
  }
}

class UserInfo extends StatefulWidget {
  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [ChangeNotifierProvider.value(value: FriendsList())],
        child: Homescreen(
          pageLabel: PageLabel.friends,
        ));
  }
}
