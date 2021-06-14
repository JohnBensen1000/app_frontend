import '../baseAPI.dart';

import '../../models/comment.dart';
import '../../models/post.dart';
import '../../globals.dart' as globals;

Future<List<Comment>> getAllComments(Post post) async {
  var response = await BaseAPI().get('v1/comments/${post.postID}/');

  List<Comment> commentsList = [];

  for (var comment in response["comments"]) {
    commentsList.add(Comment.fromServer(comment));
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
