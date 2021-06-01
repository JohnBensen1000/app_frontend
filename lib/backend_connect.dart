// import 'dart:convert';
// import 'dart:io';

// import 'package:http/http.dart' as http;
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// import 'globals.dart' as globals;
// import 'models/user.dart';
// import 'models/post.dart';
// import 'models/comment.dart';
// import 'friends/chat_page.dart';

// class ServerAPI {
//   String _url = "http:/192.168.0.180:8000/";

//   String get url {
//     return _url;
//   }
// }

// Future<int> uploadPost(bool isImage, String filePath) async {
//   // Sends the an HTTP request containing the post file to the server for
//   // further processing. Returns with the response status code.

//   var request = http.MultipartRequest(
//       'POST', Uri.parse(ServerAPI().url + 'posts/${globals.userID}/posts/'));

//   if (isImage)
//     request.fields["contentType"] = 'image';
//   else
//     request.fields["contentType"] = 'video';

//   request.files.add(await http.MultipartFile.fromPath('media', filePath));

//   var response = await request.send();
//   return response.statusCode;
// }

// Future<int> sendPostInChat(User friend, bool isImage, String filePath) async {
//   // Sends an image/video that is being sent in a chat to the backend. Waits
//   // for the backend to respond and returns the status code.

//   String chatName = getChatName(friend);

//   var request = http.MultipartRequest(
//       'POST', Uri.parse(ServerAPI().url + 'posts/$chatName/'));

//   request.fields["sender"] = globals.userID;
//   request.fields["contentType"] = (isImage) ? 'image' : 'video';

//   request.files.add(await http.MultipartFile.fromPath('media', filePath));

//   var response = await request.send();
//   return response.statusCode;
// }

// Future<void> uploadProfilePic(bool isImage, String filePath) async {
//   // Uploads a file directly to google storage. Sends a POST request to the
//   // backend telling it that the user's profile has been updated and the
//   // file type of the profile.

//   String url = ServerAPI().url + "users/${globals.userID}/profile/";
//   String profileType = (isImage) ? 'image' : 'video';
//   var response = await http.post(url, body: {"profileType": profileType});

//   if (response.statusCode == 201) {
//     String fileExtension = (isImage) ? 'png' : 'mp4';
//     String fileName = "${globals.userID}/profile.$fileExtension";

//     StorageReference storageReference =
//         FirebaseStorage.instance.ref().child(fileName);

//     StorageUploadTask uploadTask = storageReference.putFile(File(filePath));
//     await uploadTask.onComplete;
//   } else {
//     print(" [SERVER ERROR] Was not able to save profile type");
//   }
// }

// Future<List<User>> getFriendsList() async {
//   List<User> friendsList = [];

//   String newUrl = ServerAPI().url + "users/${globals.userID}/friends/";
//   var response = await http.get(newUrl);

//   for (var friendJson in json.decode(response.body)["friends"]) {
//     friendsList.add(
//         User(userID: friendJson['userID'], username: friendJson['username']));
//   }
//   return friendsList;
// }

// Future<List<Comment>> getAllComments(Post post) async {
//   // Sends an http request to the server to get a json representation of the
//   // comments section. Then calls _flattenCommentLevel to create a list
//   // of Comment() objects that are usuable.
//   String newUrl = ServerAPI().url + "comments/${post.postID}/";
//   var response = await http.get(newUrl);

//   List<Comment> commentsList = [];

//   for (var comment in jsonDecode(response.body)["comments"]) {
//     commentsList.add(Comment.fromServer(comment));
//   }
//   return commentsList;
// }

// Future<int> postComment(
//     Post post, Comment parentComment, String commentText) async {
//   String postID = post.postID;
//   String commentPath = (parentComment != null) ? parentComment.path : '';

//   String newUrl = ServerAPI().url + "comments/${postID.toString()}/";
//   var response = await http.post(newUrl, body: {
//     "path": commentPath,
//     "comment": commentText,
//     "userID": globals.userID
//   });

//   return response.statusCode;
// }

// Future<bool> authenticateUserWithBackend(String idToken) async {
//   // Authenticates the user with the backend. First gets deviceToken. Sends
//   // idToken and deviceToken to backend. Then sets the global variable userID to
//   // the data that the backend returns. Returns false if an error occurred on
//   // the backend, true otherwise.

//   FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
//   String deviceToken = await _firebaseMessaging.getToken();

//   String url = ServerAPI().url + "authenticate/";

//   http.Response response = await http
//       .post(url, body: {"idToken": idToken, "deviceToken": deviceToken});

//   if (response.statusCode == 200) {
//     globals.userID = json.decode(response.body)["userID"];
//     globals.username = json.decode(response.body)["username"];
//     return true;
//   }
//   return false;
// }

// Future<dynamic> postUniqueIdentifiers(Map<dynamic, dynamic> postBody) async {
//   String url = ServerAPI().url + "users/check/";

//   var response = await http.post(url, body: postBody);
//   Map<String, dynamic> responseBody = json.decode(response.body);
//   return responseBody;
// }

// Future<void> postCreateAccount(
//     Map<dynamic, dynamic> postBody, String userID) async {
//   String url = ServerAPI().url + "users/$userID/";
//   await http.post(url, body: postBody);
// }

// Future<List<User>> getNewFollowers() async {
//   List<User> followersList = [];

//   String newUrl = ServerAPI().url + "users/${globals.userID}/followers/";
//   var response = await http.get(newUrl);

//   for (var friendJson in json.decode(response.body)["new_followers"]) {
//     followersList.add(
//         User(userID: friendJson['userID'], username: friendJson['username']));
//   }
//   return followersList;
// }

// Future<dynamic> postFollowBack(String newFollowerID, bool followBack) async {
//   String url =
//       ServerAPI().url + "users/${globals.userID}/following/$newFollowerID/";

//   Map<dynamic, dynamic> postBody = {"followBack": followBack.toString()};
//   var response = await http.post(url, body: postBody);

//   return response;
// }

// Future<List<dynamic>> getPosts() async {
//   String newUrl = ServerAPI().url + "posts/${globals.userID}/following/";
//   var response = await http.get(newUrl);
//   return json.decode(response.body)["postsList"];
// }

// Future<dynamic> recordWatched(String postID, int userFeedback) async {
//   String newUrl = ServerAPI().url + 'posts/${globals.userID}/watched/$postID/';

//   var response =
//       await http.post(newUrl, body: {'userRating': userFeedback.toString()});
//   return response;
// }

// Future<List<User>> searchUsers(String searchString) async {
//   String url = ServerAPI().url + "users/search/" + searchString + "/";
//   var response = await http.get(url);

//   List<User> creatorsList = [
//     for (var creator in json.decode(response.body)["creatorsList"])
//       User(userID: creator["userID"], username: creator["username"])
//   ];

//   return creatorsList;
// }

// Future<bool> checkIfFollowing(String creatorID) async {
//   String url =
//       ServerAPI().url + "users/${globals.userID}/following/$creatorID/";
//   var response = await http.get(url);

//   return json.decode(response.body)["following_bool"];
// }

// Future<dynamic> startFollowing(String creatorID) async {
//   String url =
//       ServerAPI().url + "users/${globals.userID}/following/$creatorID/";
//   await http.post(url);
// }

// Future<dynamic> stopFollowing(String creatorID) async {
//   String url =
//       ServerAPI().url + "users/${globals.userID}/following/$creatorID/";
//   await http.delete(url);
// }

// Future<List<dynamic>> getProfilePosts(User user) async {
//   // Sends a request to the server to get a list of the creator's posts. When
//   // this list is recieved, _getProfilePostsList() is called to build a list
//   // of ProfilePostWidget().
//   var response =
//       await http.get(ServerAPI().url + "posts/${user.userID}/posts/");
//   List<dynamic> postList = json.decode(response.body)["userPosts"];

//   if (postList.length == 0) {
//     return [];
//   }
//   return postList;
// }

// Future<Post> getProfileURL(String userID) async {
//   String newUrl = ServerAPI().url + "users/$userID/profile/";
//   var response = await http.get(newUrl);

//   if (json.decode(response.body)["profileType"] == "none") return null;
//   return Post.fromProfile(json.decode(response.body)["profileType"], userID);
// }
