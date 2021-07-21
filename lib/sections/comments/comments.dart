import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/handle_requests.dart';

import '../../globals.dart' as globals;
import '../../API/methods/comments.dart';
import '../../models/post.dart';
import '../../models/comment.dart';
import '../../Widgets/loading_icon.dart';
import '../../Widgets/back_arrow.dart';

import 'widgets/add_comment_button.dart';
import 'comment_widget.dart';
import 'comments_page.dart';

FirebaseStorage storage = FirebaseStorage.instance;

class CommentsProvider extends ChangeNotifier {
  // The only point of this provider is to let widgets below this reset the
  // entire state of this SnackBar.

  void resetState() {
    notifyListeners();
  }
}

class Comments extends StatelessWidget {
  // Initializes CommentsProvider. Gets a list of comments for this post from
  // the backend. Displays a circular progress bar as it waits for the comments
  // list. This widget is rebuilt every time the user posts a new comment.

  Comments({
    @required this.height,
    @required this.post,
  });

  final double height;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height + .0711 * globals.size.height,
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [
            Container(
                margin: EdgeInsets.only(
                    top: 0.0059 * globals.size.height,
                    bottom: 0.0118 * globals.size.height),
                height: .047 * globals.size.height,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        child: Transform.rotate(
                            angle: -math.pi / 2, child: BackArrow()),
                        onTap: () =>
                            Scaffold.of(context).removeCurrentSnackBar()),
                  ],
                )),
            ChangeNotifierProvider(
                create: (context) => CommentsProvider(),
                child: Consumer<CommentsProvider>(
                  builder: (context, value, child) => FutureBuilder(
                    future: handleRequest(context, getAllComments(post)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          height: height,
                          child: CommentsSnackBar(
                              height: height,
                              commentsList: snapshot.data,
                              post: post),
                        );
                      } else {
                        return Center(
                            child: StreamBuilder(
                                stream: LoadingIconTimer().stream,
                                builder: (context, snapshot) {
                                  return CircularProgressIndicator(
                                    strokeWidth: 3,
                                    value: snapshot.data,
                                  );
                                }));
                      }
                    },
                  ),
                )),
          ],
        ));
  }
}

class CommentsSnackBar extends StatelessWidget {
  // Simply determines the layout of the comments snack bar. The layout is a
  // column of the comments and an add-comment button.

  const CommentsSnackBar({
    Key key,
    @required this.height,
    @required this.commentsList,
    @required this.post,
  }) : super(key: key);

  final double height;
  final List<Comment> commentsList;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CommentsSection(
            height: .85 * height, commentsList: commentsList, post: post),
        AddComment(
            height: .15 * height, commentsList: commentsList, post: post),
      ],
    );
  }
}

class CommentsSection extends StatelessWidget {
  // Creates a list view of every comment in comments list. Each item in this
  // list is a Column of one CommentWidget and a row of buttons. The
  // CommentWidget displays the user's profile, username, and comment. The row
  // of buttons currently only lets the user reply to the comment. When the
  // user returns to this page from CommentsPage, calls provider.resetState().

  const CommentsSection({
    @required this.height,
    @required this.commentsList,
    @required this.post,
    Key key,
  }) : super(key: key);

  final double height;
  final List<Comment> commentsList;
  final Post post;

  @override
  Widget build(BuildContext context) {
    CommentsProvider provider =
        Provider.of<CommentsProvider>(context, listen: false);

    double paddingPerLevel = .103 * globals.size.width;

    return Container(
      height: height,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            itemCount: commentsList.length,
            itemBuilder: (BuildContext context, int index) {
              Comment comment = commentsList[index];
              double leftPadding = paddingPerLevel * comment.level;

              return Container(
                margin: EdgeInsets.only(bottom: .0059 * globals.size.height),
                child: Column(
                  children: <Widget>[
                    CommentWidget(
                        post: post, comment: comment, leftPadding: leftPadding),
                    Container(
                      padding: EdgeInsets.only(
                          left: .0513 * globals.size.width + leftPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                right: .0513 * globals.size.width),
                            child: GestureDetector(
                              child: Center(
                                child: Text("Reply"),
                              ),
                              onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => CommentsPage(
                                                post: post,
                                                commentsList: getSubComments(
                                                    commentsList, comment),
                                                parentComment: comment,
                                              )))
                                  .then((value) => provider.resetState()),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }),
      ),
    );
  }

  List<Comment> getSubComments(List<Comment> commentsList, Comment comment) {
    int startIndex = commentsList.indexOf(comment) + 1;
    int endIndex = startIndex + comment.numSubComments;
    return commentsList.sublist(startIndex, endIndex);
  }
}

class AddComment extends StatelessWidget {
  // A button that lets the user post a comment. This button, when pressed,
  // takes the user to CommentsPage(). When the user returns to this page from
  // CommentsPage, calls provider.resetState().

  const AddComment({
    Key key,
    @required this.height,
    @required this.commentsList,
    @required this.post,
  }) : super(key: key);

  final double height;
  final List<Comment> commentsList;
  final Post post;

  @override
  Widget build(BuildContext context) {
    CommentsProvider provider =
        Provider.of<CommentsProvider>(context, listen: false);

    return Container(
      height: height,
      alignment: Alignment.center,
      child: GestureDetector(
        child: AddCommentButton(
          child: Text(
            'Add a comment',
            style: TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: .0237 * globals.size.height,
              color: const Color(0x69000000),
            ),
          ),
        ),
        onTap: () async => await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CommentsPage(
                      post: post,
                      commentsList: commentsList,
                      parentComment: null,
                    ))).then((value) => provider.resetState()),
      ),
    );
  }
}
