import 'dart:io';

import '../baseAPI.dart';

import '../../models/chat.dart';
import '../../globals.dart' as globals;

Future<List<Chat>> getListOfChats() async {
  var response = await BaseAPI().get("v1/chats/${globals.user.uid}/");

  return [for (var chatJson in response["chats"]) Chat.fromJson(chatJson)];
}

Future<bool> postChatText(String chat, String chatID) async {
  Map postBody = {'isPost': false, 'text': chat};
  return await BaseAPI()
      .post('v1/chats/${globals.user.uid}/$chatID/', postBody);
}

Future<bool> postChatPost(bool isImage, File file, String chatID) async {
  String downloadURL = await uploadFile(file, chatID, isImage);

  Map postBody = {
    'isPost': true,
    'isImage': isImage,
    'downloadURL': downloadURL
  };
  return await BaseAPI()
      .post('v1/chats/${globals.user.uid}/$chatID/', postBody);
}
