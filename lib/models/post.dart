import 'user.dart';
import 'chat.dart';
import 'post.dart';

class Post {
  User creator;
  String postID;
  bool isImage;
  String downloadURL;

  Post({this.creator, this.postID, this.isImage, this.downloadURL});

  Post.fromJson(Map postJson) {
    this.creator = User.fromJson(postJson["creator"]);
    this.postID = postJson["postID"];
    this.isImage = postJson["isImage"];
    this.downloadURL = postJson["downloadURL"];
  }

  Post.fromChatItem(ChatItem chatItem) {
    this.isImage = chatItem.post['isImage'];
    this.downloadURL = chatItem.post["downloadURL"];
  }
}
