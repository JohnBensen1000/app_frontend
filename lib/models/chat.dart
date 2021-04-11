class Chat {
  // Class that holds relevant data about an individual chat. Also has a
  // constructor that creates a Chat() object from a Firestore Map.
  bool isPost;
  String sender;
  String text;
  Map postData;

  Chat.fromFirebase(Map chatData) {
    this.isPost = chatData['isPost'];
    this.sender = chatData['sender'];
    if (this.isPost)
      this.postData = chatData['post'];
    else
      this.text = chatData["text"];
  }
}
