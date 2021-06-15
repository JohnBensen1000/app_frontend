import 'package:flutter/material.dart';
import 'package:test_flutter/API/handle_requests.dart';

import '../../../widgets/profile_pic.dart';
import '../../../models/comment.dart';
import '../../../API/methods/users.dart';
import '../../../globals.dart' as globals;

class CommentWidget extends StatefulWidget {
  CommentWidget({
    @required this.comment,
    @required this.leftPadding,
  });

  final Comment comment;
  final double leftPadding;

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    double profilePicSize = 40.0;
    double profilePicPadding = 5.0;
    double margin = 2.5;
    double width = MediaQuery.of(context).size.width;

    return Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.all(margin),
        padding: EdgeInsets.only(left: widget.leftPadding),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: 0, horizontal: profilePicPadding),
                child: Column(
                  children: [
                    ProfilePic(
                        diameter: profilePicSize, user: widget.comment.user)
                  ],
                ),
              ),
              Container(
                  width: width -
                      widget.leftPadding -
                      (2 * profilePicPadding + profilePicSize) -
                      2 * margin -
                      10,
                  alignment: Alignment.topLeft,
                  child: RichText(
                      text: new TextSpan(
                          style:
                              new TextStyle(fontSize: 13, color: Colors.black),
                          children: <TextSpan>[
                        TextSpan(
                            text: "${widget.comment.user.username} ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: widget.comment.commentText)
                      ]))),
            ],
          ),
        ));
  }
}
