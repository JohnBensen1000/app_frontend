import 'package:firebase_storage/firebase_storage.dart';

import 'user.dart';
import 'chat.dart';

class Post {
  //Constructor
  String userID;
  String username;
  String postID;
  bool isImage;
  var postURL;

  Post.fromJson(Map postJson) {
    this.userID = postJson["userID"];
    this.username = postJson["username"];
    this.isImage = postJson["isImage"];
    this.postID = postJson["postID"].toString();

    String fileExtension = (this.isImage) ? 'png' : 'mp4';

    this.postURL = FirebaseStorage.instance
        .ref()
        .child("${postJson["userID"]}")
        .child("${postJson["postID"].toString()}.$fileExtension")
        .getDownloadURL();
  }

  Post.fromChat(Chat chat) {
    this.userID = chat.sender;
    this.username = null;
    this.postURL = chat.postData["postURL"];
    this.isImage = chat.postData['isImage'];
  }

  Post.fromProfile(String profileType, String userID) {
    if (profileType == "image" || profileType == "video") {
      this.isImage = (profileType == 'image') ? true : false;

      String fileExtension = (profileType == "image") ? "png" : "mp4";

      this.postURL = FirebaseStorage.instance
          .ref()
          .child("$userID")
          .child("profile.$fileExtension")
          .getDownloadURL();
    }
  }
}
