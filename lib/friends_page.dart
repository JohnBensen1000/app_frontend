import 'package:flutter/material.dart';
import 'package:test_flutter/user_info.dart';
import 'backend_connect.dart';
import 'package:provider/provider.dart';
import 'user_info.dart';
import 'main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final backendConnection = new BackendConnection();

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    // UserInfo userInfo = UserInfo.of(context);
    return Consumer<FriendsList>(
        builder: (context, friendsList, child) => Container(
            height: 700,
            width: double.infinity,
            child: ListView.builder(
                itemCount: friendsList.friendsList.length,
                itemBuilder: (BuildContext context, int index) {
                  return FriendWidget(
                      // userInfo: userInfo,
                      friend: friendsList.friendsList[index]);
                })));
  }
}

class FriendWidget extends StatelessWidget {
  // final UserInfo userInfo;
  final User friend;

  FriendWidget({this.friend});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatPage(
                    // userInfo: userInfo,
                    friend: friend,
                  )),
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Container(
            width: 359.0,
            height: 118.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(61.0),
              border: Border.all(width: 2.0, color: const Color(0xff22a2ff)),
            ),
            child: Container(
              padding: EdgeInsets.only(left: 20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 85.0,
                    height: 87.0,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                      // image: DecorationImage(
                      //   image: const AssetImage(''),
                      //   fit: BoxFit.cover,
                      // ),
                      border: Border.all(
                          width: 5.0, color: const Color(0xff22a2ff)),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          this.friend.username,
                          style: TextStyle(
                            fontFamily: 'SF Pro Text',
                            fontSize: 15,
                            color: const Color(0xff000000),
                            letterSpacing: -0.36,
                            height: 1.4666666666666666,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                          width: 34.0,
                          child: Text(
                            'Tier 7 ',
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 10,
                              color: const Color(0xff000000),
                              letterSpacing: -0.004099999964237213,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: Offset(0.0, 5.5),
                              child: Container(
                                width: 73.0,
                                height: 11.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.0),
                                  color: const Color(0xffffffff),
                                  border: Border.all(
                                      width: 1.0,
                                      color: const Color(0xff22a2ff)),
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(0.0, -5.5),
                              child: SvgPicture.string(
                                _svg_qlaync,
                                allowDrawingOutsideViewBox: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  final _chatController = TextEditingController();
  // final UserInfo userInfo;
  final User friend;

  ChatPage({this.friend});

  String _getChatName() {
    if (userID.hashCode < friend.userID.hashCode) {
      return userID + "-" + friend.userID;
    } else {
      return friend.userID + "-" + userID;
    }
  }

  Future<void> _createChatIfDoesntExist(
      CollectionReference chatsCollection, String chatName) async {
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

  Future<void> _sendChat(
      CollectionReference chatsCollection, String chatName) async {
    await chatsCollection
        .document(chatName)
        .collection('chats')
        .document('1')
        .updateData({
      'conversation': FieldValue.arrayUnion([
        {'sender': userID, 'chat': _chatController.text}
      ])
    });
  }

  @override
  Widget build(BuildContext context) {
    String chatName = _getChatName();
    CollectionReference chatsCollection =
        Firestore.instance.collection("Chats");
    _createChatIfDoesntExist(chatsCollection, chatName);

    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20.0),
          height: 700.0,
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

                  return ListView.builder(
                      itemCount: conversation.length,
                      itemBuilder: (context, index) {
                        dynamic chat = conversation[index];
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
                      });
                }
              }),
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
}

class Chat extends StatelessWidget {
  final String senderID;
  final String chat;
  final MainAxisAlignment mainAxisAlignment;
  final Color backgroundColor;

  Chat(
      {this.senderID, this.chat, this.mainAxisAlignment, this.backgroundColor});

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

  @override
  Widget build(BuildContext context) {
    String newChat = _breakIntoLines(28, 20);
    return Container(
      padding: EdgeInsets.only(top: 2.5, bottom: 2.5),
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

const String _svg_ffj51b =
    '<svg viewBox="23.0 3.7 1.3 4.0" ><path transform="translate(23.0, 3.67)" d="M 0 0 L 0 4 C 0.8047311305999756 3.661223411560059 1.328037977218628 2.873133182525635 1.328037977218628 2 C 1.328037977218628 1.126866698265076 0.8047311305999756 0.3387765288352966 0 0" fill="#000000" fill-opacity="0.4" stroke="none" stroke-width="1" stroke-opacity="0.4" stroke-miterlimit="10" stroke-linecap="butt" /></svg>';
const String _svg_32sc6 =
    '<svg viewBox="295.3 3.3 15.3 11.0" ><path transform="translate(295.34, 3.33)" d="M 7.667118072509766 10.99980068206787 C 7.583868026733398 10.99980068206787 7.502848148345947 10.96601009368896 7.444818019866943 10.90710067749023 L 5.438717842102051 8.884799957275391 C 5.37655782699585 8.824450492858887 5.342437744140625 8.740139961242676 5.345118045806885 8.653500556945801 C 5.346918106079102 8.567130088806152 5.384637832641602 8.48445987701416 5.448617935180664 8.426700592041016 C 6.068027973175049 7.903049945831299 6.855897903442383 7.61467981338501 7.667118072509766 7.61467981338501 C 8.478347778320312 7.61467981338501 9.266218185424805 7.903059959411621 9.885618209838867 8.426700592041016 C 9.949607849121094 8.48445987701416 9.98731803894043 8.567120552062988 9.989117622375488 8.653500556945801 C 9.990918159484863 8.740429878234863 9.956467628479004 8.824740409851074 9.894618034362793 8.884799957275391 L 7.889418125152588 10.90710067749023 C 7.831387996673584 10.96601009368896 7.750368118286133 10.99980068206787 7.667118072509766 10.99980068206787 Z M 11.18971824645996 7.451099872589111 C 11.10976791381836 7.451099872589111 11.03336811065674 7.420739650726318 10.97461795806885 7.365599632263184 C 10.06604766845703 6.544379711151123 8.891417503356934 6.092099666595459 7.667118072509766 6.092099666595459 C 6.443657875061035 6.092999935150146 5.269988059997559 6.545269966125488 4.36231803894043 7.365599632263184 C 4.303567886352539 7.420729637145996 4.227168083190918 7.451099872589111 4.147217750549316 7.451099872589111 C 4.064228057861328 7.451099872589111 3.986237764358521 7.418819904327393 3.927617788314819 7.360199928283691 L 2.768417596817017 6.189300060272217 C 2.706577777862549 6.127449989318848 2.673017740249634 6.045629978179932 2.673917770385742 5.958899974822998 C 2.674807786941528 5.871150016784668 2.709967613220215 5.789649963378906 2.772917747497559 5.729399681091309 C 4.106788158416748 4.489140033721924 5.845237731933594 3.806100130081177 7.668017864227295 3.806100130081177 C 9.490477561950684 3.806100130081177 11.229248046875 4.489140033721924 12.56401824951172 5.729399681091309 C 12.62696838378906 5.790549755096436 12.66212749481201 5.872049808502197 12.66301822662354 5.958899974822998 C 12.66391754150391 6.045629978179932 12.63035774230957 6.127449989318848 12.56851768493652 6.189300060272217 L 11.40931797027588 7.360199928283691 C 11.35068798065186 7.418819904327393 11.27270793914795 7.451099872589111 11.18971824645996 7.451099872589111 Z M 13.85911750793457 4.758299827575684 C 13.77818775177002 4.758299827575684 13.70179748535156 4.726979732513428 13.64401817321777 4.67009973526001 C 12.02446746826172 3.131530046463013 9.901827812194824 2.284200191497803 7.667118072509766 2.284200191497803 C 5.431828022003174 2.284200191497803 3.308867692947388 3.131530046463013 1.68931782245636 4.670109748840332 C 1.631547808647156 4.726969718933105 1.555147767066956 4.758299827575684 1.474217772483826 4.758299827575684 C 1.390907764434814 4.758299827575684 1.312917828559875 4.725699901580811 1.254617810249329 4.666500091552734 L 0.09361779689788818 3.496500015258789 C 0.03235779702663422 3.434340000152588 -0.0008822033414617181 3.352830171585083 1.779667218215764e-05 3.267000198364258 C 0.0009177966858260334 3.180460214614868 0.03511779755353928 3.099590063095093 0.09631779789924622 3.039300203323364 C 2.143527746200562 1.079370021820068 4.832218170166016 0 7.667118072509766 0 C 10.50233840942383 0 13.19070816040039 1.079380035400391 15.23701763153076 3.039300203323364 C 15.2982177734375 3.099590063095093 15.33241748809814 3.180460214614868 15.33331775665283 3.267000198364258 C 15.33421802520752 3.352830171585083 15.30097770690918 3.434340000152588 15.23971748352051 3.496500015258789 L 14.0787181854248 4.666500091552734 C 14.02041816711426 4.725699901580811 13.94242763519287 4.758299827575684 13.85911750793457 4.758299827575684 Z" fill="#000000" stroke="none" stroke-width="1" stroke-miterlimit="10" stroke-linecap="butt" /></svg>';
const String _svg_7e8xj2 =
    '<svg viewBox="273.3 3.7 17.0 10.7" ><path transform="translate(273.34, 3.67)" d="M 16.00020027160645 10.6668004989624 L 15.00029945373535 10.6668004989624 C 14.44894981384277 10.6668004989624 14.00039958953857 10.2182502746582 14.00039958953857 9.666900634765625 L 14.00039958953857 0.9999000430107117 C 14.00039958953857 0.4485500752925873 14.44894981384277 7.066725515869621e-08 15.00029945373535 7.066725515869621e-08 L 16.00020027160645 7.066725515869621e-08 C 16.55154991149902 7.066725515869621e-08 17.00010108947754 0.4485500752925873 17.00010108947754 0.9999000430107117 L 17.00010108947754 9.666900634765625 C 17.00010108947754 10.2182502746582 16.55154991149902 10.6668004989624 16.00020027160645 10.6668004989624 Z M 11.33369922637939 10.6668004989624 L 10.33290004730225 10.6668004989624 C 9.781549453735352 10.6668004989624 9.332999229431152 10.2182502746582 9.332999229431152 9.666900634765625 L 9.332999229431152 3.333600044250488 C 9.332999229431152 2.782249927520752 9.781549453735352 2.333699941635132 10.33290004730225 2.333699941635132 L 11.33369922637939 2.333699941635132 C 11.88504981994629 2.333699941635132 12.33360004425049 2.782249927520752 12.33360004425049 3.333600044250488 L 12.33360004425049 9.666900634765625 C 12.33360004425049 10.2182502746582 11.88504981994629 10.6668004989624 11.33369922637939 10.6668004989624 Z M 6.666300296783447 10.6668004989624 L 5.666399955749512 10.6668004989624 C 5.115049839019775 10.6668004989624 4.666500091552734 10.2182502746582 4.666500091552734 9.666900634765625 L 4.666500091552734 5.66640043258667 C 4.666500091552734 5.115050315856934 5.115049839019775 4.666500091552734 5.666399955749512 4.666500091552734 L 6.666300296783447 4.666500091552734 C 7.218140125274658 4.666500091552734 7.667099952697754 5.115050315856934 7.667099952697754 5.66640043258667 L 7.667099952697754 9.666900634765625 C 7.667099952697754 10.2182502746582 7.218140125274658 10.6668004989624 6.666300296783447 10.6668004989624 Z M 1.999799966812134 10.6668004989624 L 0.9998999834060669 10.6668004989624 C 0.4485500156879425 10.6668004989624 0 10.2182502746582 0 9.666900634765625 L 0 7.667100429534912 C 0 7.115260124206543 0.4485500156879425 6.666300296783447 0.9998999834060669 6.666300296783447 L 1.999799966812134 6.666300296783447 C 2.55115008354187 6.666300296783447 2.99970006942749 7.115260124206543 2.99970006942749 7.667100429534912 L 2.99970006942749 9.666900634765625 C 2.99970006942749 10.2182502746582 2.55115008354187 10.6668004989624 1.999799966812134 10.6668004989624 Z" fill="#000000" stroke="none" stroke-width="1" stroke-miterlimit="10" stroke-linecap="butt" /></svg>';
const String _svg_6kk5rb =
    '<svg viewBox="3.5 43.5 375.0 1.0" ><path transform="translate(3.5, 43.5)" d="M 0 0 L 375 1" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_qlaync =
    '<svg viewBox="121.0 259.0 57.0 11.0" ><path transform="translate(121.0, 259.0)" d="M 6.397959232330322 0 L 50.60204315185547 0 C 54.13554000854492 0 57.00000381469727 2.462433815002441 57.00000381469727 5.5 C 57.00000381469727 8.537566184997559 54.13554000854492 11 50.60204315185547 11 L 6.397959232330322 11 C 2.864464044570923 11 0 8.537566184997559 0 5.5 C 0 2.462433815002441 2.864464044570923 0 6.397959232330322 0 Z" fill="#22a2ff" stroke="#22a2ff" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_st435y =
    '<svg viewBox="84.0 115.0 59.1 7.0" ><path transform="translate(84.0, 115.0)" d="M 3.691642761230469 0 L 55.37464141845703 0 C 57.41348266601562 0 59.0662841796875 1.56700325012207 59.0662841796875 3.5 C 59.0662841796875 5.43299674987793 57.41348266601562 7 55.37464141845703 7 L 3.691642761230469 7 C 1.652804613113403 7 0 5.43299674987793 0 3.5 C 0 1.56700325012207 1.652804613113403 0 3.691642761230469 0 Z" fill="#000000" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_j1y4ax =
    '<svg viewBox="129.0 729.0 73.0 11.0" ><path transform="translate(129.0, 729.0)" d="M 5.5 0 L 67.5 0 C 70.53756713867188 0 73 2.462433815002441 73 5.5 C 73 8.537566184997559 70.53756713867188 11 67.5 11 L 5.5 11 C 2.462433815002441 11 0 8.537566184997559 0 5.5 C 0 2.462433815002441 2.462433815002441 0 5.5 0 Z" fill="#ffffff" stroke="#ffaa22" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_ui83do =
    '<svg viewBox="0.0 0.0 30.0 30.0" ><path transform="translate(-19.96, -19.9)" d="M 49.04438781738281 19.89999961853027 C 48.94434356689453 19.89999961853027 48.84429931640625 19.89999961853027 48.74425506591797 19.95000076293945 L 20.63217353820801 33.5 C 19.83182907104492 33.75 19.73178672790527 34.79999923706055 20.43208694458008 35.25 L 28.53557014465332 38.95000076293945 L 25.58430099487305 44.25 L 30.93660163879395 41.34999847412109 L 34.68821716308594 49.45000076293945 C 34.88830184936523 49.75 35.18843078613281 49.90000152587891 35.48855972290039 49.90000152587891 C 35.88873291015625 49.90000152587891 36.23888397216797 49.65000152587891 36.38894653320312 49.25 L 49.94477081298828 21.09999847412109 C 50.14485931396484 20.5 49.64464569091797 19.89999961853027 49.04438781738281 19.89999961853027 Z M 35.53858184814453 46.79999923706055 L 32.43724822998047 40 L 45.39281463623047 24.59999847412109 L 29.88615036010742 37.54999923706055 L 23.08322525024414 34.40000152587891 L 46.99350738525391 22.85000038146973 L 35.53858184814453 46.79999923706055 Z" fill="#707070" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
