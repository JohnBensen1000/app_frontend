import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../models/chat.dart';
import '../../API/methods/chats.dart';
import '../../globals.dart' as globals;

import 'repository.dart';

class ChatsRepository extends Repository<List<Chat>> {
  ChatsRepository() {
    _getChatsList();
    _refreshChatsListCallback();
    _newChatsCallback();
  }
  String _openedChatId;
  List<Chat> _chatsList;

  List<Chat> get chatsList => _chatsList;

  void setOpenedChatId(String newOpenedChatId) =>
      _openedChatId = newOpenedChatId;

  void clearOpenedChatId() => _openedChatId = null;

  Future<void> setAsUpdated(String chatID) async {
    Map response = await postIsUpdated(chatID);

    if (response != null) {
      Chat chat = _chatsList.firstWhere((Chat chat) => chat.chatID == chatID);
      chat.isUpdated = response['isUpdated'];
      super.controller.sink.add(_chatsList);
    }
  }

  Future<void> refreshChatsList() => _getChatsList();

  Future<void> _getChatsList() async {
    var response = await getListOfChats();

    if (response != null) {
      _chatsList = response;
      super.controller.sink.add(_chatsList);
    }
  }

  Future<void> _refreshChatsListCallback() async {
    globals.blockedRepository.stream.listen((_) => _getChatsList());
    globals.followingRepository.stream.listen((_) => _getChatsList());
  }

  Future<void> _newChatsCallback() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String chatID = message.data['chatID'];

      if (chatID != _openedChatId) {
        Chat chat = _chatsList.firstWhere((Chat chat) => chat.chatID == chatID);
        chat.isUpdated = false;

        _chatsList.removeWhere((chat) => chat.chatID == chatID);
        _chatsList = [chat] + _chatsList;

        super.controller.sink.add(_chatsList);
      }
    });
  }
}
