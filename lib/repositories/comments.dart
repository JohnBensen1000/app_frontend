import 'package:test_flutter/API/methods/comments.dart';
import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../models/post.dart';

import 'repository.dart';

class CommentsSectionRepository extends Repository<List<Comment>> {
  CommentsSectionRepository({@required this.postID}) {
    _getCommentsList();
  }

  final String postID;
  List<Comment> _commentsList;

  List<Comment> get commentsList => _commentsList != null ? _commentsList : [];

  Future<Map> addComment(Comment parentComment, String comment) async {
    Map response = await postComment(postID, parentComment, comment);
    if (response == null || response.containsKey("denied")) return response;

    _getCommentsList();
    return {};
  }

  void _getCommentsList() async {
    _commentsList = await getAllComments(postID);
    super.controller.sink.add(_commentsList);
  }
}
