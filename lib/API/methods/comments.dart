import '../baseAPI.dart';

import '../../models/comment.dart';
import '../../models/post.dart';
import '../../globals.dart' as globals;

Future<List<Comment>> getAllComments(Post post) async {
  var response = await BaseAPI().get('v1/comments/${post.postID}/');

  List<Comment> commentsList = [];

  for (var commentJson in response["comments"]) {
    Comment comment = Comment.fromServer(commentJson);
    await comment.initDone;

    commentsList.add(comment);
  }
  return commentsList;
}

Future<bool> postComment(
    Post post, Comment parentComment, String commentText) async {
  String postID = post.postID;
  String commentPath = (parentComment != null) ? parentComment.path : '';

  Map postBody = {
    "path": commentPath,
    "comment": commentText,
    "uid": globals.user.uid
  };

  return await BaseAPI().post('v1/comments/${post.postID}/', postBody);
}
