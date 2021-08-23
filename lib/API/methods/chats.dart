import 'dart:io';

import '../baseAPI.dart';

import '../../models/chat.dart';
import '../../models/user.dart';
import '../../globals.dart' as globals;

Future<Map> createChat(
    List<User> members, bool isDirectMessage, String chatName) async {
  return await BaseAPI().post("v2/chats/${globals.uid}", {
    'isDirectMessage': isDirectMessage,
    'members': members.map((user) => user.toDict()).toList(),
    'chatName': chatName
  });
}

Future<List<Chat>> getListOfChats() async {
  var response = await BaseAPI().get("v2/chats/${globals.uid}");

  if (response == null) return null;

  return [for (var chatJson in response["chats"]) Chat.fromJson(chatJson)];
}

Future<Map> postChatText(String chatText, String chatID) async {
  Map postBody = {'isPost': false, 'text': chatText};
  return await BaseAPI().post('v2/chats/${globals.uid}/$chatID', postBody);
}

Future<Map> postChatPost(
    bool isImage, File file, String chatID, String caption) async {
  String downloadURL = await uploadFile(file, chatID, isImage);

  Map postBody = {
    'isPost': true,
    'isImage': isImage,
    'downloadURL': downloadURL,
    'caption': caption
  };
  return await BaseAPI().post('v2/chats/${globals.uid}/$chatID', postBody);
}

Future<Map> postIsUpdated(String chatID) async {
  return await BaseAPI().post('v2/chats/${globals.uid}/$chatID/updated', {});
}
