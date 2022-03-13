import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../widgets/generic_alert_dialog.dart';
import '../../models/post.dart';
import '../../models/comment.dart';
import '../../repositories/comments.dart';
import '../post/post_widget.dart';

import '../../widgets/entropy_scaffold.dart';

import 'widgets/add_comment_button.dart';
import 'widgets/comment_widget.dart';
import '../../widgets/back_arrow.dart';

class CommentsPageProvider extends ChangeNotifier {
  // Contains state of entire page. Contains function for uploading a new
  // comment.

  CommentsPageProvider(
      {@required this.post,
      @required this.commentsList,
      @required this.repository,
      @required this.parentComment});

  final Post post;
  final CommentsSectionRepository repository;
  final List<Comment> commentsList;
  final Comment parentComment;

  Future<Map> addComment(String comment) async {
    return await repository.addComment(parentComment, comment);
  }
}

class CommentsPage extends StatefulWidget {
  // Determines the layout of the comments page. The comments page is a
  // semi-transparent column of 3 sections that is placed on top of the post.
  // These three sections are: header, body, and footer. The header displays
  // the parent comment if there is on, the body displays all the comments
  // found in commentsList, and the footer contains a text field that lets the
  // user type a new comment.

  CommentsPage(
      {@required this.post,
      @required this.parentComment,
      @required this.repository,
      @required this.commentsList});

  final Post post;
  final Comment parentComment;
  final List<Comment> commentsList;
  final CommentsSectionRepository repository;

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double height = MediaQuery.of(context).size.height - keyboardHeight;

    double headerHeight = .16 * height;
    double footerHeight = .14 * height;

    return EntropyScaffold(
        backgroundWidget: PostWidget(
          post: widget.post,
          height: MediaQuery.of(context).size.height,
          aspectRatio: MediaQuery.of(context).size.height /
              MediaQuery.of(context).size.width,
          cornerRadiusFraction: 0,
        ),
        hidePostWithOpacity: true,
        body: ChangeNotifierProvider(
          create: (context) => CommentsPageProvider(
              post: widget.post,
              commentsList: widget.commentsList,
              repository: widget.repository,
              parentComment: widget.parentComment),
          child: Container(
            padding: EdgeInsets.only(
                left: .01 * globals.size.width,
                right: .01 * globals.size.width),
            child: Column(
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
                  parentCommentOffset: (widget.parentComment != null)
                      ? widget.parentComment.level + 1
                      : 0,
                ),
                CommentsPageFooter(
                  height: footerHeight,
                )
              ],
            ),
          ),
        ));
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
    return Container(
      height: height,
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              child: BackArrow(),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ]),
    );
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

    double paddingPerLevel = .103 * globals.size.width;

    return Container(
        height: height,
        child: Column(
          children: [
            if (provider.parentComment != null)
              Container(
                  child: FutureBuilder(
                      future: globals.userRepository
                          .get(provider.parentComment.uid),
                      builder: (context, snapshot) {
                        if (snapshot.hasData)
                          return CommentWidget(
                            post: provider.post,
                            comment: provider.parentComment,
                            commenter: snapshot.data,
                            leftPadding: 0,
                          );
                        else
                          return Container();
                      }),
                  padding: EdgeInsets.only(bottom: .01 * globals.size.height),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Colors.grey[500].withOpacity(.7),
                              width: 1)))),
            Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.only(top: .0118 * globals.size.height),
                  itemCount: provider.commentsList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin:
                          EdgeInsets.only(bottom: .0059 * globals.size.height),
                      child: FutureBuilder(
                          future: globals.userRepository
                              .get(provider.commentsList[index].uid),
                          builder: (context, snapshot) {
                            if (snapshot.hasData)
                              return CommentWidget(
                                  post: provider.post,
                                  comment: provider.commentsList[index],
                                  commenter: snapshot.data,
                                  leftPadding: paddingPerLevel *
                                      (provider.commentsList[index].level -
                                          parentCommentOffset));
                            else
                              return Container();
                          }),
                    );
                  }),
            ),
          ],
        ));
  }
}

class CommentsPageFooter extends StatefulWidget {
  // Contains a text field for typing a new comment and a button for uploading
  // the comment. When the button is pressed, calls provider.uploadComment to
  // upload the comment. When this process is complete, leaves this page.

  const CommentsPageFooter({
    @required this.height,
    Key key,
  }) : super(key: key);

  final double height;

  @override
  _CommentsPageFooterState createState() => _CommentsPageFooterState();
}

class _CommentsPageFooterState extends State<CommentsPageFooter> {
  bool allowButtonPress = true;
  TextEditingController textController;

  @override
  void initState() {
    textController = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CommentsPageProvider provider =
        Provider.of<CommentsPageProvider>(context, listen: false);

    return AddCommentButton(
        child: Container(
      padding: EdgeInsets.symmetric(horizontal: .05 * globals.size.width),
      child: Row(children: [
        Flexible(
          child: TextFormField(
            style: TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: .03 * globals.size.height,
              color: const Color(0x69000000),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            autofocus: true,
            controller: textController,
          ),
        ),
        GestureDetector(
            child: SvgPicture.string(
              _svg_myuv7f,
              allowDrawingOutsideViewBox: true,
            ),
            onTap: () async {
              if (allowButtonPress) {
                setState(() {
                  allowButtonPress = false;
                });
                Map response = await provider.addComment(textController.text);

                switch (response["denied"]) {
                  case "NSFW":
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) => GenericAlertDialog(
                            text:
                                "Your comment will not be uploaded due to inappropraite langauge."));
                }

                Navigator.pop(context);
              }
            }),
      ]),
    ));
  }
}

const String _svg_myuv7f =
    '<svg viewBox="327.0 861.5 20.0 23.0" ><path transform="matrix(0.0, 1.0, -1.0, 0.0, 347.0, 861.5)" d="M 11.49999904632568 0 L 23 20 L 0 20 Z" fill="#ffffff" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
