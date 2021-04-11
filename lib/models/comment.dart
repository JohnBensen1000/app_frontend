class Comment {
  // Data structure that holds all important information about an individual
  // comment Provides multiple constructors for creating a Comment.

  String user_ID;
  String commentText;
  String datePosted;
  String path;
  int level;
  int numSubComments;

  Comment.fromServer(Map commentJson) {
    // Used to construct comments from a json that was recieved from the server.
    // level and numSubComments should be calculated before calling this method.

    this.user_ID = commentJson["userID"];
    this.commentText = commentJson["comment"];
    this.datePosted = commentJson["datePosted"].toString();
    this.path = commentJson["path"];
    this.level = commentJson['level'];
    this.numSubComments = commentJson['numSubComments'];
  }

  Comment.fromUser(String userID, Comment parentComment, String commentText) {
    // Used to contruct a new comment when the user successfully uploads a
    // comment. parentComment is the comment that the user is responding to,
    // this variable is left null if the user is making an initial comment.

    this.user_ID = userID;
    this.commentText = commentText;
    this.datePosted = null;
    this.path = null;
    this.level = (parentComment != null) ? parentComment.level + 1 : 0;
    this.numSubComments = 0;
  }
}
