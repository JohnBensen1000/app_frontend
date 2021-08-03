import 'user.dart';
import 'chat.dart';
import 'post.dart';

class Post {
  User creator;
  String postID;
  bool isImage;
  String downloadURL;
  String caption;

  Post(
      {this.creator,
      this.postID,
      this.isImage,
      this.downloadURL,
      this.caption});

  Post.fromJson(Map postJson) {
    this.creator = User.fromJson(postJson["creator"]);
    this.postID = postJson["postID"];
    this.isImage = postJson["isImage"];
    this.downloadURL = postJson["downloadURL"];
    this.caption = postJson["caption"];
  }

  Post.fromChatItem(ChatItem chatItem) {
    this.isImage = chatItem.post['isImage'];
    this.downloadURL = chatItem.post["downloadURL"];
    this.caption =
        chatItem.post.containsKey("caption") ? chatItem.post["caption"] : "";
  }
}
