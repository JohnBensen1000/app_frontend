import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'backend_connect.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_info.dart';
import 'package:firebase_storage/firebase_storage.dart';

final backendConnection = new BackendConnection();
FirebaseStorage storage = FirebaseStorage.instance;

class Comment {
  final String userID;
  final String path;
  final String comment;
  final String datePosted;
  final int level;

  Comment({this.userID, this.path, this.comment, this.datePosted, this.level});
}

Future<List<Comment>> getAllComments(int postID) async {
  String newUrl = backendConnection.url + "comments/$postID/comments/";
  var response = await http.get(newUrl);

  return flattenCommentLevel(jsonDecode(response.body)["comments"], 1);
}

List<Comment> flattenCommentLevel(var levelComments, int level) {
  List<Comment> commentsList = [];
  for (var comment in levelComments) {
    commentsList.add(Comment(
        userID: comment["userID"],
        path: comment["path"],
        comment: comment["comment"],
        datePosted: comment["datePosted"].toString(),
        level: level));
    commentsList += flattenCommentLevel(comment["subComments"], level + 1);
  }
  return commentsList;
}

class FollowingPage extends StatefulWidget {
  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  Future<List<dynamic>> _postList;

  Future<List<dynamic>> getPosts() async {
    String newUrl = backendConnection.url + "posts/$userID/following/new/";
    var response = await http.get(newUrl);
    return json.decode(response.body)["postsList"];
  }

  @override
  void initState() {
    _postList = getPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
            future: _postList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return SizedBox(
                    height: 700,
                    width: double.infinity,
                    child: new ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          Map<String, dynamic> postJson = snapshot.data[index];
                          return PostWidget(
                              userID: postJson["userID"],
                              username: postJson["username"],
                              postID: postJson["postID"]);
                        }));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }
}

class PostWidget extends StatefulWidget {
  final String userID;
  final String username;
  final int postID;

  PostWidget({this.userID, this.username, this.postID});

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  Future<Image> _postImage;
  Future<List<Comment>> commentsList;

  Future<Image> _getPostImage() async {
    String postDownloadURL = await FirebaseStorage.instance
        .ref()
        .child("${widget.userID}")
        .child("${widget.postID.toString()}.png")
        .getDownloadURL();

    return Image.network(postDownloadURL);
  }

  @override
  void initState() {
    _postImage = _getPostImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    commentsList = getAllComments(widget.postID);
    return Container(
        child: FutureBuilder(
            future: _postImage,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return Container(
                    padding: EdgeInsets.only(left: 40, right: 40, bottom: 20),
                    child: Column(
                      children: <Widget>[
                        postHeader(),
                        postBody(snapshot.data),
                      ],
                    ));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }

  Widget postHeader() {
    return Container(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 45.0,
                height: 43.0,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                  // image: DecorationImage(
                  //   image: const AssetImage(''),
                  //   fit: BoxFit.cover,
                  // ),
                  border:
                      Border.all(width: 3.0, color: const Color(0xff707070)),
                ),
              ),
              SizedBox(
                width: 146.0,
                child: Container(
                  padding: EdgeInsets.only(left: 10, top: 5),
                  child: Text(
                    widget.username,
                    style: TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 22,
                      color: const Color(0xff000000),
                      letterSpacing: -0.009019999921321869,
                      height: 0.5454545454545454,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 73.0,
                child: Text(
                  'Tier 5 ',
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 12,
                    color: const Color(0xff000000),
                    letterSpacing: -0.004099999964237213,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, 5.5),
                child: Container(
                  width: 73.0,
                  height: 11.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: const Color(0xffffffff),
                    border:
                        Border.all(width: 1.0, color: const Color(0xff707070)),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -5.5),
                child: Container(
                  width: 49.0,
                  height: 11.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: const Color(0xff707070),
                    border:
                        Border.all(width: 1.0, color: const Color(0xff707070)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget postBody(Image postImage) {
    return SizedBox(
      height: 475.0,
      child: Column(
        children: <Widget>[
          Container(
            height: 435.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              image: DecorationImage(
                image: postImage.image,
                fit: BoxFit.cover,
              ),
              border: Border.all(width: 1.0, color: const Color(0xff707070)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: EdgeInsets.only(top: 3),
              width: 146.0,
              height: 25.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13.0),
                color: const Color(0xffffffff),
                border: Border.all(width: 3.0, color: const Color(0xff707070)),
              ),
              child: Container(
                padding: EdgeInsets.only(bottom: 5),
                child: FlatButton(
                  onPressed: () async {
                    // waits for commentsList to be fully parsed before opening
                    // the comments section
                    List<Comment> commentsList = await this.commentsList;
                    Scaffold.of(context)
                        .showSnackBar(commentSection(commentsList));
                  },
                  child: Text(
                    'View Comments',
                    style: TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 10,
                      color: const Color(0x67000000),
                      letterSpacing: -0.004099999964237213,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SnackBar commentSection(List<Comment> commentsList) {
    return SnackBar(
      backgroundColor: Colors.white,
      duration: Duration(days: 365),
      content:
          CommentSection(commentsList: commentsList, postID: widget.postID),
    );
  }
}

class CommentSection extends StatefulWidget {
  final List<Comment> commentsList;
  final int postID;
  CommentSection({this.commentsList, this.postID});

  @override
  _CommentSectionState createState() =>
      _CommentSectionState(commentsList: this.commentsList, postID: postID);
}

class _CommentSectionState extends State<CommentSection> {
  List<Comment> commentsList;
  int postID;
  // UserInfo userInfo;
  _CommentSectionState({this.commentsList, this.postID});

  void postComment(String newCommentString, Comment comment) async {
    // Posts the comment to the server. If the server successfully processes
    // the post, then the new comment is inserted into the comments list

    String newUrl = backendConnection.url +
        "comments/${this.postID.toString()}/comments/$userID/";
    var response = await http.post(newUrl,
        body: {"path": comment.path, "comment": newCommentString});

    if (response.statusCode == 200) {
      setState(() {
        int commentIndex = this.commentsList.indexOf(comment);
        Comment newComment = Comment(
            comment: newCommentString,
            userID: userID,
            // userID: this.userInfo.userID,
            datePosted: "Now",
            level: comment.level + 1);
        commentsList = commentsList.sublist(0, commentIndex + 1) +
            [newComment] +
            commentsList.sublist(commentIndex + 1, commentsList.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // userInfo = UserInfo.of(context);
    return commentSectionWidget();
  }

  Widget commentSectionWidget() {
    return Container(
        height: 600,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Scaffold.of(context).hideCurrentSnackBar();
                      },
                      child: Text(
                        "Close Comment Section",
                        style: TextStyle(color: Colors.black),
                      )),
                  FlatButton(
                      onPressed: () {
                        print(this.commentsList);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  backgroundColor: Colors.white,
                                  // Raw comment (not a response to another comment)
                                  // is treated as if it's responding to an empty
                                  // Comment
                                  content: responseWidget(Comment(
                                      userID: ' ',
                                      path: '',
                                      comment: ' ',
                                      datePosted: ' ',
                                      level: 0)));
                            });
                      },
                      child: Text(
                        "Comment on this post",
                        style: TextStyle(color: Colors.black),
                      )),
                ],
              ),
              Expanded(
                  child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: commentsList.length,
                itemBuilder: (BuildContext context, int index) {
                  return commentWidget(commentsList[index]);
                },
              )),
            ]));
  }

  Widget commentWidget(Comment comment) {
    return Container(
      margin:
          EdgeInsets.only(left: 20.0 + 40.0 * (comment.level - 1), top: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          commentSubWidget(comment),
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
                            content: responseWidget(comment),
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

  Widget commentSubWidget(Comment comment) {
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

  Widget responseWidget(Comment comment) {
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
                commentSubWidget(comment),
              ],
            ),
            TextField(
              style: TextStyle(color: Colors.black),
              controller: textController,
            ),
            RaisedButton(
                onPressed: () {
                  postComment(textController.text, comment);
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
