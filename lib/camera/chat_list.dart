// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../backend_connect.dart';
// import '../models/user.dart';

// class ChatListProvider extends ChangeNotifier {
//   // Contains state variables used throughout the page. Creates a hash table
//   // to keep track of which friends to send the post to.

//   ChatListProvider(
//       {@required this.friendsList,
//       @required this.isImage,
//       @required this.filePath}) {
//     sendingToHashMap =
//         Map.fromIterable(friendsList, key: (k) => k, value: (_) => false);
//   }

//   final List<User> friendsList;
//   final bool isImage;
//   final String filePath;

//   Map<User, bool> sendingToHashMap;

//   void changeSendingTo(User friend) {
//     sendingToHashMap[friend] = !sendingToHashMap[friend];
//     notifyListeners();
//   }
// }

// class ChatList extends StatelessWidget {
//   // Calls getFriendsList() to get a list of the user's friends. Initializes
//   // ChatListProvider().

//   ChatList({@required this.isImage, @required this.filePath});

//   final bool isImage;
//   final String filePath;

//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery.of(context).size.height;
//     double appBarHeight = 75;

//     return Scaffold(
//         appBar: ChatListAppBar(height: appBarHeight),
//         body: FutureBuilder(
//             future: getFriendsList(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done &&
//                   snapshot.hasData) {
//                 return ChangeNotifierProvider(
//                   create: (context) => ChatListProvider(
//                       friendsList: snapshot.data,
//                       isImage: isImage,
//                       filePath: filePath),
//                   builder: (context, child) =>
//                       ChatListPage(height: height - appBarHeight),
//                 );
//               } else {
//                 return Center(child: Text("Loading"));
//               }
//             }));
//   }
// }

// class ChatListAppBar extends PreferredSize {
//   final double height;

//   ChatListAppBar({@required this.height});

//   @override
//   Size get preferredSize => Size.fromHeight(height);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Container(
//               padding: EdgeInsets.only(left: 40, top: 40),
//               child: GestureDetector(
//                 child: Text("Back"),
//                 onTap: () => Navigator.pop(context, false),
//               ),
//             ),
//           ],
//         ),
//         Container(
//           padding: EdgeInsets.only(bottom: 10),
//           child: Text(
//             "Send To:",
//             style: TextStyle(fontSize: 32),
//           ),
//         )
//       ],
//     );
//   }
// }

// class ChatListPage extends StatefulWidget {
//   // Returns a ListView.builder() of all of the user's friends. Each friend is
//   // colored differently based on whether or not they will recieve the post.
//   // This widget is rebuilt every time the user adds/removes a friend from
//   // recieving the post.

//   const ChatListPage({
//     @required this.height,
//     Key key,
//   }) : super(key: key);

//   final double height;

//   @override
//   _ChatListPageState createState() => _ChatListPageState();
// }

// class _ChatListPageState extends State<ChatListPage> {
//   Color sendButtonColor = Colors.grey[200];
//   bool allowSend = true;

//   @override
//   Widget build(BuildContext context) {
//     double sendButtonHeight = 100;

//     return Consumer<ChatListProvider>(
//       builder: (context, provider, child) => Container(
//         child: Column(
//           children: [
//             Container(
//               height: widget.height - sendButtonHeight - 47,
//               child: ListView.builder(
//                   itemCount: provider.friendsList.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     return ChatListItem(friend: provider.friendsList[index]);
//                   }),
//             ),
//             GestureDetector(
//                 child: Container(
//                   height: sendButtonHeight,
//                   color: sendButtonColor,
//                   child: Center(
//                     child: Text(
//                       "Send",
//                       style: TextStyle(fontSize: 32),
//                     ),
//                   ),
//                 ),
//                 onTapDown: (_) async {
//                   setState(() {
//                     sendButtonColor = Colors.grey[400];
//                   });
//                 },
//                 onTapUp: (_) async {
//                   setState(() {
//                     sendButtonColor = Colors.grey[200];
//                   });
//                   if (allowSend) {
//                     allowSend = false;
//                     await sendPostInChats(context);
//                     Navigator.pop(context);
//                   }
//                 }),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> sendPostInChats(BuildContext context) async {
//     ChatListProvider provider =
//         Provider.of<ChatListProvider>(context, listen: false);

//     for (User friend in provider.friendsList) {
//       if (provider.sendingToHashMap[friend])
//         await sendPostInChat(friend, provider.isImage, provider.filePath);
//     }
//   }
// }

// class ChatListItem extends StatelessWidget {
//   const ChatListItem({@required this.friend, Key key}) : super(key: key);

//   final User friend;

//   @override
//   Widget build(BuildContext context) {
//     ChatListProvider provider =
//         Provider.of<ChatListProvider>(context, listen: false);

//     Color color =
//         (provider.sendingToHashMap[friend]) ? Colors.red : Colors.grey[100];

//     return GestureDetector(
//       child: Container(
//         height: 75,
//         color: color,
//         child: Center(child: Text(friend.username)),
//       ),
//       onTap: () => Provider.of<ChatListProvider>(context, listen: false)
//           .changeSendingTo(friend),
//     );
//   }
// }
