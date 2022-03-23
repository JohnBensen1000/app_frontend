import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../widgets/back_arrow.dart';
import '../../globals.dart' as globals;
import '../../widgets/entropy_scaffold.dart';

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
    return EntropyScaffold(
      body: Container(
        padding: EdgeInsets.only(top: .05 * globals.size.height),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  child: GestureDetector(
                      child: BackArrow(), onTap: () => Navigator.pop(context)),
                )
              ],
            ),
            (isFullPost)
                ? FullPostWidget(
                    width: .96 * globals.size.width,
                    height: .75 * globals.size.height,
                    post: post,
                    showComments: showComments,
                    isFullPage: true,
                    showCaption: true,
                  )
                : Expanded(
                    child: Container(
                      child: PostWidget(
                        post: post,
                        height: .72 * globals.size.height,
                        aspectRatio: globals.goldenRatio,
                        showCaption: true,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
