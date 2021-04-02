import 'package:flutter/material.dart';
import 'package:test_flutter/main.dart';
import 'package:test_flutter/new_post.dart';
import 'package:test_flutter/user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'view_post.dart';
import 'user_info.dart';

String getChatName(User friend) {
  // Uses comparison between hashCodes of two userIDs to determin chat name.
  // This way, the chat name for two friends will always be the same.
  if (userID.hashCode < friend.userID.hashCode) {
    return userID + "-" + friend.userID;
  } else {
    return friend.userID + "-" + userID;
  }
}

Future<void> createChatIfDoesntExist(
    CollectionReference chatsCollection, String chatName, User friend) async {
  // If a document doesn't exist in google firestore to hold the chat, than
  // a new document is created along with the 'conversation' field that will
  // hold the conversation.
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

String breakIntoLines(
    String origString, int minCharPerLine, int maxCharPerLine) {
  /* Breaks up a chat string into multiple lines. The number of characters per
    line will be between minCharPerLine and maxCharPerLine. */

  String newString = origString;
  int currentChar = 0;

  while (newString.length - currentChar > maxCharPerLine) {
    int cutoff = currentChar;

    // Counts up until current line has at least minCharPerLine characters.
    // Continues counting until the end of a word is reached.
    while (cutoff - currentChar < minCharPerLine) cutoff++;
    while (cutoff < newString.length && origString[cutoff] != ' ') cutoff++;
    if (cutoff >= newString.length) break;

    // If the number of characters in the current line is greater than
    // maxCharPerLine, counts backwards to remove word from current line.
    if (cutoff - currentChar > maxCharPerLine)
      do {
        cutoff--;
      } while (origString[cutoff] != ' ');

    newString =
        newString.substring(0, cutoff) + '\n' + newString.substring(cutoff + 1);
    currentChar = cutoff + 1;
  }

  return newString;
}

class ChatPage extends StatelessWidget {
  // Main Widget for a chat. First makes sure that there is a document in google
  // firestore to hold the chat. Then uses a StreamBuilder() to connect to the
  // document that holds the chats. Returns a ListView.builder() that contains a
  // list of every individual chat that was sent. This list updates in real
  // time whenever a new chat is saved in the google firestore document.

  final User friend;

  ChatPage({this.friend});

  @override
  Widget build(BuildContext context) {
    String chatName = getChatName(friend);
    CollectionReference chatCollection = Firestore.instance.collection("Chats");
    createChatIfDoesntExist(chatCollection, chatName, friend);

    return Scaffold(
        appBar: ChatPageHeader(
          friend: friend,
          height: 50,
        ),
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
                        List<dynamic> conversation =
                            snapshot.data["conversation"];
                        return ListView.builder(
                            itemCount: conversation.length,
                            itemBuilder: (context, index) {
                              if (conversation.length > 0)
                                return ChatWidget(
                                    chat: Chat.fromFirebase(
                                        snapshot.data["conversation"][index]));
                              else
                                return Container();
                            });
                      }
                    }),
              ),
            ),
            ChatPageFooter(
                chatName: chatName,
                friend: friend,
                chatCollection: chatCollection),
          ],
        ));
  }
}

class ChatPageHeader extends PreferredSize {
  // Header widget that displays the name of the chat and a button that, when
  // pressed, returns the user to the FriendsPage().

  ChatPageHeader({this.height, this.friend});

  final double height;
  final User friend;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.bottomCenter,
          child: Text(friend.username, style: TextStyle(fontSize: 20)),
        ),
        Container(
            alignment: Alignment.bottomLeft,
            child: FlatButton(
                child: Text("Back"),
                onPressed: () => Navigator.of(context).pop())),
      ],
    ));
  }
}

class ChatPageFooter extends StatelessWidget {
  // Widget that allows the user to input text or take a post and send it as
  // a new chat.

  ChatPageFooter(
      {@required this.chatName,
      @required this.friend,
      @required this.chatCollection});
  final String chatName;
  final User friend;
  final CollectionReference chatCollection;
  final _chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
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
              child: Text("Send Post"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewPostScaffold(
                            cameraUsage: CameraUsage.chat,
                            friend: friend,
                          )),
                );
              }),
          FlatButton(
              child: Text("Send Chat"),
              onPressed: () async {
                await _sendChat();
                _chatController.clear();
              }),
        ],
      )
    ]);
  }

  Future<void> _sendChat() async {
    await chatCollection
        .document(chatName)
        .collection('chats')
        .document('1')
        .updateData({
      'conversation': FieldValue.arrayUnion([
        {'sender': userID, 'text': _chatController.text, 'isPost': false}
      ])
    });
  }
}

class Chat {
  // Class that holds relevant data about an individual chat. Also has a
  // constructor that creates a Chat() object from a Firestore Map.
  bool isPost;
  String sender;
  String text;
  Map postData;

  Chat.fromFirebase(Map chatData) {
    this.isPost = chatData['isPost'];
    this.sender = chatData['sender'];
    if (this.isPost)
      this.postData = chatData['post'];
    else
      this.text = chatData["text"];
  }
}

class ChatWidget extends StatelessWidget {
  // This widget takes a Chat() object as an input and determines who sent the
  // chat and whether the chat is a ChatWidgetText() or a ChatWidgetPost().

  ChatWidget({@required this.chat});

  final Chat chat;
  @override
  Widget build(BuildContext context) {
    MainAxisAlignment chatAxisAlignment;
    Color backgroundColor;

    if (chat.sender == userID) {
      chatAxisAlignment = MainAxisAlignment.end;
      backgroundColor = Colors.orange[300];
    } else {
      chatAxisAlignment = MainAxisAlignment.start;
      backgroundColor = Colors.purple[300];
    }

    if (chat.isPost == false) {
      return ChatWidgetText(
        senderID: chat.sender,
        chat: chat.text,
        mainAxisAlignment: chatAxisAlignment,
        backgroundColor: backgroundColor,
      );
    } else {
      return ChatWidgetPost(
        post: Post.fromChat(chat),
        height: 200,
        mainAxisAlignment: chatAxisAlignment,
      );
    }
  }
}

class ChatWidgetText extends StatelessWidget {
  // Returns a text field that contains a chat. Adds '\n' characters to the
  // string to break the text up into multiple lines to make it easier to read.

  final String senderID;
  final String chat;
  final MainAxisAlignment mainAxisAlignment;
  final Color backgroundColor;

  ChatWidgetText(
      {this.senderID, this.chat, this.mainAxisAlignment, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    String newChat = breakIntoLines(chat, 28, 20);
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
}

class ChatWidgetPost extends StatelessWidget {
  // A widget that wraps around a PostWidget() in order to display it correctly.
  ChatWidgetPost(
      {@required this.post,
      @required this.height,
      @required this.mainAxisAlignment});

  final Post post;
  final double height;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: mainAxisAlignment, children: <Widget>[
      PostWidget(
        post: post,
        height: height,
        aspectRatio: goldenRatio,
        onlyShowBodyAfterPressed: true,
      )
    ]);
  }
}
