import '../baseAPI.dart';

import '../../models/comment.dart';
import '../../globals.dart' as globals;

Future<List<Comment>> getAllComments(String postID) async {
  var response = await BaseAPI()
      .get('v2/comments/$postID', queryParameters: {'uid': globals.uid});

  List<Comment> commentsList = [];

  if (response == null) return null;

  for (var commentJson in response["comments"]) {
    Comment comment = Comment.fromServer(commentJson);
    commentsList.add(comment);
  }
  return commentsList;
}

Future<Map> postComment(
    String postID, Comment parentComment, String commentText) async {
  String commentPath = (parentComment != null) ? parentComment.path : '';

  Map postBody = {
    "path": commentPath,
    "comment": commentText,
    "uid": globals.uid
  };

  return await BaseAPI().post('v2/comments/$postID', postBody);
}
