import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../API/methods/comments.dart';

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

    _insertNewComment(response, parentComment);
    return {};
  }

  Future<void> removeComment(String postID, Comment comment) async {
    await deleteComment(postID, comment.path);

    List<Comment> _newCommentsList = [];

    bool _isChildOrParent = false;
    int _commentLevel = comment.level;
    for (int i = 0; i < _commentsList.length; i++) {
      if (_commentsList[i] == comment) {
        _isChildOrParent = true;
      } else if (_commentsList[i].level <= _commentLevel) {
        _isChildOrParent = false;
      }

      if (_isChildOrParent == false) {
        _newCommentsList.add(_commentsList[i]);
      }
    }
    _commentsList = _newCommentsList;

    super.controller.sink.add(_commentsList);
  }

  void _getCommentsList() async {
    _commentsList = await getAllComments(postID);
    super.controller.sink.add(_commentsList);
  }

  void _insertNewComment(Map commentJson, Comment parentComment) {
    Comment newComment = Comment.fromResponse(commentJson, parentComment);
    if (parentComment == null) {
      _commentsList = [newComment] + _commentsList;
    } else {
      for (int i = 0; i < _commentsList.length; i++) {
        if (_commentsList[i] == parentComment) {
          _commentsList = _commentsList.sublist(0, i + 1) +
              [newComment] +
              _commentsList.sublist(i + 1, _commentsList.length);
          break;
        }
      }
    }
    super.controller.sink.add(_commentsList);
  }
}
