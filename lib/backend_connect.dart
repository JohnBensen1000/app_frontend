import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';

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

Future<int> sendPostInChat(User friend, bool isImage, String filePath) async {
  // Sends an image/video that is being sent in a chat to the backend. Waits
  // for the backend to respond and returns the status code.

  String chatName = getChatName(friend);

  var request = http.MultipartRequest(
      'POST', Uri.parse(ServerAPI().url + 'posts/$chatName/'));

  request.fields["sender"] = globals.userID;
  request.fields["contentType"] = (isImage) ? 'image' : 'video';

  request.files.add(await http.MultipartFile.fromPath('media', filePath));

  var response = await request.send();
  return response.statusCode;
}

Future<void> uploadProfilePic(bool isImage, String filePath) async {
  // Uploads a file directly to google storage. Sends a POST request to the
  // backend telling it that the user's profile has been updated and the
  // file type of the profile.

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
