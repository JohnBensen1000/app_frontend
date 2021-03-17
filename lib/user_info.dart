import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';

import 'backend_connect.dart';
import 'home_screen.dart';
import 'chat_page.dart';

final serverAPI = new ServerAPI();

String userID = "Nick1000";
double goldenRatio = 1.6180;

class User {
  String userID;
  String username;

  User({this.userID, this.username});
}

class Post {
  //Constructor
  String userID;
  String username;
  String postID;
  bool isImage;
  var postURL;

  Post.fromJson(Map postJson) {
    print(postJson);
    this.userID = postJson["userID"];
    this.username = postJson["username"];
    this.isImage = postJson["isImage"];
    this.postID = postJson["postID"].toString();

    String fileExtension = (this.isImage) ? 'png' : 'mp4';

    this.postURL = FirebaseStorage.instance
        .ref()
        .child("${postJson["userID"]}")
        .child("${postJson["postID"].toString()}.$fileExtension")
        .getDownloadURL();
  }

  Post.fromChat(Chat chat) {
    this.userID = chat.sender;
    this.username = null;
    this.postURL = chat.postData["postURL"];
    this.isImage = chat.postData['isImage'];
  }
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
    // return ChangeNotifierProvider(
    //     create: (context) => FriendsList(),
    //     child: Homescreen(
    //       pageLabel: PageLabel.friends,
    //     ));
    return Homescreen(pageLabel: PageLabel.friends);
  }
}
