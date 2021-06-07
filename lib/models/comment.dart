class Comment {
  // Data structure that holds all important information about an individual
  // comment Provides multiple constructors for creating a Comment.

  String uid;
  String commentText;
  String datePosted;
  String path;
  int level;
  int numSubComments;

  Comment.fromServer(Map commentJson) {
    // Used to construct comments from a json that was recieved from the server.
    // level and numSubComments should be calculated before calling this method.

    this.uid = commentJson["uid"];
    this.commentText = commentJson["comment"];
    this.datePosted = commentJson["datePosted"].toString();
    this.path = commentJson["path"];
    this.level = commentJson['level'];
    this.numSubComments = commentJson['numSubComments'];
  }
}
