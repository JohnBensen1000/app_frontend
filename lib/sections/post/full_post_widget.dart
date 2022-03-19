import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../widgets/profile_pic.dart';
import '../../models/post.dart';
import '../../widgets/entropy_scaffold.dart';

import '../profile_page/profile_page.dart';
import '../comments/comments.dart';

import 'post_widget.dart';
import 'post_page.dart';

class FullPostWidget extends StatefulWidget {
  // Returns a column of the creator's profile, the post, and the comments
  // button. When the profile is pressed, takes user to that creator's profile
  // page. When the post is pressed and the post is not it's own page, then
  // takes the user to the page that only shows the post. When the comments
  // button is pressed, opens up the comments section.

  FullPostWidget(
      {@required this.post,
      @required this.height,
      @required this.width,
      this.playVideo = true,
      this.isFullPage = false,
      this.showComments = false,
      this.verticalOffset = 0,
      this.commentsHeightFraction = .65,
      this.showCaption = false});

  final Post post;
  final bool playVideo;
  final bool isFullPage;
  final bool showComments;
  final bool showCaption;
  final double verticalOffset;
  final double commentsHeightFraction;
  final double height;
  final double width;

  @override
  State<FullPostWidget> createState() => _FullPostWidgetState();
}

class _FullPostWidgetState extends State<FullPostWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomCenter, children: [
      Container(
        width: widget.width,
        child: Column(
          children: [
            GestureDetector(
                key: UniqueKey(),
                child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: .015 * widget.width),
                    child: Profile(
                        diameter: .1 * widget.width,
                        user: widget.post.creator)),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(user: widget.post.creator)))),
            GestureDetector(
                key: UniqueKey(),
                child: PostWidget(
                  post: widget.post,
                  height: widget.height,
                  aspectRatio: widget.height / widget.width,
                  showCaption: widget.showCaption,
                  showComments: widget.showComments,
                  playVideo: widget.playVideo,
                  commentsHeightFraction: widget.commentsHeightFraction,
                ),
                onTap: () {
                  if (!widget.isFullPage) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PostPage(isFullPost: true, post: widget.post)));
                  }
                }),
          ],
        ),
      ),
    ]);
  }
}
