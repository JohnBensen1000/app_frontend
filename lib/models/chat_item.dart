class ChatItem {
  bool isPost;
  String uid;
  String text;
  Map post;

  ChatItem.fromFirebase(Map<String, dynamic> chatItemJson) {
    this.isPost = chatItemJson['isPost'];
    this.uid = chatItemJson['uid'];
    if (this.isPost)
      this.post = {
        'isImage': chatItemJson['post']['isImage'],
        'downloadURL': chatItemJson['post']['downloadURL'],
        'caption': chatItemJson['post']['caption'],
      };
    else
      this.text = chatItemJson["text"];
  }

  Map toJson() {
    return (isPost) ? {'uid': uid, 'post': post} : {'uid': uid, 'text': text};
  }
}
