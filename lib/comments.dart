import 'package:flutter/material.dart';
import 'backend_connect.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_info.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

class CommentSection extends StatefulWidget {
  final int postID;
  CommentSection({this.postID});

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  Future<List<Comment>> _commentsList;

  void _postComment(String newCommentString, Comment comment) async {
    // Posts the comment to the server. If the server successfully processes
    // the post, then the new comment is inserted into the comments list

    String newUrl = backendConnection.url +
        "comments/${widget.postID.toString()}/comments/$userID/";
    var response = await http.post(newUrl,
        body: {"path": comment.path, "comment": newCommentString});

    if (response.statusCode == 200) {
      setState(() {
        _commentsList = _getAllComments();
      });
    }
  }

  Future<List<Comment>> _getAllComments() async {
    String newUrl =
        backendConnection.url + "comments/${widget.postID}/comments/";
    var response = await http.get(newUrl);

    return _flattenCommentLevel(jsonDecode(response.body)["comments"], 1);
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

  @override
  void initState() {
    _commentsList = _getAllComments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: Colors.black45))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                child: _commentSectionButton("Close"),
                onPressed: () {
                  Scaffold.of(context).hideCurrentSnackBar();
                },
              ),
              FlatButton(
                child: _commentSectionButton("Comment"),
                onPressed: () {
                  print(this._commentsList);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            backgroundColor: Colors.white,
                            // Raw comment (not a response to another comment)
                            // is treated as if it's responding to an empty
                            // Comment
                            content: _responseWidget(Comment(
                                userID: ' ',
                                path: '',
                                comment: ' ',
                                datePosted: ' ',
                                level: 0)));
                      });
                },
              ),
            ],
          ),
          Container(
            child: FutureBuilder(
              future: _commentsList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Expanded(
                      child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _commentWidget(snapshot.data[index]);
                    },
                  ));
                } else {
                  return Center(child: Text("Loading..."));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentSectionButton(String buttonName) {
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

  Widget _commentWidget(Comment comment) {
    return Container(
      margin:
          EdgeInsets.only(left: 20.0 + 40.0 * (comment.level - 1), top: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _commentSubWidget(comment),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.reply, size: 16.0, color: Colors.black),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: _responseWidget(comment),
                            backgroundColor: Colors.white,
                          );
                        });
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _commentSubWidget(Comment comment) {
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

  Widget _responseWidget(Comment comment) {
    // Widget responsible for allowing user to respond to a comment
    final textController = TextEditingController();

    return Stack(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _commentSubWidget(comment),
              ],
            ),
            TextField(
              style: TextStyle(color: Colors.black),
              controller: textController,
            ),
            RaisedButton(
                onPressed: () {
                  _postComment(textController.text, comment);
                  textController.dispose();
                  Navigator.pop(context);
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
}
