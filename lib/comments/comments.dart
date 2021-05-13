import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test_flutter/post/post_view.dart';
import 'package:video_player/video_player.dart';

import '../models/post.dart';
import '../models/comment.dart';

import '../globals.dart' as globals;
import '../backend_connect.dart';
import '../post/post.dart';
import 'comments_section.dart';
import 'comments_page.dart';
import 'widgets/add_comment_button.dart';

final backendConnection = new ServerAPI();
FirebaseStorage storage = FirebaseStorage.instance;

class CommentsProvider extends ChangeNotifier {
  //  Maintains a list of comments associated with a post. The point of this
  //  provider is to update the list of comment widgets when the user adds a new
  //  comment. Also has a function, getSubComments(), that returns a list of
  //  all of a comment's subcomments.

  CommentsProvider({
    @required this.post,
    @required this.indent,
    @required this.commentsList,
  });

  final Post post;
  final double indent;

  List<Comment> commentsList;

  Future<void> pushCommentsPage(
      BuildContext context, Comment parentComment) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CommentsPage(
                  post: post,
                  commentsList: commentsList,
                  parentComment: parentComment,
                ))).then((commentText) async {
      if (commentText != null)
        await addNewCommentToList(parentComment, commentText);
    });
  }

  Future<void> addNewCommentToList(
      Comment parentComment, String commentText) async {
    await postComment(post, parentComment, commentText);
    print("sent comment");
    Comment newComment =
        Comment.fromUser(globals.userID, parentComment, commentText);

    if (parentComment == null) {
      commentsList = [newComment] + commentsList;
    } else {
      int index = commentsList.indexOf(parentComment) + 1;
      commentsList = commentsList.sublist(0, index) +
          [newComment] +
          commentsList.sublist(index, commentsList.length);
    }
    print(commentText);

    notifyListeners();
  }

  List<Comment> getSubComments(Comment comment) {
    int startIndex = commentsList.indexOf(comment) + 1;
    int endIndex = startIndex + comment.numSubComments;

    return commentsList.sublist(startIndex, endIndex);
  }
}

class Comments extends StatelessWidget {
  Comments({
    @required this.height,
    @required this.post,
  });

  final double height;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: FutureBuilder(
          future: getAllComments(post),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ChangeNotifierProvider(
                  create: (context) => CommentsProvider(
                      commentsList: snapshot.data, indent: 20, post: post),
                  child: Consumer<CommentsProvider>(
                    builder: (context, provider, child) => Column(
                      children: <Widget>[
                        CommentsSection(
                            commentsList: provider.commentsList,
                            height: .85 * height,
                            showReplyBotton: true),
                        AddComment(
                          post: post,
                        ),
                      ],
                    ),
                  ));
            } else {
              return Center(child: Text("Loading"));
            }
          }),
    );
  }
}

class AddComment extends StatelessWidget {
  const AddComment({
    Key key,
    @required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    CommentsProvider provider =
        Provider.of<CommentsProvider>(context, listen: false);

    return GestureDetector(
      child: AddCommentButton(
        child: Text(
          'Add a comment',
          style: TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 20,
            color: const Color(0x69000000),
            letterSpacing: -0.48,
            height: 1.1,
          ),
        ),
      ),
      onTap: () => provider.pushCommentsPage(context, null),
    );
  }
}
