import '../baseAPI.dart';

import '../../models/chat.dart';
import '../../globals.dart' as globals;

Future<List<Chat>> getListOfChats() async {
  var response = await BaseAPI().get("v1/chats/${globals.user.uid}/");

  return [for (var chatJson in response["chats"]) Chat.fromJson(chatJson)];
}

Future<bool> sendChatText(String chat, String chatID) async {
  Map postBody = {'isPost': false, 'text': chat};
  var response =
      await BaseAPI().post('v1/chats/${globals.user.uid}/$chatID/', postBody);

  return response;
}

Future<bool> sendChatPost(bool isImage, String filePath, String chatID) async {
  Map postBody = {'isPost': true, 'isImage': isImage};
  var response = await BaseAPI()
      .postFile('v1/chats/${globals.user.uid}/$chatID/', postBody, filePath);

  return response;
}
