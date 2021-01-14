import 'package:flutter/material.dart';
import '../backend_connect.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final backendConnection = new BackendConnection();

class Comment {
  final String userID;
  final String path;
  final String comment;
  final String datePosted;
  final int level;

  Comment({this.userID, this.path, this.comment, this.datePosted, this.level});

  void respond() {}
}

class CommentSection {
  List<Comment> allComments = [];

  Future<void> getAllComments(int postID) async {
    allComments = [];

    String newUrl = backendConnection.url + "comments/$postID/comments/";
    var response = await http.get(newUrl);

    flattenCommentLevel(jsonDecode(response.body)["comments"], 1);
  }

  void flattenCommentLevel(var levelComments, int level) {
    for (var comment in levelComments) {
      allComments.add(Comment(
          userID: comment["userID"],
          path: comment["path"],
          comment: comment["comment"],
          datePosted: comment["datePosted"].toString(),
          level: level));
      flattenCommentLevel(comment["subComments"], level + 1);
    }
  }
}

class ForYou extends StatefulWidget {
  @override
  _ForYouState createState() => _ForYouState();
}

class _ForYouState extends State<ForYou> {
  final postID = 1;
  CommentSection commentSection = new CommentSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RaisedButton(
            child: Text("Click here for comments"),
            onPressed: () async {
              await commentSection.getAllComments(postID);
              setState(() {});
            }),
        Container(
            height: 700,
            width: double.infinity,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: commentSection.allComments.length,
              itemBuilder: (BuildContext context, int index) {
                return commentWidget(commentSection.allComments[index]);
              },
            )),
      ],
    );
  }

  Widget responseWidget() {
    return Stack(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(),
            RaisedButton(
                onPressed: null,
                child: Text(
                  "Post Comment",
                  style: TextStyle(color: Colors.black),
                )),
          ],
        )
      ],
    );
  }

  Widget commentWidget(Comment comment) {
    return Container(
      margin:
          EdgeInsets.only(left: 20.0 + 40.0 * (comment.level - 1), top: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text(comment.userID,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
          ),
          Container(
            margin: EdgeInsets.only(left: 10.0),
            child: Text(
              comment.comment,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.add, size: 16.0),
                  onPressed: () {
                    setState(() {});
                  }),
              IconButton(
                  icon: Icon(Icons.minimize, size: 16.0),
                  onPressed: () {
                    setState(() {});
                  }),
              IconButton(
                  icon: Icon(Icons.reply, size: 16.0),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(content: responseWidget());
                        });
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
