import 'package:flutter/material.dart';
import 'dart:collection';

import '../models/user.dart';
import '../globals.dart' as globals;
import '../widgets/profile_pic.dart';

class Chat {
  String chatID;
  String chatName;
  bool isDirectMessage;
  List<User> members;
  Widget chatIcon;
  Color color;

  HashMap membersMap = new HashMap<String, User>();

  Chat.fromJson(Map chatJson) {
    this.chatID = chatJson["chatID"];
    this.isDirectMessage = chatJson["isDirectMessage"];
    this.members = [
      for (Map userJson in chatJson['members']) User.fromJson(userJson)
    ];

    for (User user in this.members) {
      this.membersMap[user.uid] = user;
    }
    this.members.removeWhere((item) => item.uid == globals.user.uid);

    if (this.isDirectMessage) {
      this.chatName = this.members[0].username;
      this.chatIcon = ProfilePic(
          diameter: .11 * globals.size.height, user: this.members[0]);
      this.color = this.members[0].profileColor;
    } else {
      this.chatName = chatJson['chatName'];
      this.color = Colors.blue;
    }
  }
}

class ChatItem {
  bool isPost;
  String uid;
  String text;
  Map post;

  ChatItem.fromFirebase(Map<String, dynamic> chatItemJson) {
    this.isPost = chatItemJson['isPost'];
    this.uid = chatItemJson['uid'];
    if (this.isPost)
      this.post = {
        'isImage': chatItemJson['post']['isImage'],
        'downloadURL': chatItemJson['post']['downloadURL']
      };
    else
      this.text = chatItemJson["text"];
  }

  Map toJson() {
    return (isPost) ? {'uid': uid, 'post': post} : {'uid': uid, 'text': text};
  }
}
