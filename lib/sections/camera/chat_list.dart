import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';

import '../../globals.dart' as globals;
import '../../API/methods/chats.dart';
import '../../models/chat.dart';
import '../../API/handle_requests.dart';

import '../../widgets/loading_icon.dart';
import '../../widgets/generic_alert_dialog.dart';

class ChatListProvider extends ChangeNotifier {
  // Given a list of chats that the user is part of, keeps track of which chats
  // the user wants to share the post in. The hash table, isSendingTo, keeps
  // track of whether each chat will recieve the post or not. When the user
  // finally decides to share the post, this provider calls the function
  // 'sendChatPost' for every chat that is selected to recieve the post.

  ChatListProvider(
      {@required this.chatsList,
      @required this.isImage,
      @required this.file,
      @required this.caption}) {
    isSendingTo =
        Map.fromIterable(chatsList, key: (k) => k, value: (_) => false);
    numChatsSelected = 0;
  }

  final List<Chat> chatsList;
  final bool isImage;
  final File file;
  final String caption;

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

  Future<void> sharePostInChats(BuildContext context) async {
    for (Chat chat in chatsList) {
      if (isSendingTo[chat]) {
        Map response = await handleRequest(
            context, postChatPost(isImage, file, chat.chatID, caption));

        switch (response["reasonForRejection"]) {
          case "NSFW":
            await showDialog(
                context: context,
                builder: (BuildContext context) => GenericAlertDialog(
                    text:
                        "Your post has been determined to be inappropriate, so it will not be uploaded."));
            return;
        }
      }
    }
  }
}

class ChatListSnackBar extends StatelessWidget {
  // Gets a list of chats from the server. Displays a list of chats that the
  // user is part of and a button that allows the user to share the post in the
  // selected chats.

  ChatListSnackBar(
      {@required this.isImage, @required this.file, @required this.caption});

  final bool isImage;
  final File file;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: .237 * globals.size.height,
        child: FutureBuilder(
          future: handleRequest(context, getListOfChats()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done)
              return ChangeNotifierProvider(
                create: (context) => ChatListProvider(
                    chatsList: snapshot.data,
                    isImage: isImage,
                    file: file,
                    caption: caption),
                child: Column(
                  children: [
                    Container(
                      height: .178 * globals.size.height,
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
            padding: EdgeInsets.all(.0118 * globals.size.height),
            margin: EdgeInsets.all(.0059 * globals.size.height),
            decoration: BoxDecoration(
                color: (provider.isSendingTo[chat])
                    ? new Color.fromRGBO(155, 155, 155, 0.5)
                    : Colors.transparent,
                border: Border.all(
                  color: (provider.isSendingTo[chat])
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
                borderRadius: BorderRadius.all(
                    Radius.circular(.0237 * globals.size.height))),
            child: Column(
              children: [
                chat.chatIcon,
                Container(
                  padding: EdgeInsets.only(top: .01 * globals.size.height),
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
                width: .513 * globals.size.width,
                height: .047 * globals.size.height,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[600],
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(.0178 * globals.size.height))),
                child: Center(
                    child: Text("Send To ${provider.numChatsSelected} Chats",
                        style: TextStyle(
                          color: (provider.numChatsSelected > 0)
                              ? Colors.black
                              : Colors.grey[400],
                          fontSize: .024 * globals.size.height,
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
                  await provider.sharePostInChats(context);
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
          height: .0889 * globals.size.height,
          width: .256 * globals.size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                  Radius.circular(.0189 * globals.size.height))),
          child: Center(
            child: Text("You have not selected any chats.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black)),
          ),
        ));
  }
}
