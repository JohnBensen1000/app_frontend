import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:test_flutter/API/methods/comments.dart';
import 'package:test_flutter/widgets/back_arrow.dart';
import 'package:video_player/video_player.dart';

import '../../widgets/generic_alert_dialog.dart';
import '../../models/post.dart';
import '../../models/comment.dart';

import '../post/post_view.dart';

import 'widgets/add_comment_button.dart';
import 'comment_widget.dart';

class CommentsPageProvider extends ChangeNotifier {
  // Contains state of entire page. Contains function for uploading a new
  // comment.

  CommentsPageProvider(
      {@required this.post,
      @required this.commentsList,
      @required this.parentComment});

  final Post post;
  final List<Comment> commentsList;
  final Comment parentComment;
}

class CommentsPage extends StatelessWidget {
  // Determines the layout of the comments page. The comments page is a
  // semi-transparent column of 3 sections that is placed on top of the post.
  // These three sections are: header, body, and footer. The header displays
  // the parent comment if there is on, the body displays all the comments
  // found in commentsList, and the footer contains a text field that lets the
  // user type a new comment.

  CommentsPage(
      {@required this.post,
      @required this.parentComment,
      @required this.commentsList});

  final Post post;
  final Comment parentComment;
  final List<Comment> commentsList;

  @override
  Widget build(BuildContext context) {
    // double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double height = .6 * MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.height;

    double headerHeight = 130;
    double footerHeight = 60;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: ChangeNotifierProvider(
            create: (context) => CommentsPageProvider(
                post: post,
                commentsList: commentsList,
                parentComment: parentComment),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    Container(
                        child: PostView(
                      post: post,
                      height: height,
                      aspectRatio: height / width,
                      postStage: PostStage.onlyPost,
                      playOnInit: false,
                    )),
                    Container(
                      width: width,
                      height: height,
                      color: Colors.white.withOpacity(.7),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                        ),
                        CommentsPageHeader(
                          height: headerHeight,
                        ),
                        CommentsPageBody(
                          height: height - headerHeight - footerHeight,
                          parentCommentOffset: (parentComment != null)
                              ? parentComment.level + 1
                              : 0,
                        ),
                        CommentsPageFooter(
                          videoPlayerController: null,
                          height: footerHeight,
                        )
                      ],
                    ),
                  ],
                ),
              ],
            )));
  }
}

class CommentsPageHeader extends StatelessWidget {
  // Contains a button for leaving the page and a CommentWidget that displays
  // the parent comment (if there is one).

  const CommentsPageHeader({
    Key key,
    @required this.height,
  }) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) {
    CommentsPageProvider provider =
        Provider.of<CommentsPageProvider>(context, listen: false);

    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Colors.grey[500].withOpacity(.7), width: 1))),
        width: double.infinity,
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(top: 35),
        height: height,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                child: Container(
                    margin: EdgeInsets.only(left: 20), child: BackArrow()),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          if (provider.parentComment != null)
            Container(
              child: CommentWidget(
                post: provider.post,
                comment: provider.parentComment,
                leftPadding: 0,
              ),
            ),
        ]));
  }
}

class CommentsPageBody extends StatelessWidget {
  // Contains a list view of each comment found in the comments list.

  CommentsPageBody({@required this.height, @required this.parentCommentOffset});

  final double height;
  final int parentCommentOffset;

  @override
  Widget build(BuildContext context) {
    CommentsPageProvider provider =
        Provider.of<CommentsPageProvider>(context, listen: false);

    double paddingPerLevel = 40;

    return Container(
        height: height,
        child: ListView.builder(
            padding: EdgeInsets.only(top: 10),
            itemCount: provider.commentsList.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 5),
                child: CommentWidget(
                    post: provider.post,
                    comment: provider.commentsList[index],
                    leftPadding: paddingPerLevel *
                        (provider.commentsList[index].level -
                            parentCommentOffset)),
              );
            }));
  }
}

class CommentsPageFooter extends StatefulWidget {
  const CommentsPageFooter({
    @required this.videoPlayerController,
    @required this.height,
    Key key,
  }) : super(key: key);

  final VideoPlayerController videoPlayerController;
  final double height;

  @override
  _CommentsPageFooterState createState() => _CommentsPageFooterState();
}

class _CommentsPageFooterState extends State<CommentsPageFooter> {
  // Contains a text field for typing a new comment and a button for uploading
  // the comment. When the button is pressed, calls provider.uploadComment to
  // upload the comment. When this process is complete, leaves this page.

  bool allowButtonPress = true;

  @override
  Widget build(BuildContext context) {
    CommentsPageProvider provider =
        Provider.of<CommentsPageProvider>(context, listen: false);

    final TextEditingController textController = new TextEditingController();

    return Container(
        height: widget.height,
        padding: EdgeInsets.only(bottom: 10),
        child: AddCommentButton(
          child: Stack(
            children: [
              TextFormField(
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: 20,
                  color: const Color(0x69000000),
                  letterSpacing: -0.48,
                  height: 1.1,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                autofocus: true,
                controller: textController,
              ),
              Container(
                padding: EdgeInsets.only(right: 12),
                alignment: Alignment.centerRight,
                child: GestureDetector(
                    child: SvgPicture.string(
                      _svg_myuv7f,
                      allowDrawingOutsideViewBox: true,
                    ),
                    onTap: () async {
                      if (allowButtonPress) {
                        setState(() {
                          allowButtonPress = false;
                        });
                        Map response = await handleRequest(
                            context,
                            postComment(provider.post, provider.parentComment,
                                textController.text));

                        switch (response["reasonForDenial"]) {
                          case "profanity":
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    GenericAlertDialog(
                                        text:
                                            "Your comment will not be uploaded due to inappropraite langauge."));
                        }

                        Navigator.pop(context);
                      }
                    }),
              ),
            ],
          ),
        ));
  }
}

const String _svg_myuv7f =
    '<svg viewBox="327.0 861.5 20.0 23.0" ><path transform="matrix(0.0, 1.0, -1.0, 0.0, 347.0, 861.5)" d="M 11.49999904632568 0 L 23 20 L 0 20 Z" fill="#ffffff" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
