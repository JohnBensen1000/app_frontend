import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/handle_requests.dart';

import '../../globals.dart' as globals;
import '../../API/methods/chats.dart';
import '../../models/user.dart';
import '../../models/chat.dart';
import '../../models/post.dart';
import '../../widgets/back_arrow.dart';

import '../camera/camera.dart';
import '../post/post_view.dart';

class ChatPageProvider extends ChangeNotifier {
  // Contains variables used throughout the entire page.

  ChatPageProvider({
    @required this.chatCollection,
    @required this.chat,
  });

  CollectionReference chatCollection;
  Chat chat;
}

class ChatPage extends StatelessWidget {
  // Main widget for the chat page's UI. Returns a column of the chat's header,
  // body, and footer. The header displays the name and profile of the chat. The
  // footer allows the user to send a new chat. The body is a scrollable list of
  // each individaul chat item. Uses SchedulerBinding() to automatically scroll
  // to the bottom of this list after it is built.

  ChatPage({@required this.chat});

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    double headerHeight = 170;
    double footerHeight = 100;

    return ChangeNotifierProvider(
        create: (context) => ChatPageProvider(
            chatCollection: FirebaseFirestore.instance.collection("Chats"),
            chat: chat),
        child: Scaffold(
            body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ChatPageHeader(
              chat: chat,
              height: headerHeight,
            ),
            ChatPageBody(),
            ChatPageFooter(height: footerHeight),
          ],
        )));
  }
}

class ChatPageHeader extends PreferredSize {
  // Header widget that displays the name of the chat and a button that, when
  // pressed, returns the user to the FriendsPage().

  ChatPageHeader({
    @required this.height,
    @required this.chat,
  });

  final double height;
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 30, left: 30),
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  child: BackArrow(),
                  onTap: () => Navigator.pop(context),
                )
              ],
            ),
            Container(child: chat.chatIcon),
            Text(
              chat.chatName,
              style: TextStyle(fontSize: 20),
            )
          ],
        ));
  }
}

class ChatPageBody extends StatelessWidget {
  // Sets up a streambuilder that listens to the Firestore collection that holds
  // this chat. Updates whenever a new chat item is upload to firestore. Returns
  // a list view of all chat items in order.

  @override
  Widget build(BuildContext context) {
    ChatPageProvider provider =
        Provider.of<ChatPageProvider>(context, listen: false);

    return Expanded(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(globals.chatCollection)
                .doc(provider.chat.chatID)
                .collection('chats')
                .orderBy('time', descending: true)
                .snapshots()
                .map((snapshot) {
              return snapshot.docs.map((doc) {
                ChatItem chatItem = ChatItem.fromFirebase(doc.data());
                User user = provider.chat.membersMap[chatItem.uid];
                return ChatItemWidget(chatItem: chatItem, user: user);
              }).toList();
            }),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      reverse: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        if (snapshot.data.length > 0) {
                          return snapshot.data[index];
                        } else {
                          return Container();
                        }
                      }),
                );
              } else {
                return Container();
              }
            }));
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

    return Container(
        padding: EdgeInsets.only(top: 4, bottom: 4),
        child: (widget.chatItem.isPost == false)
            ? ChatItemWidgetText(
                text: widget.chatItem.text,
                mainAxisAlignment: chatAxisAlignment,
                backgroundColor: backgroundColor,
              )
            : ChatItemWidgetPost(
                post: Post.fromChatItem(widget.chatItem),
                height: 200,
                mainAxisAlignment: chatAxisAlignment,
              ));
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
    String newChat = breakIntoLines(text, 34, 30);
    return Container(
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: backgroundColor,
              ),
              padding: EdgeInsets.all(10),
              child: Text(
                newChat,
                style: TextStyle(color: Colors.black),
              )),
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

class ChatPageFooter extends StatefulWidget {
  // Widget that allows the user to input text or take a post and send it as
  // a new chat. Only allows the user to press the "send chat" button if there
  // is text in the text field. If the user presses on the "Send Post" button,
  // then the user is taken to the camera page, where they could take a post to
  // send in the chat.

  ChatPageFooter({
    @required this.height,
  });

  final double height;

  @override
  _ChatPageFooterState createState() => _ChatPageFooterState();
}

class _ChatPageFooterState extends State<ChatPageFooter> {
  final _chatController = TextEditingController();

  bool allowSendChat = false;
  ChatPageProvider provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<ChatPageProvider>(context, listen: false);

    return Container(
      height: widget.height,
      child: Column(children: <Widget>[
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
              onChanged: (String text) {
                if (text == '')
                  setState(() {
                    allowSendChat = false;
                  });
                else if (allowSendChat == false)
                  setState(() {
                    allowSendChat = true;
                  });
              },
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                child: Text("Send Post"),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Camera(
                          cameraUsage: CameraUsage.chat, chat: provider.chat),
                    )),
              ),
              GestureDetector(
                  child: Text(
                    "Send Chat",
                    style: TextStyle(
                        color: (allowSendChat) ? Colors.black : Colors.grey),
                  ),
                  onTap: () async {
                    if (allowSendChat) {
                      setState(() {
                        allowSendChat = false;
                      });
                      await handleRequest(
                          context,
                          postChatText(
                              _chatController.text, provider.chat.chatID));
                      _chatController.clear();
                    }
                  }),
            ],
          ),
        )
      ]),
    );
  }
}
