import 'user.dart';
import '../API/methods/users.dart';

class Comment {
  // Data structure that holds all important information about an individual
  // comment Provides multiple constructors for creating a Comment.

  User user;
  String commentText;
  String datePosted;
  String path;
  int level;
  int numSubComments;

  Future initFuture;

  Comment.fromServer(Map commentJson) {
    // Used to construct comments from a json that was recieved from the server.
    // level and numSubComments should be calculated before calling this method.

    initFuture = _init(commentJson);
  }

  Future _init(Map commentJson) async {
    this.commentText = commentJson["comment"];
    this.datePosted = commentJson["datePosted"].toString();
    this.path = commentJson["path"];
    this.level = commentJson['level'];
    this.numSubComments = commentJson['numSubComments'];

    this.user = await getUserFromUID(commentJson['uid']);
  }

  Future get initDone => initFuture;
}
