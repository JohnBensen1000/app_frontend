import '../baseAPI.dart';

import '../../models/chat.dart';
import '../../globals.dart' as globals;

Future<List<Chat>> getListOfChats() async {
  var response = await BaseAPI().get("v1/chats/${globals.user.uid}/");

  return [for (var chatJson in response["chats"]) Chat.fromJson(chatJson)];
}

Future<bool> postChatText(String chat, String chatID) async {
  Map postBody = {'isPost': false, 'text': chat};
  var response =
      await BaseAPI().post('v1/chats/${globals.user.uid}/$chatID/', postBody);

  return response;
}

Future<bool> postChatPost(bool isImage, String filePath, String chatID) async {
  String downloadURL = await uploadFile(filePath, chatID, isImage);

  Map postBody = {
    'isPost': true,
    'isImage': isImage,
    'downloadURL': downloadURL
  };
  var response =
      await BaseAPI().post('v1/chats/${globals.user.uid}/$chatID/', postBody);

  return response;
}
