import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../models/post.dart';
import '../../models/comment.dart';
import '../../repositories/comments.dart';

import 'widgets/add_comment_button.dart';
import 'widgets/comment_widget.dart';
import 'comments_page.dart';

FirebaseStorage storage = FirebaseStorage.instance;

class CommentsProvider extends ChangeNotifier {
  // Keeps track of all the comments for a post. Rebuilds comments section every
  // time the repository is updated. Provides a function for getting all of a
  // comment's replies.

  CommentsProvider({@required this.repository, @required this.post}) {
    _commentsSectionCallback();
  }

  final CommentsSectionRepository repository;
  final Post post;

  List<Comment> get commentsList => repository.commentsList;

  List<Comment> getSubComments(Comment comment) {
    int startIndex = commentsList.indexOf(comment) + 1;
    int endIndex = startIndex + comment.numSubComments;
    return commentsList.sublist(startIndex, endIndex);
  }

  void _commentsSectionCallback() async {
    repository.stream.listen((_) {
      notifyListeners();
    });
  }
}

class Comments extends StatefulWidget {
  // Initializes a new comments section repository whenever built for the first
  // time. Returns a column of the commments section and an add comment button.

  Comments({
    @required this.height,
    @required this.post,
  });

  final double height;
  final Post post;

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  CommentsSectionRepository repository;

  @override
  void initState() {
    repository = new CommentsSectionRepository(postID: widget.post.postID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) =>
            CommentsProvider(repository: repository, post: widget.post),
        child: Column(
          children: <Widget>[
            CommentsSection(height: .82 * widget.height),
            AddComment(height: .18 * widget.height),
          ],
        ));
  }
}

class CommentsSection extends StatelessWidget {
  // Returns a list view of all comments for a post. Each comment is offset by
  // a certain amount based on whether it's a reply or not. For each comment,
  // "reply" button is added to the bottom of the comment widget. When the user
  // hits "reply", sends the user to the comments page.

  const CommentsSection({
    @required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    double paddingPerLevel = .103 * globals.size.width;

    return Container(
      height: height,
      padding: EdgeInsets.only(top: .025 * globals.size.height),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Consumer<CommentsProvider>(
            builder: (context, provider, child) => ListView.builder(
                itemCount: provider.commentsList.length,
                itemBuilder: (BuildContext context, int index) {
                  Comment comment = provider.commentsList[index];
                  double leftPadding = paddingPerLevel * comment.level;
                  Future getUserFuture =
                      globals.userRepository.get(comment.uid);

                  return FutureBuilder(
                      future: getUserFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData)
                          return Container(
                            margin: EdgeInsets.only(
                                bottom: .0059 * globals.size.height),
                            child: Column(
                              children: <Widget>[
                                CommentWidget(
                                    post: provider.post,
                                    comment: comment,
                                    commenter: snapshot.data,
                                    leftPadding: leftPadding),
                                Container(
                                  padding: EdgeInsets.only(
                                      left: .0513 * globals.size.width +
                                          leftPadding),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            right: .0513 * globals.size.width),
                                        child: GestureDetector(
                                          child: Center(
                                            child: Text("Reply",
                                                style: TextStyle(
                                                    fontSize: .015 *
                                                        globals.size.height)),
                                          ),
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => CommentsPage(
                                                        post: provider.post,
                                                        repository:
                                                            provider.repository,
                                                        commentsList: provider
                                                            .getSubComments(
                                                                comment),
                                                        parentComment: comment,
                                                      ))),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        else
                          return Container();
                      });
                })),
      ),
    );
  }
}

class AddComment extends StatelessWidget {
  // A button that lets the user post a comment. This button, when pressed,
  // takes the user to CommentsPage(). When the user returns to this page from
  // CommentsPage, calls provider.resetState().

  const AddComment({
    Key key,
    @required this.height,
  }) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) {
    CommentsProvider provider =
        Provider.of<CommentsProvider>(context, listen: false);

    return Container(
      height: height,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        child: AddCommentButton(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: .05 * globals.size.width),
            child: Text(
              'Add a comment',
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: .0237 * globals.size.height,
                color: const Color(0x69000000),
              ),
            ),
          ),
        ),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CommentsPage(
                      post: provider.post,
                      repository: provider.repository,
                      commentsList: provider.commentsList,
                      parentComment: null,
                    ))),
      ),
    );
  }
}
