import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../globals.dart' as globals;
import '../../API/chats.dart';
import '../../models/user.dart';
import '../../models/chat.dart';
import '../../models/post.dart';

import '../camera/camera.dart';
import '../post/post_view.dart';

class ChatPageState extends StatelessWidget {
  // Responsible for setting a stream that listens to a firebase collection.
  // This collection has a list of documents, each containing information about
  // an individual chat item. When a stream is set up, builds ChatPage().

  final Chat chat;

  ChatPageState({this.chat});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection(globals.chatCollection)
            .document(chat.chatID)
            .collection('chats')
            .orderBy('time')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ChatPage(chat: chat, snapshot: snapshot.data);
          } else {
            return Scaffold(
              body: Container(),
            );
          }
        });
  }
}

class ChatPage extends StatelessWidget {
  // Main widget for the chat page's UI. Returns a column of the chat's header,
  // body, and footer. The header displays the name and profile of the chat. The
  // footer allows the user to send a new chat. The body is a scrollable list of
  // each individaul chat item. Uses SchedulerBinding() to scroll to the bottom
  // of this list after it is built.

  ChatPage({@required this.chat, @required this.snapshot});

  final Chat chat;
  final QuerySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    ItemScrollController _scrollController = new ItemScrollController();
    CollectionReference chatCollection = Firestore.instance.collection("Chats");

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(index: snapshot.documents.length - 1);
    });

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
                child: ScrollablePositionedList.builder(
                    itemScrollController: _scrollController,
                    itemCount: snapshot.documents.length,
                    itemBuilder: (context, index) {
                      if (snapshot.documents.length > 0) {
                        ChatItem chatItem = ChatItem.fromFirebase(
                            snapshot.documents[index].data);
                        User user = chat.membersMap[chatItem.uid];

                        return ChatItemWidget(chatItem: chatItem, user: user);
                      } else
                        return Container();
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

class ChatItemWidget extends StatefulWidget {
  // This widget takes a ChatItem object as an input and determines who sent the
  // chat and whether the chat is a ChatWidgetText() or a ChatWidgetPost().

  ChatItemWidget({@required this.chatItem, @required this.user});

  final ChatItem chatItem;
  final User user;

  @override
  _ChatItemWidgetState createState() => _ChatItemWidgetState();
}

class _ChatItemWidgetState extends State<ChatItemWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    MainAxisAlignment chatAxisAlignment;
    Color backgroundColor;

    if (widget.user.uid == globals.user.uid) {
      chatAxisAlignment = MainAxisAlignment.end;
      backgroundColor = Colors.grey[100];
    } else {
      chatAxisAlignment = MainAxisAlignment.start;
      backgroundColor = widget.user.profileColor;
    }

    if (widget.chatItem.isPost == false) {
      return ChatItemWidgetText(
        text: widget.chatItem.text,
        mainAxisAlignment: chatAxisAlignment,
        backgroundColor: backgroundColor,
      );
    } else {
      return ChatItemWidgetPost(
        post: Post.fromChatItem(widget.chatItem),
        height: 200,
        mainAxisAlignment: chatAxisAlignment,
      );
    }
  }
}

class ChatItemWidgetText extends StatelessWidget {
  // Returns a text field that contains a chat. Adds '\n' characters to the
  // string to break the text up into multiple lines to make it easier to read.

  final String text;
  final MainAxisAlignment mainAxisAlignment;
  final Color backgroundColor;

  ChatItemWidgetText({this.text, this.mainAxisAlignment, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    String newChat = breakIntoLines(text, 28, 20);
    return Container(
      padding: EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: backgroundColor,
              ),
              padding: EdgeInsets.all(10),
              child: Text(newChat)),
        ],
      ),
    );
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

      newString = newString.substring(0, cutoff) +
          '\n' +
          newString.substring(cutoff + 1);
      currentChar = cutoff + 1;
    }

    return newString;
  }
}

class ChatItemWidgetPost extends StatelessWidget {
  // A widget that wraps around a PostView() in order to display it correctly.
  ChatItemWidgetPost(
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
