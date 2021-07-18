import '../baseAPI.dart';

import '../../models/comment.dart';
import '../../models/post.dart';
import '../../globals.dart' as globals;

Future<List<Comment>> getAllComments(Post post) async {
  var response = await BaseAPI().get('v1/comments/${post.postID}/',
      queryParameters: {'uid': globals.user.uid});

  List<Comment> commentsList = [];

  for (var commentJson in response["comments"]) {
    Comment comment = Comment.fromServer(commentJson);
    await comment.initDone;

    commentsList.add(comment);
  }
  return commentsList;
}

Future<Map> postComment(
    Post post, Comment parentComment, String commentText) async {
  String commentPath = (parentComment != null) ? parentComment.path : '';

  Map postBody = {
    "path": commentPath,
    "comment": commentText,
    "uid": globals.user.uid
  };

  return await BaseAPI().post('v1/comments/${post.postID}/', postBody);
}

Future<bool> postReportComment(Post post, Comment comment) async {
  return await BaseAPI()
      .post('v1/comments/${post.postID}/report/', comment.toJson());
}
