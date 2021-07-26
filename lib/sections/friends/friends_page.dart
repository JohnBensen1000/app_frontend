import 'dart:collection';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../API/handle_requests.dart';
import '../../API/methods/chats.dart';
import '../../API/methods/relations.dart';
import '../../models/chat.dart';

import 'direct_message.dart';
import 'new_followers.dart';

class FriendsProvider extends ChangeNotifier {
  // Allows any widget below this to rebuild the friends page from scratch.
  void resetState() {
    notifyListeners();
  }
}

class Friends extends StatelessWidget {
  // Gets a list of chats from the server. Returns a column of two widgets:
  // NewFollowersAlert() and ChatsList(). NewFollowersAlert() shows how many
  // new followers the user has and, when pressed, takes the user to a new page
  // where they could follow/not follow these new followers back. ChatsList()
  // is a ListView of every chat that the user is in.

  Friends({@required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: .0256 * globals.size.width),
      child: ChangeNotifierProvider(
          create: (_) => FriendsProvider(),
          child: Consumer<FriendsProvider>(
              builder: (context, provider, child) => FutureBuilder(
                    future: handleRequest(context, getListOfChats()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return Column(children: <Widget>[
                          NewFollowersAlert(),
                          ChatsList(
                            chatsList: snapshot.data,
                          )
                        ]);
                      } else {
                        return Container();
                      }
                    },
                  ))),
    );
  }
}

class NewFollowersAlert extends StatefulWidget {
  // This widget displays if new people. When pressed, sends user to new
  // followers page. When the user returns from the new followers page, calls
  // resetState() to reset the state of the page (to update the friends list).

  @override
  _NewFollowersAlertState createState() => _NewFollowersAlertState();
}

class _NewFollowersAlertState extends State<NewFollowersAlert> {
  String newFollowingText = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: handleRequest(context, getNewFollowers()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data.length > 0) {
            newFollowingText = "New Followers: ${snapshot.data.length}";

            return Padding(
                padding: EdgeInsets.only(bottom: .0059 * globals.size.height),
                child: GestureDetector(
                    child: Container(
                      height: .0237 * globals.size.height,
                      width: .513 * globals.size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.all(
                              Radius.circular(globals.size.height))),
                      child: Center(child: Text(newFollowingText)),
                    ),
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => NewFollowersPage(
                                    newFollowersList: snapshot.data,
                                  )),
                        ).then((newFriends) {
                          Provider.of<FriendsProvider>(context, listen: false)
                              .resetState();
                        })));
          } else {
            return Container();
          }
        });
  }
}

class ChatsList extends StatefulWidget {
  // Returns a list view of every chat that the user is in. Initiates a callback
  // that listens to Firebase Messaging. Whenever some one sends a new chat in
  // any of the chats, this callback gets a notification from Firebase. When
  // this happens, the chat that has a new chat is sent to the top of the List
  // View, and "New Chats!" is displayed on the chat widget. When the user
  // returns from a direct message, the "New Chats!" is no longer displayed on
  // the chat widget. If the user blocks another user from inside a direct
  // message, then resetState is set to true.

  ChatsList({@required this.chatsList});

  final List<Chat> chatsList;

  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  Queue<ChatWidget> chatWidgets = new Queue<ChatWidget>();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.chatsList.length; i++) {
      chatWidgets.addLast(ChatWidget(chat: widget.chatsList[i]));
    }

    createMessagingCallback();
  }

  @override
  Widget build(BuildContext context) {
    List<ChatWidget> chatWidgetsList = chatWidgets.toList();

    return Expanded(
        child: ListView.builder(
            padding: EdgeInsets.only(top: .0237 * globals.size.height),
            itemCount: chatWidgetsList.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    if (!chatWidgetsList[index].chat.isUpdated)
                      Container(
                          padding:
                              EdgeInsets.only(right: .05 * globals.size.width),
                          child: Text(
                            "New chats!",
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: .018 * globals.size.height),
                          )),
                    GestureDetector(
                        child: chatWidgetsList[index],
                        onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                        chat: chatWidgetsList[index].chat,
                                      )),
                            ).then(
                              (popAction) {
                                chatWidgetsList[index].chat.isUpdated = true;
                                switch (popAction) {
                                  case PopAction.removeChat:
                                    chatWidgets.remove(chatWidgetsList[index]);
                                    break;
                                  case PopAction.moveToTop:
                                    ChatWidget chatWidget =
                                        chatWidgetsList[index];
                                    chatWidgets.remove(chatWidget);
                                    chatWidgets.addFirst(chatWidget);
                                    break;
                                }

                                setState(() {});
                              },
                            )),
                  ],
                ),
              );
            }));
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
                chat.chatIcon,
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
