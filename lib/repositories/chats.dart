import 'dart:async';

import '../../models/chat.dart';
import '../../API/methods/chats.dart';
import '../../globals.dart' as globals;

import 'repository.dart';

class ChatsRepository extends Repository<List<Chat>> {
  ChatsRepository() {
    _getChatsList();
    _refreshChatsListCallback();
  }
  List<Chat> _chatsList;

  List<Chat> get chatsList => _chatsList;

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
}
