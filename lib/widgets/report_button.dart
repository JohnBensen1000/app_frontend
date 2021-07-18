import 'package:flutter/material.dart';

import '../../API/handle_requests.dart';
import '../../API/methods/posts.dart';
import '../../models/post.dart';
import '../../models/comment.dart';
import '../../models/user.dart';
import '../../API/methods/relations.dart';
import '../../API/methods/comments.dart';

class ReportButton extends StatelessWidget {
  ReportButton({@required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: 20.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.0),
          color: const Color(0xffffffff),
          border: Border.all(width: 1.0, color: const Color(0xff707070)),
        ),
        child: Center(
          child: Text(
            "Report",
            style: TextStyle(color: const Color(0x67000000), fontSize: 10),
          ),
        ));
  }
}

enum ActionTaken { blocked, reported }

class ReportContentAlertDialog extends StatelessWidget {
  // Allows the user to either report a post and/or block a post's creator or
  // report a comment and/or block a comment's creator. If the variable comment
  // is null, then the report/block is on a post. If the variable comment is not
  // null, then the report/block is on a comment. Returns an ActionTaken enum
  // to show what action was taken.

  ReportContentAlertDialog({this.post, this.comment});

  final Post post;
  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        width: 200,
        height: 200,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.grey[300].withOpacity(.9),
            borderRadius: BorderRadius.all(Radius.circular(25))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.all(10),
                child: Text("Problem?", style: TextStyle(fontSize: 22))),
            GestureDetector(
                child: ReportContentButton(
                  buttonName: "Report",
                ),
                onTap: () async {
                  if (comment == null) {
                    await handleRequest(context, postReportPost(post));
                  } else {
                    await handleRequest(
                        context, postReportComment(post, comment));
                  }
                  Navigator.pop(context, ActionTaken.reported);
                }),
            GestureDetector(
                child: ReportContentButton(
                  buttonName: "Block this user",
                ),
                onTap: () async {
                  User creator = comment == null ? post.creator : comment.user;
                  await handleRequest(context, postBlockedUser(creator));
                  Navigator.pop(context, ActionTaken.blocked);
                }),
          ],
        ),
      ),
    );
  }
}

class ReportContentButton extends StatelessWidget {
  // Stateless widget used for ReportContentAlertDialog buttons.

  const ReportContentButton({
    @required this.buttonName,
    Key key,
  }) : super(key: key);

  final String buttonName;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white.withOpacity(.8);
    return GestureDetector(
      child: Container(
          margin: EdgeInsets.all(5),
          width: 160,
          height: 40,
          decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: Colors.grey[700], width: 1),
              borderRadius: BorderRadius.all(Radius.circular(25))),
          child: Center(
            child: Text(buttonName),
          )),
    );
  }
}
