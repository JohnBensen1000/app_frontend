import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import '../models/chat.dart';
import '../models/post.dart';

import '../globals.dart' as globals;
import '../camera/camera.dart';
import '../post/post_view.dart';

import '../API/chats.dart';

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

  final Chat chat;

  ChatPage({this.chat});

  @override
  Widget build(BuildContext context) {
    CollectionReference chatCollection = Firestore.instance.collection("Chats");

    return Scaffold(
        appBar: ChatPageHeader(
          chat: chat,
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
                        .collection(globals.chatCollection)
                        .document(chat.chatID)
                        .collection('chats')
                        .orderBy('time')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text("No Data");
                      } else {
                        return ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              if (snapshot.data.documents.length > 0) {
                                return ChatWidget(
                                    chatItem: ChatItem.fromFirebase(
                                        snapshot.data.documents[index].data));
                              } else
                                return Container();
                            });
                      }
                    }),
              ),
            ),
            ChatPageFooter(chat: chat, chatCollection: chatCollection),
          ],
        ));
  }
}

class ChatPageHeader extends PreferredSize {
  // Header widget that displays the name of the chat and a button that, when
  // pressed, returns the user to the FriendsPage().

  ChatPageHeader({this.height, this.chat});

  final double height;
  final Chat chat;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.bottomCenter,
          child: Text(chat.chatName, style: TextStyle(fontSize: 20)),
        ),
        Container(
            alignment: Alignment.bottomLeft,
            child: FlatButton(
                child: Text("Back"),
                onPressed: () => Navigator.of(context).pop())),
      ],
    );
  }
}

class ChatPageFooter extends StatelessWidget {
  // Widget that allows the user to input text or take a post and send it as
  // a new chat.

  ChatPageFooter({@required this.chat, @required this.chatCollection});

  final Chat chat;
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
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Camera(cameraUsage: CameraUsage.chat, chat: chat),
                )),
          ),
          FlatButton(
              child: Text("Send Chat"),
              onPressed: () async {
                await sendChatText(_chatController.text, chat.chatID);
                _chatController.clear();
              }),
        ],
      )
    ]);
  }
}

class ChatWidget extends StatelessWidget {
  // This widget takes a Chat() object as an input and determines who sent the
  // chat and whether the chat is a ChatWidgetText() or a ChatWidgetPost().

  ChatWidget({@required this.chatItem});

  final ChatItem chatItem;

  @override
  Widget build(BuildContext context) {
    MainAxisAlignment chatAxisAlignment;
    Color backgroundColor;

    if (chatItem.user.uid == globals.user.uid) {
      chatAxisAlignment = MainAxisAlignment.end;
      backgroundColor = Colors.orange[300];
    } else {
      chatAxisAlignment = MainAxisAlignment.start;
      backgroundColor = Colors.purple[300];
    }

    if (chatItem.isPost == false) {
      return ChatWidgetText(
        senderID: chatItem.user.userID,
        chat: chatItem.text,
        mainAxisAlignment: chatAxisAlignment,
        backgroundColor: backgroundColor,
      );
    } else {
      return ChatWidgetPost(
        post: Post.fromChatItem(chatItem),
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
  // A widget that wraps around a PostView() in order to display it correctly.
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
      PostView(
        post: post,
        height: height,
        aspectRatio: globals.goldenRatio,
        postStage: PostStage.onlyPost,
        fromChatPage: true,
      )
    ]);
  }
}
