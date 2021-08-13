import 'dart:collection';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../API/handle_requests.dart';
import '../../API/methods/chats.dart';
import '../../models/chat.dart';
import '../../widgets/profile_pic.dart';

class ChatsProvider extends ChangeNotifier {
  ChatsProvider() {
    _chatsList = globals.chatsRepository.chatsList;
    _refreshCallback();
  }
  List<Chat> _chatsList;

  List<Chat> get chatsList => (_chatsList != null) ? _chatsList : [];

  void _refreshCallback() {
    globals.chatsRepository.stream.listen((chatsList) {
      _chatsList = chatsList;
      notifyListeners();
    });
  }
}

class Chats extends StatelessWidget {
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
              return ChatsList(chatsList: provider.chatsList, key: UniqueKey());
            })));
  }
}

class ChatsList extends StatefulWidget {
  ChatsList({
    @required this.chatsList,
    Key key,
  }) : super(key: key);

  final List<Chat> chatsList;

  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  Queue<ChatWidget> chatWidgets = new Queue<ChatWidget>();

  @override
  void initState() {
    for (int i = 0; i < widget.chatsList.length; i++) {
      chatWidgets.addLast(ChatWidget(chat: widget.chatsList[i]));
    }

    createMessagingCallback();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ChatWidget> chatWidgetsList = chatWidgets.toList();
    return ListView.builder(
        padding: EdgeInsets.only(top: .0237 * globals.size.height),
        itemCount: chatWidgetsList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                if (!chatWidgetsList[index].chat.isUpdated)
                  Container(
                      padding: EdgeInsets.only(right: .05 * globals.size.width),
                      child: Text(
                        "New chats!",
                        style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: .018 * globals.size.height),
                      )),
                GestureDetector(
                  child: chatWidgetsList[index],
                  // onTap: () => Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => ChatPage(
                  //                 chat: chatWidgetsList[index].chat,
                  //               )),
                  //     ).then(
                  //       (popAction) {
                  //         chatWidgetsList[index].chat.isUpdated = true;
                  //         switch (popAction) {
                  //           case PopAction.removeChat:
                  //             chatWidgets.remove(chatWidgetsList[index]);
                  //             break;
                  //           case PopAction.moveToTop:
                  //             ChatWidget chatWidget = chatWidgetsList[index];
                  //             chatWidgets.remove(chatWidget);
                  //             chatWidgets.addFirst(chatWidget);
                  //             break;
                  //         }

                  //         setState(() {});
                  //       },
                  //     )),
                )
              ],
            ),
          );
        });
  }

  void createMessagingCallback() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String chatID = message.data['chatID'];
      ChatWidget chatWidget = chatWidgets.singleWhere(
          (ChatWidget chatWidget) => chatWidget.chat.chatID == chatID);

      chatWidget.chat.isUpdated = false;

      chatWidgets.remove(chatWidget);
      chatWidgets.addFirst(chatWidget);
      setState(() {});
    });
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
          0, .0059 * globals.size.height, 0, .0059 * globals.size.height),
      child: Container(
          width: .921 * globals.size.width,
          height: .140 * globals.size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(globals.size.height),
            border: Border.all(width: 2.0, color: chat.color),
            color: Colors.transparent,
          ),
          child: Container(
            padding: EdgeInsets.only(left: .0513 * globals.size.width),
            child: Row(
              children: <Widget>[
                ProfilePic(
                    user: chat.members[0], diameter: .1 * globals.size.height),
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
