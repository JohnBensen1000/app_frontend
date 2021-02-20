import 'package:flutter/material.dart';
import 'backend_connect.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_info.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

final backendConnection = new ServerAPI();
FirebaseStorage storage = FirebaseStorage.instance;

class Comment {
  final String userID;
  final String path;
  final String comment;
  final String datePosted;
  final int level;

  Comment({this.userID, this.path, this.comment, this.datePosted, this.level});
}

class CommentSection extends StatelessWidget {
  CommentSection({this.postID});
  final int postID;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CommentsProvider(postID: postID),
      child: CommentsPage(),
    );
  }
}

class CommentsProvider extends ChangeNotifier {
  CommentsProvider({this.postID}) {
    _getAllComments();
  }
  List<Comment> commentsList = [];
  final int postID;

  void _getAllComments() async {
    String newUrl = backendConnection.url + "comments/$postID/comments/";
    var response = await http.get(newUrl);

    commentsList =
        _flattenCommentLevel(jsonDecode(response.body)["comments"], 1);
    notifyListeners();
  }

  List<Comment> _flattenCommentLevel(var levelComments, int level) {
    List<Comment> commentsList = [];
    for (var comment in levelComments) {
      commentsList.add(Comment(
          userID: comment["userID"],
          path: comment["path"],
          comment: comment["comment"],
          datePosted: comment["datePosted"].toString(),
          level: level));
      commentsList += _flattenCommentLevel(comment["subComments"], level + 1);
    }
    return commentsList;
  }

  void updateCommentsList(List<Comment> newCommentsList) {
    commentsList = newCommentsList;
    notifyListeners();
  }
}

class CommentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CommentsProvider>(
        builder: (context, commentsProvider, child) {
      return Container(
        height: 600,
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black45))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                  child: CommentSectionButton(buttonName: "Close"),
                  onPressed: () {
                    Scaffold.of(context).hideCurrentSnackBar();
                  },
                ),
                FlatButton(
                  child: CommentSectionButton(buttonName: "Comment"),
                  onPressed: null,
                ),
              ],
            ),
            Expanded(
                child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: commentsProvider.commentsList.length,
              itemBuilder: (BuildContext context, int index) {
                var commentsProvider = Provider.of<CommentsProvider>(context);

                return CommentWidget(
                    comment: commentsProvider.commentsList[index],
                    commentsProvider: commentsProvider);
              },
            )),
          ],
        ),
      );
    });
  }
}

class CommentSectionButton extends StatelessWidget {
  const CommentSectionButton({
    Key key,
    @required this.buttonName,
  }) : super(key: key);

  final String buttonName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      height: 25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.grey[300],
      ),
      child: Transform.translate(
        offset: Offset(0, 4),
        child: Text(
          buttonName,
          style: TextStyle(color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class CommentWidget extends StatelessWidget {
  const CommentWidget({
    Key key,
    @required this.comment,
    @required this.commentsProvider,
  }) : super(key: key);

  final Comment comment;
  final commentsProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.only(left: 20.0 + 40.0 * (comment.level - 1), top: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CommentSubWidget(comment: comment),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.reply, size: 16.0, color: Colors.black),
                onPressed: () => _respondToComment(context),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _respondToComment(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: ResponseWidget(
              comment: comment,
              commentsProvider: commentsProvider,
            ),
          );
        });
  }
}

class ResponseWidget extends StatelessWidget {
  const ResponseWidget({
    Key key,
    @required this.comment,
    @required this.commentsProvider,
  }) : super(key: key);

  final Comment comment;
  final commentsProvider;

  @override
  Widget build(BuildContext context) {
    // Widget responsible for allowing user to respond to a comment
    final TextEditingController textController = TextEditingController();

    return Stack(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CommentSubWidget(comment: comment),
              ],
            ),
            TextField(
              style: TextStyle(color: Colors.black),
              controller: textController,
            ),
            RaisedButton(
                onPressed: () {
                  _postComment(context, textController.text);
                  textController.dispose();
                },
                child: Text(
                  "Post Comment",
                  style: TextStyle(color: Colors.black),
                )),
          ],
        )
      ],
    );
  }

  Future<void> _postComment(BuildContext context, String commentString) async {
    int postID = commentsProvider.postID;

    String newUrl = backendConnection.url +
        "comments/${postID.toString()}/comments/$userID/";
    var response = await http
        .post(newUrl, body: {"path": comment.path, "comment": commentString});

    if (response.statusCode == 200) {
      _updateCommentsList(commentString);
    }
    Navigator.pop(context);
  }

  void _updateCommentsList(String commentString) {
    List<Comment> commentsList = commentsProvider.commentsList;

    int commentIndex = commentsList.indexOf(comment);
    Comment newComment = Comment(
        comment: commentString, userID: userID, level: comment.level + 1);
    List<Comment> newCommentsList = commentsList.sublist(0, commentIndex + 1) +
        [newComment] +
        commentsList.sublist(commentIndex + 1, commentsList.length);

    commentsProvider.updateCommentsList(newCommentsList);
  }
}

class CommentSubWidget extends StatelessWidget {
  const CommentSubWidget({
    Key key,
    @required this.comment,
  }) : super(key: key);

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    // This widget displays the user and the comment text, this is seperated from
    // commentWidget bc this widget is also used for responseWidget
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text(comment.userID,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0)),
        ),
        Container(
          child: Text(
            comment.comment,
            style: TextStyle(color: Colors.black, fontSize: 16.0),
          ),
        ),
      ],
    );
  }
}
