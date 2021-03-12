import 'package:flutter/material.dart';
import 'package:test_flutter/user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_info.dart';

String getChatName(User friend) {
  if (userID.hashCode < friend.userID.hashCode) {
    return userID + "-" + friend.userID;
  } else {
    return friend.userID + "-" + userID;
  }
}

Future<void> createChatIfDoesntExist(
    CollectionReference chatsCollection, String chatName, User friend) async {
  await chatsCollection.document(chatName).get().then((doc) {
    if (!doc.exists) {
      chatsCollection.document(chatName).setData({
        "Members": [userID, friend.userID]
      });
      chatsCollection
          .document(chatName)
          .collection('chats')
          .document('1')
          .setData({'conversation': []});
    }
  });
}

class ChatPage extends StatelessWidget {
  final _chatController = TextEditingController();
  final User friend;

  ChatPage({this.friend});

  @override
  Widget build(BuildContext context) {
    String chatName = getChatName(friend);
    CollectionReference chatsCollection =
        Firestore.instance.collection("Chats");
    createChatIfDoesntExist(chatsCollection, chatName, friend);

    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: StreamBuilder(
                stream: Firestore.instance
                    .collection('Chats')
                    .document(chatName)
                    .collection('chats')
                    .document('1')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text("No Data");
                  } else {
                    List<dynamic> conversation = snapshot.data["conversation"];
                    print(conversation);
                    return ListView.builder(
                        itemCount: conversation.length,
                        itemBuilder: (context, index) {
                          dynamic chat = conversation[index];
                          print(chat);
                          if (chat['isPost'] == false) {
                            if (chat['sender'] == userID) {
                              return Chat(
                                senderID: chat['sender'],
                                chat: chat['chat'],
                                mainAxisAlignment: MainAxisAlignment.end,
                                backgroundColor: Colors.orange[300],
                              );
                            } else {
                              return Chat(
                                senderID: chat['sender'],
                                chat: chat['chat'],
                                mainAxisAlignment: MainAxisAlignment.start,
                                backgroundColor: Colors.purple[300],
                              );
                            }
                          } else
                            return Container(child: Text("Hello"));
                        });
                  }
                }),
          ),
        ),
        Container(
          width: 350.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23.0),
            color: const Color(0xffffffff),
            border: Border.all(width: 1.0, color: const Color(0xff707070)),
          ),
          child: Container(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: TextField(
              controller: _chatController,
              decoration: InputDecoration(
                hintText: "Chat",
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton(
                child: Text("Exit Chat"),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            FlatButton(
                child: Text("Send Chat"),
                onPressed: () async {
                  await _sendChat(chatsCollection, chatName);
                  _chatController.clear();
                }),
          ],
        ),
      ],
    ));
  }

  Future<void> _sendChat(
      CollectionReference chatsCollection, String chatName) async {
    await chatsCollection
        .document(chatName)
        .collection('chats')
        .document('1')
        .updateData({
      'conversation': FieldValue.arrayUnion([
        {'sender': userID, 'chat': _chatController.text, 'isPost': false}
      ])
    });
  }
}

class Chat extends StatelessWidget {
  final String senderID;
  final String chat;
  final MainAxisAlignment mainAxisAlignment;
  final Color backgroundColor;

  Chat(
      {this.senderID, this.chat, this.mainAxisAlignment, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    String newChat = _breakIntoLines(28, 20);
    return Container(
      padding: EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(13)),
                color: backgroundColor,
              ),
              padding: EdgeInsets.all(10),
              child: Text(newChat)),
        ],
      ),
    );
  }

  String _breakIntoLines(int minCharPerLine, int maxCharPerLine) {
    /* Breaks up a chat string into multiple lines. The number of characters per
    line will be between minCharPerLine and maxCharPerLine. */

    String newChat = chat;
    int currentChar = 0;

    while (newChat.length - currentChar > maxCharPerLine) {
      int cutoff = currentChar;

      // Counts up until current line has at least minCharPerLine characters.
      // Continues counting until the end of a word is reached.
      while (cutoff - currentChar < minCharPerLine) cutoff++;
      while (cutoff < newChat.length && chat[cutoff] != ' ') cutoff++;
      if (cutoff >= newChat.length) break;

      // If the number of characters in the current line is greater than
      // maxCharPerLine, counts backwards to remove word from current line.
      if (cutoff - currentChar > maxCharPerLine)
        do {
          cutoff--;
        } while (chat[cutoff] != ' ');

      newChat =
          newChat.substring(0, cutoff) + '\n' + newChat.substring(cutoff + 1);
      currentChar = cutoff + 1;
    }

    return newChat;
  }
}
