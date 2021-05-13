import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

import '../models/post.dart';
import '../models/comment.dart';

import '../globals.dart' as globals;
import '../backend_connect.dart';
import '../post/post.dart';

class CommentsSection extends StatelessWidget {
  // Builds and returns a scrollable list view of every comment in commentsList.
  // The list view is constrained vertically by the variable height. levelOffset
  // is subtracted from each comment.level. This is only non-zero if the
  // responses to another comment is being displayed as the main level of
  // comments.

  const CommentsSection({
    @required this.commentsList,
    @required this.height,
    @required this.showReplyBotton,
    this.levelOffset = 0,
    this.indent = 20,
    Key key,
  }) : super(key: key);

  final List<Comment> commentsList;
  final double height;
  final bool showReplyBotton;
  final int levelOffset;
  final double indent;

  @override
  Widget build(BuildContext context) {
    if (commentsList == null)
      return Container(
        height: height,
      );
    else
      return Container(
        height: height,
        child: Container(
          child: ListView.builder(
            itemCount: commentsList.length,
            itemBuilder: (BuildContext context, int index) {
              return CommentWidget(
                comment: commentsList[index],
                indent: indent,
                levelOffset: levelOffset,
                showReplyBotton: showReplyBotton,
              );
            },
          ),
        ),
      );
  }
}

class CommentWidget extends StatelessWidget {
  CommentWidget(
      {@required this.comment,
      @required this.indent,
      @required this.levelOffset,
      @required this.showReplyBotton});

  final Comment comment;
  final double indent;
  final int levelOffset;
  final bool showReplyBotton;

  @override
  Widget build(BuildContext context) {
    double leftPadding = indent * (comment.level - levelOffset);
    double width = MediaQuery.of(context).size.width - leftPadding;

    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5, left: leftPadding),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              CommentWidgetHeader(
                width: .35 * width,
                comment: comment,
                showProfilePic: (comment.level - levelOffset) < 2,
              ),
              if (showReplyBotton) GestureDetector(child: Text("Reply")),
            ],
          ),
          Container(
            padding: EdgeInsets.only(left: .35 * width),
            child: Text(
              comment.commentText,
              style: TextStyle(
                fontFamily: 'Helvetica Neue',
                fontSize: 18,
                color: const Color(0xff000000),
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

class CommentWidgetHeader extends StatelessWidget {
  const CommentWidgetHeader({
    Key key,
    @required this.width,
    @required this.comment,
    @required this.showProfilePic,
  }) : super(key: key);

  final double width;
  final Comment comment;
  final bool showProfilePic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: Column(children: <Widget>[
        Row(
          children: <Widget>[
            if (showProfilePic)
              Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                  // image: DecorationImage(
                  //   image: const AssetImage(''),
                  //   fit: BoxFit.cover,
                  // ),
                  border:
                      Border.all(width: 1.0, color: const Color(0xff22a2ff)),
                ),
              ),
            Text(
              comment.userID,
              style: TextStyle(
                fontFamily: 'Helvetica Neue',
                fontSize: 15,
                color: const Color(0xff707070),
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        // if (showProfilePic)
        //   Container(
        //     height: 20,
        //     alignment: Alignment.centerLeft,
        //     child: FlatButton(
        //       child: Text("Reply"),
        //       onPressed: null,
        // onPressed: () => Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (_) => AddCommentScaffold(
        //               post: post,
        //               commentsList: Provider.of<CommentSectionProvider>(
        //                       context,
        //                       listen: false)
        //                   .getSubComments(comment),
        //               parentComment: comment,
        //             ))).then((value) =>
        //     Provider.of<CommentSectionProvider>(context, listen: false)
        //         .addNewCommentToList(
        //             comment,
        //             Comment.fromUser(
        //                 globals.userID, comment, value["commentText"]))),
        //   ),
        // )
      ]),
    );
  }
}
