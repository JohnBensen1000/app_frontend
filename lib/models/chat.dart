import 'package:flutter/material.dart';
import '../models/user.dart';
import '../globals.dart' as globals;
import '../widgets/profile_pic.dart';

class Chat {
  String chatID;
  String chatName;
  bool isDirectMessage;
  List<User> members;
  Widget chatIcon;

  Chat.fromJson(Map chatJson) {
    this.chatID = chatJson["chatID"];
    this.isDirectMessage = chatJson["isDirectMessage"];
    this.members = [
      for (Map userJson in chatJson['members']) User.fromJson(userJson)
    ];
    this.members.removeWhere((item) => item.uid == globals.user.uid);

    if (this.isDirectMessage) {
      this.chatName = this.members[0].username;
      this.chatIcon = ProfilePic(diameter: 85, user: this.members[0]);
    } else {
      this.chatName = chatJson['chatName'];
    }
  }
}

class ChatItem {
  bool isPost;
  User user;
  String text;
  Map post;

  ChatItem.fromFirebase(Map chatItemJson) {
    this.isPost = chatItemJson['isPost'];
    this.user = User.fromJson(chatItemJson['user']);
    if (this.isPost)
      this.post = {
        'isImage': chatItemJson['post']['isImage'],
        'downloadURL': chatItemJson['post']['downloadURL']
      };
    else
      this.text = chatItemJson["text"];
  }
}
