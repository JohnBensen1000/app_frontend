import 'package:flutter/material.dart';
import 'backend_connect.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'home_screen.dart';

final serverAPI = new ServerAPI();

String userID = "John1000";
double goldenRatio = 1.6180;

class User {
  String userID;
  String username;

  User({this.userID, this.username});
}

class FriendsList extends ChangeNotifier {
  List<User> friendsList = [];

  Future<void> getFriendsList() async {
    String newUrl = serverAPI.url + "users/$userID/friends/";
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
    return ChangeNotifierProvider(
        create: (context) => FriendsList(),
        child: Homescreen(
          pageLabel: PageLabel.friends,
        ));
  }
}
