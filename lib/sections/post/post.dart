import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';

import '../../globals.dart' as globals;
import '../../models/post.dart';
import '../../widgets/back_arrow.dart';

import 'post_view.dart';

FirebaseStorage storage = FirebaseStorage.instance;

class PostPage extends StatelessWidget {
  // Returns a scaffold that only includes a PostView() and a return button.
  // If this widget is called from the chat page, then dont show the full
  // post widget. Initializes videoPlayerController() here if the post is a
  // video.

  PostPage({@required this.post, this.fromChatPage = false});

  final Post post;
  final bool fromChatPage;

  @override
  Widget build(BuildContext context) {
    PostStage postStage =
        (fromChatPage) ? PostStage.onlyPost : PostStage.fullWidget;

    return Scaffold(
        appBar: PostAppBar(
          height: 40,
        ),
        body: Center(
          child: Center(
            child: PostView(
              post: post,
              aspectRatio: globals.goldenRatio,
              height: 600,
              postStage: postStage,
              playOnInit: true,
              fullPage: true,
            ),
          ),
        ));
  }
}

class PostAppBar extends PreferredSize {
  const PostAppBar({@required this.height});

  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20, top: 40),
          child: GestureDetector(
            child: BackArrow(),
            onTap: () => Navigator.of(context).pop(),
          ),
        )
      ],
    );
  }
}
