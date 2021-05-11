import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'globals.dart' as globals;
import 'models/user.dart';
import 'chat_page.dart';

class ServerAPI {
  String _url = "http://192.168.0.180:8000/";

  String get url {
    return _url;
  }
}

Future<int> uploadPost(bool isImage, String filePath) async {
  // Sends the an HTTP request containing the post file to the server for
  // further processing. Returns with the response status code.
  var request = http.MultipartRequest(
      'POST', Uri.parse(ServerAPI().url + 'posts/${globals.userID}/posts/'));

  if (isImage)
    request.fields["contentType"] = 'image';
  else
    request.fields["contentType"] = 'video';

  request.files.add(await http.MultipartFile.fromPath('media', filePath));

  var response = await request.send();
  return response.statusCode;
}

Future<void> sendPostInChat(User friend, bool isImage, String filePath) async {
  // Sends a post as a direct message to a chat. Stores data about the post
  // in the chat document in google firestore (including download url to access
  // the file), and then  calls uploadFile() to store the actual post in google
  // storage.

  String chatName = getChatName(friend);
  CollectionReference chatsCollection = Firestore.instance.collection("Chats");

  await createChatIfDoesntExist(chatsCollection, chatName, friend);

  String postURL = await uploadFile(chatName, isImage, filePath);

  await chatsCollection
      .document(chatName)
      .collection('chats')
      .document('1')
      .updateData({
    'conversation': FieldValue.arrayUnion([
      {
        'sender': globals.userID,
        'isPost': true,
        'post': {
          'postURL': postURL,
          'isImage': isImage,
        }
      }
    ])
  });
}

Future<void> uploadProfilePic(bool isImage, String filePath) async {
  // Uploads a file that will be used as a user's profile pic

  String url = ServerAPI().url + "users/${globals.userID}/profile/";
  String profileType = (isImage) ? 'image' : 'video';
  var response = await http.post(url, body: {"profileType": profileType});

  if (response.statusCode == 201) {
    String fileExtension = (isImage) ? 'png' : 'mp4';
    String fileName = "${globals.userID}/profile.$fileExtension";

    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(fileName);

    StorageUploadTask uploadTask = storageReference.putFile(File(filePath));
    await uploadTask.onComplete;
  } else {
    print(" [SERVER ERROR] Was not able to save profile type");
  }
}

Future<String> uploadFile(
    String chatName, bool isImage, String filePath) async {
  // Uploads the post file to google storage. Determines the file name and
  // extension, and returns the download url that of the file.

  String fileExtension = (isImage) ? 'png' : 'mp4';
  String fileName =
      "$chatName/${DateTime.now().hashCode.toString()}.$fileExtension";

  StorageReference storageReference =
      FirebaseStorage.instance.ref().child(fileName);

  StorageUploadTask uploadTask = storageReference.putFile(File(filePath));
  await uploadTask.onComplete;
  return await storageReference.getDownloadURL();
}

Future<List<User>> getFriendsList() async {
  List<User> friendsList = [];

  String newUrl = ServerAPI().url + "users/${globals.userID}/friends/";
  var response = await http.get(newUrl);

  for (var friendJson in json.decode(response.body)["friends"]) {
    friendsList.add(
        User(userID: friendJson['userID'], username: friendJson['username']));
  }
  return friendsList;
}
