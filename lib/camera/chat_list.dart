import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../models/chat.dart';
import '../API/chats.dart';
import '../globals.dart' as globals;

class ChatListProvider extends ChangeNotifier {
  // Given a list of chats that the user is part of, keeps track of which chats
  // the user wants to share the post in. The hash table, sendingToHashMap,
  // keeps track of whether each chat will recieve the post or not. When the
  // user finally decides to share the post, this provider calls the function
  // 'sendChatPost' for every chat that is selected to recieve the post.

  ChatListProvider(
      {@required this.chatsList,
      @required this.isImage,
      @required this.filePath}) {
    sendingToHashMap =
        Map.fromIterable(chatsList, key: (k) => k, value: (_) => false);
    numChatsSelected = 0;
  }

  final List<Chat> chatsList;
  final bool isImage;
  final String filePath;

  Map<Chat, bool> sendingToHashMap;
  int numChatsSelected;

  void changeSendingTo(Chat chat) {
    if (!sendingToHashMap[chat])
      numChatsSelected++;
    else
      numChatsSelected--;

    sendingToHashMap[chat] = !sendingToHashMap[chat];
    notifyListeners();
  }

  Future<void> sharePostInChats() async {
    for (Chat chat in chatsList) {
      if (sendingToHashMap[chat]) {
        await sendChatPost(isImage, filePath, chat.chatID);
      }
    }
  }
}

class ChatListSnackBar extends StatelessWidget {
  // Gets a list of chats from the server. Displays a list of chats that the
  // user is part of and a button that allows the user to share the post in the
  // selected chats.
  ChatListSnackBar({@required this.isImage, @required this.filePath});

  final bool isImage;
  final String filePath;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        child: FutureBuilder(
          future: getListOfChats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done)
              return ChangeNotifierProvider(
                create: (context) => ChatListProvider(
                    chatsList: snapshot.data,
                    isImage: isImage,
                    filePath: filePath),
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) =>
                            ChatListWidget(chat: snapshot.data[index]),
                      ),
                    ),
                    Center(
                      child: SharePostButton(),
                    )
                  ],
                ),
              );
            else
              return Container();
          },
        ));
  }
}

class ChatListWidget extends StatelessWidget {
  // Displays the icon and chat name for an individual chat. When this widget is
  // tapped, either selects or de-selects the given chat to recieve the post.

  ChatListWidget({@required this.chat});

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatListProvider>(
      builder: (context, provider, child) => GestureDetector(
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: (provider.sendingToHashMap[chat])
                    ? new Color.fromRGBO(155, 155, 155, 0.5)
                    : Colors.transparent,
                border: Border.all(
                  color: Colors.grey[600],
                ),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(
              children: [
                chat.chatIcon,
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    chat.chatName,
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          ),
          onTap: () => provider.changeSendingTo(chat)),
    );
  }
}

class SharePostButton extends StatefulWidget {
  // When pressed, sends the post to all the selected chats. Displays the number
  // of chats that have been selected. If no chats are selected, then notifies
  // the user (via an AlertDialog) that no chats have been selected.

  const SharePostButton({
    Key key,
  }) : super(key: key);

  @override
  _SharePostButtonState createState() => _SharePostButtonState();
}

class _SharePostButtonState extends State<SharePostButton> {
  bool buttonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatListProvider>(
        builder: (context, provider, child) => GestureDetector(
            child: Container(
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[600],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Center(
                    child: Text("Send To ${provider.numChatsSelected} Chats",
                        style: TextStyle(
                          color: (provider.numChatsSelected > 0)
                              ? Colors.black
                              : Colors.grey[400],
                          fontSize: 20,
                        )))),
            onTap: () async {
              if (!buttonPressed) {
                if (provider.numChatsSelected == 0) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NoChatsSelectedAlert();
                      });
                } else {
                  setState(() {
                    buttonPressed = true;
                  });
                  await provider.sharePostInChats();
                  Navigator.pop(context);
                }
              }
            }));
  }
}

class NoChatsSelectedAlert extends StatelessWidget {
  // An alert dialog that tells the user that no chats have been selected.

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          height: 75,
          width: 100,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Center(
            child: Text("You have not selected any chats.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black)),
          ),
        ));
  }
}
