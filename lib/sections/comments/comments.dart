import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/widgets/profile_pic.dart';

import '../../API/comments.dart';
import '../../models/post.dart';
import '../../models/comment.dart';

import 'widgets/add_comment_button.dart';
import 'comments_page.dart';

FirebaseStorage storage = FirebaseStorage.instance;

class CommentsProvider extends ChangeNotifier {
  // resetState() acts like "setState()", it forces all widgets below this to
  // rebuild. The variable, commentsList, is used to store the current list
  // of comments as a FutureBuilder() waits for an updated list of comments.

  List<Comment> commentsList = [];

  void resetState() {
    notifyListeners();
  }
}

class Comments extends StatelessWidget {
  // Initializes CommentsProvider(). Gets a list of comments from backend. When
  // the user adds a new comment, this widget is rebuilt and a new list of
  // comments is recieved from the server. As the FutureBuilder() waits for the
  // new list of comments, the previous list of comments (stored in the
  // provider) is shown.

  Comments({
    @required this.height,
    @required this.post,
  });

  final double height;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => CommentsProvider(),
        child: Consumer<CommentsProvider>(
          builder: (context, provider, child) => Container(
            height: height,
            child: FutureBuilder(
                future: getAllComments(post),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    provider.commentsList = snapshot.data;
                    return CommentsSnackBar(
                        height: height,
                        post: post,
                        commentsList: snapshot.data);
                  } else
                    return CommentsSnackBar(
                      height: height,
                      post: post,
                      commentsList: provider.commentsList,
                    );
                }),
          ),
        ));
  }
}

class CommentsSnackBar extends StatelessWidget {
  // Displays the list of comments as a SnackBar.

  const CommentsSnackBar({
    Key key,
    @required this.height,
    @required this.post,
    @required this.commentsList,
  }) : super(key: key);

  final double height;
  final Post post;
  final List<Comment> commentsList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CommentsSection(
            commentsList: commentsList,
            height: .85 * height,
            showReplyBotton: true,
            post: post),
        AddComment(
          post: post,
          commentsList: commentsList,
        ),
      ],
    );
  }
}

class CommentsSection extends StatelessWidget {
  // Returns a ListVew.builder() of every comment in commentsList. If this list
  // is empty or null, returns an empty container with the same height.

  const CommentsSection({
    @required this.commentsList,
    @required this.height,
    @required this.showReplyBotton,
    @required this.post,
    this.levelOffset = 0,
    this.indent = 40,
    Key key,
  }) : super(key: key);

  final List<Comment> commentsList;
  final double height;
  final bool showReplyBotton;
  final Post post;
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
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.builder(
              itemCount: commentsList.length,
              itemBuilder: (BuildContext context, int index) {
                return CommentWidget(
                  comment: commentsList[index],
                  indent: indent,
                  levelOffset: levelOffset,
                  showReplyBotton: showReplyBotton,
                  commentsList: commentsList,
                  post: post,
                );
              },
            ),
          ),
        ),
      );
  }
}

class CommentWidget extends StatelessWidget {
  // Widget for an individual comment.
  CommentWidget({
    @required this.comment,
    @required this.indent,
    @required this.levelOffset,
    @required this.showReplyBotton,
    @required this.commentsList,
    @required this.post,
  });

  final Comment comment;
  final double indent;
  final int levelOffset;
  final bool showReplyBotton;
  final List<Comment> commentsList;
  final Post post;

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
              Row(
                children: <Widget>[
                  if (showReplyBotton)
                    ProfilePic(diameter: 45, user: comment.user),
                  Column(
                    children: [
                      Text(
                        comment.user.userID,
                        style: TextStyle(
                          fontFamily: 'Helvetica Neue',
                          fontSize: 15,
                          color: const Color(0xff707070),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      if (showReplyBotton)
                        GestureDetector(
                            child: Text("Reply"),
                            onTap: () async => await replyToComment(context))
                    ],
                  ),
                ],
              ),
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

  List<Comment> getSubComments(Comment comment) {
    int startIndex = commentsList.indexOf(comment) + 1;
    int endIndex = startIndex + comment.numSubComments;
    return commentsList.sublist(startIndex, endIndex);
  }

  Future<void> replyToComment(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CommentsPage(
                  post: post,
                  commentsList: (comment == null)
                      ? commentsList
                      : getSubComments(comment),
                  parentComment: comment,
                ))).then((commentText) async {
      if (commentText != null) await postComment(post, comment, commentText);
      if (commentText != null)
        Provider.of<CommentsProvider>(context, listen: false).resetState();
    });
  }
}

class AddComment extends StatelessWidget {
  const AddComment({
    Key key,
    @required this.post,
    @required this.commentsList,
  }) : super(key: key);

  final Post post;
  final List<Comment> commentsList;

  @override
  Widget build(BuildContext context) {
    CommentsProvider provider =
        Provider.of<CommentsProvider>(context, listen: false);

    return GestureDetector(
        child: AddCommentButton(
          child: Text(
            'Add a comment',
            style: TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: 20,
              color: const Color(0x69000000),
              letterSpacing: -0.48,
              height: 1.1,
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
                        ))).then((commentText) async {
              await postComment(post, null, commentText);
              if (commentText != null) provider.resetState();
            }));
  }
}
