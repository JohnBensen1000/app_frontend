import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../models/chat.dart';
import '../../widgets/profile_pic.dart';

import 'direct_message.dart';

class ChatsProvider extends ChangeNotifier {
  // Keeps track of the list of chats that the user is part of. Rebuilds the
  // chat page every time the chat repository is updated. When a user leaves a
  // chat, that chat is moved to the top of the chats list.

  ChatsProvider() {
    _chatsList = globals.chatsRepository.chatsList;
    _refreshCallback();
  }
  List<Chat> _chatsList;

  List<Chat> get chatsList => (_chatsList != null) ? _chatsList : [];

  void moveToTop(String chatID) {
    Chat chat = _chatsList.firstWhere((chat) => chat.chatID == chatID);
    _chatsList.removeWhere((chat) => chat.chatID == chatID);
    _chatsList.insert(0, chat);

    notifyListeners();
  }

  void _refreshCallback() {
    globals.chatsRepository.stream.listen((chatsList) {
      _chatsList = chatsList;
      notifyListeners();
    });
  }
}

class Chats extends StatelessWidget {
  // Returns a listview of chat widgets. Each chat widget, when pressed, takes
  // the user to the page page associated with that chat.

  Chats({
    @required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: .0256 * globals.size.width),
        child: ChangeNotifierProvider(
            create: (_) => ChatsProvider(),
            child: Consumer<ChatsProvider>(builder: (context, provider, child) {
              return ListView.builder(
                  padding: EdgeInsets.only(top: .0237 * globals.size.height),
                  itemCount: provider.chatsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!provider.chatsList[index].isUpdated)
                            Transform.translate(
                              offset: Offset(.25 * globals.size.width, 0),
                              child: Container(
                                  child: Text(
                                "New chats!",
                                style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: .018 * globals.size.height),
                              )),
                            ),
                          GestureDetector(
                              child: ChatWidget(
                                chat: provider.chatsList[index],
                              ),
                              onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                            chat: provider.chatsList[index])),
                                  ).then((popAction) {
                                    if (popAction == PopAction.moveToTop) {
                                      provider.moveToTop(
                                          provider.chatsList[index].chatID);
                                    }
                                  }))
                        ],
                      ),
                    );
                  });
            })));
  }
}

class ChatWidget extends StatelessWidget {
  // Displays a widget for an individual chat. When pressed, takes the user to
  // the direct message page.

  const ChatWidget({Key key, @required this.chat}) : super(key: key);

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          0, .005 * globals.size.height, 0, .0059 * globals.size.height),
      child: Container(
          width: .921 * globals.size.width,
          height: .112 * globals.size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(globals.size.height),
            border: Border.all(width: 2.0, color: chat.color),
            color: Colors.transparent,
          ),
          child: Container(
            padding: EdgeInsets.only(left: .0513 * globals.size.width),
            child: Row(
              children: <Widget>[
                Container(
                    child: ProfilePic(
                        user: chat.members[0],
                        diameter: .075 * globals.size.height)),
                Container(
                  padding: EdgeInsets.only(left: .018 * globals.size.width),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        chat.chatName,
                        style: TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: .024 * globals.size.height,
                          color: const Color(0xff000000),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
