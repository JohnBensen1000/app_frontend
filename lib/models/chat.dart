import '../models/user.dart';
import '../globals.dart' as globals;

class Chat {
  String chatID;
  String chatName;
  bool isDirectMessage;
  List<User> members;

  Chat.fromJson(Map chatJson) {
    this.chatID = chatJson["chatID"];
    this.isDirectMessage = chatJson["isDirectMessage"];
    this.members = [
      for (Map userJson in chatJson['members']) User.fromJson(userJson)
    ];
    this.members.removeWhere((item) => item.uid == globals.user.uid);

    if (this.isDirectMessage)
      this.chatName = this.members[0].username;
    else
      this.chatName = chatJson['chatName'];
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
