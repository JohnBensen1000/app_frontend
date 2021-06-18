import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:test_flutter/API/handle_requests.dart';

import '../../API/methods/chats.dart';
import '../../models/chat.dart';

import '../../widgets/loading_icon.dart';

class ChatListProvider extends ChangeNotifier {
  // Given a list of chats that the user is part of, keeps track of which chats
  // the user wants to share the post in. The hash table, isSendingTo, keeps
  // track of whether each chat will recieve the post or not. When the user
  // finally decides to share the post, this provider calls the function
  // 'sendChatPost' for every chat that is selected to recieve the post.

  ChatListProvider(
      {@required this.chatsList, @required this.isImage, @required this.file}) {
    isSendingTo =
        Map.fromIterable(chatsList, key: (k) => k, value: (_) => false);
    numChatsSelected = 0;
  }

  final List<Chat> chatsList;
  final bool isImage;
  final File file;

  Map<Chat, bool> isSendingTo;
  int numChatsSelected;

  void changeSendingTo(Chat chat) {
    if (!isSendingTo[chat])
      numChatsSelected++;
    else
      numChatsSelected--;

    isSendingTo[chat] = !isSendingTo[chat];
    notifyListeners();
  }

  Future<void> sharePostInChats() async {
    for (Chat chat in chatsList) {
      if (isSendingTo[chat]) {
        await postChatPost(isImage, file, chat.chatID);
      }
    }
  }
}

class ChatListSnackBar extends StatelessWidget {
  // Gets a list of chats from the server. Displays a list of chats that the
  // user is part of and a button that allows the user to share the post in the
  // selected chats.

  ChatListSnackBar({@required this.isImage, @required this.file});

  final bool isImage;
  final File file;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        child: FutureBuilder(
          future: handleRequest(context, getListOfChats()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done)
              return ChangeNotifierProvider(
                create: (context) => ChatListProvider(
                    chatsList: snapshot.data, isImage: isImage, file: file),
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
                color: (provider.isSendingTo[chat])
                    ? new Color.fromRGBO(155, 155, 155, 0.5)
                    : Colors.transparent,
                border: Border.all(
                  color: (provider.isSendingTo[chat])
                      ? Colors.grey[600]
                      : Colors.grey[400],
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
  // the user (via an AlertDialog) that no chats have been selected. Displays
  // a loading screen (LoadingIcon()) while waiting for the post to be uploaded
  // to all the chats.

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
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (buttonPressed)
        showDialog(
          context: context,
          builder: (context) {
            return LoadingIcon();
          },
        );
    });

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
                  int count = 0;
                  Navigator.popUntil(context, (route) {
                    return count++ == 2;
                  });
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
