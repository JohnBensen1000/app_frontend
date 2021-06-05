import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';

import '../models/post.dart';
import '../models/user.dart';

import '../globals.dart' as globals;
import 'post_view.dart';
import '../widgets/back_arrow.dart';

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

    return FutureBuilder(
      future: getVideoPlayerController(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
              appBar: PostAppBar(
                height: 40,
                videoPlayerController: snapshot.data,
              ),
              body: Center(
                child: Center(
                  child: PostView(
                    post: post,
                    aspectRatio: globals.goldenRatio,
                    height: 600,
                    postStage: postStage,
                    videoPlayerController: snapshot.data,
                    playOnInit: true,
                    fullPage: true,
                  ),
                ),
              ));
        } else {
          return Container();
        }
      },
    );
  }

  Future<void> getVideoPlayerController() async {
    if (!post.isImage) {
      VideoPlayerController videoPlayerController =
          VideoPlayerController.network(post.downloadURL);
      videoPlayerController.setLooping(true);
      return videoPlayerController;
    } else {
      return null;
    }
  }
}

class PostAppBar extends PreferredSize {
  const PostAppBar(
      {@required this.height, @required this.videoPlayerController});

  final double height;
  final VideoPlayerController videoPlayerController;

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
            onTap: () {
              if (videoPlayerController != null) videoPlayerController.pause();
              Navigator.of(context).pop();
            },
          ),
        )
      ],
    );
  }
}
