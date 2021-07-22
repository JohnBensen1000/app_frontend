import 'package:flutter/material.dart';
import 'package:test_flutter/widgets/generic_alert_dialog.dart';
import 'package:test_flutter/widgets/report_button.dart';
import 'package:provider/provider.dart';

import '../../widgets/profile_pic.dart';
import '../../widgets/alert_dialog_container.dart';
import '../../models/comment.dart';
import '../../models/post.dart';
import '../../API/methods/users.dart';
import '../../API/methods/comments.dart';
import '../../globals.dart' as globals;

import 'comments_page.dart';
import 'comments.dart';

class CommentWidget extends StatefulWidget {
  // Displays a comment, the comment's owner's profile and username.  When this
  // widget is held down, an alert dialog will appear asking if the current user
  // wants to report the comment or block the comment's creator.
  CommentWidget({
    @required this.comment,
    @required this.leftPadding,
    @required this.post,
  });

  final Comment comment;
  final double leftPadding;
  final Post post;

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    double profilePicSize = .0474 * globals.size.height;
    double profilePicPadding = .0059 * globals.size.height;
    double margin = 2.5;
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
        child: Container(
            color: Colors.transparent,
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
                          .03 * globals.size.width,
                      alignment: Alignment.topLeft,
                      child: RichText(
                          text: new TextSpan(
                              style: new TextStyle(
                                  fontSize: .0154 * globals.size.height,
                                  color: Colors.black),
                              children: <TextSpan>[
                            TextSpan(
                                text: "${widget.comment.user.username} ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: widget.comment.commentText)
                          ]))),
                ],
              ),
            )),
        onLongPress: () async {
          if (widget.comment.user.uid != globals.user.uid) {
            showDialog(
                context: context,
                builder: (BuildContext context) => ReportContentAlertDialog(
                      post: widget.post,
                      comment: widget.comment,
                    )).then((actionTaken) async {
              switch (actionTaken) {
                case ActionTaken.blocked:
                  await _blockUser();
                  break;
                case ActionTaken.reported:
                  await _reportComment();
                  break;
              }
            });
          }
        });
  }

  Future<void> _blockUser() async {
    // Displays an alert confirming that the user has blocked the comment's
    // creator. If the comment widget is found in the comment snackbar, then the
    // provider is told to reset state. If The comment is found in the comments
    // page, then pops the page.
    // THIS IS A HACK: checks to see where the comment is by putting the call to
    // the provider in a try-except. If there is no exception, the the comment
    // is in the snackbar. If there is an exception, then the comment is in the
    // comments page.

    await showDialog(
        context: context,
        builder: (context) => GenericAlertDialog(
            text:
                "You have sucessfully blocked this user, you will no longer see any content from them."));

    try {
      Provider.of<CommentsProvider>(context, listen: false).resetState();
    } on ProviderNotFoundException {
      Navigator.pop(context);
    }
  }

  Future<void> _reportComment() async {
    // Simply displays an alert confirming that the user has reported the
    // comment.
    await showDialog(
        context: context,
        builder: (context) => GenericAlertDialog(
            text:
                "Thank you for reporting this comment, we will review it to see if it violates any of our guidelines."));
  }
}
