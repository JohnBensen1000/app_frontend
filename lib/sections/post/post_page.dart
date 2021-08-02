import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../widgets/back_arrow.dart';
import '../../globals.dart' as globals;

import 'post_widget.dart';
import 'full_post_widget.dart';

class PostPage extends StatelessWidget {
  // An entire page dedicated to displaying a post.
  const PostPage(
      {@required this.post,
      @required this.isFullPost,
      this.showComments = false});

  final Post post;
  final bool isFullPost;
  final bool showComments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(
                    top: .05 * globals.size.height,
                    left: .05 * globals.size.width),
                child: GestureDetector(
                    child: BackArrow(), onTap: () => Navigator.pop(context)),
              )
            ],
          ),
          (isFullPost)
              ? FullPostWidget(
                  post: post,
                  height: .9 * globals.size.height,
                  showComments: showComments,
                  isFullPage: true,
                )
              : Expanded(
                  child: Container(
                    child: PostWidget(
                      post: post,
                      height: .72 * globals.size.height,
                      aspectRatio: globals.goldenRatio,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
