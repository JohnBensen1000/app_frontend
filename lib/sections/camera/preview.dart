import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../globals.dart' as globals;
import '../../API/posts.dart';
import '../../API/chats.dart';
import '../../models/chat.dart';
import '../../widgets/back_arrow.dart';

import 'widgets/button.dart';

import 'camera.dart';
import 'chat_list.dart';

class PreviewProvider extends ChangeNotifier {
  // Contains state variables used throughout the page. Every widget under this
  // is rebuilt when the variable playVideo is updated (only if post is a
  // video). This is to ensure that the video isn't playing when the user is
  // on the ChatList page.

  PreviewProvider(
      {@required this.controller,
      @required this.isImage,
      @required this.cameraUsage,
      @required this.filePath,
      this.chat});

  final CameraController controller;
  final bool isImage;
  final CameraUsage cameraUsage;
  final String filePath;
  final Chat chat;

  bool _playVideo = true;

  bool allowNewPost = true;

  set playVideo(bool newPlayVideo) {
    _playVideo = newPlayVideo;
    if (!isImage) notifyListeners();
  }

  bool get playVideo {
    return _playVideo;
  }
}

class Preview extends StatefulWidget {
  // Simply initializes PreviewProvider() and PreviewPage().

  Preview(
      {@required this.controller,
      @required this.isImage,
      @required this.cameraUsage,
      @required this.filePath,
      this.chat});

  final CameraController controller;
  final bool isImage;
  final CameraUsage cameraUsage;
  final String filePath;
  final Chat chat;

  @override
  _PreviewState createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider(
            create: (context) => PreviewProvider(
                controller: widget.controller,
                isImage: widget.isImage,
                cameraUsage: widget.cameraUsage,
                filePath: widget.filePath,
                chat: widget.chat),
            child: PreviewPage()));
  }
}

class PreviewPage extends StatelessWidget {
  // Returns a coumn of the image/video preview and possible actions to take
  // with the image/video. The type of preview (image or video) and is
  // determined by PreviewProvider. If the camera is being used to take a
  // profile picture, then highlight the portion of the image that will be used
  // for the profile picture. Determines what options to give the user based
  // on what the camera is being used for.

  @override
  Widget build(BuildContext context) {
    double height = 600;

    return Consumer<PreviewProvider>(
        builder: (context, provider, child) =>
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(top: 20, left: 5),
                  child: FlatButton(
                      child: BackArrow(),
                      onPressed: () => Navigator.pop(context))),
              PreviewView(height: height),
              Container(
                  padding: EdgeInsets.only(left: 20, top: 40, bottom: 40),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        if (provider.cameraUsage == CameraUsage.post)
                          PostOptions()
                        else if (provider.cameraUsage == CameraUsage.profile)
                          ProfileOptions()
                        else if (provider.cameraUsage == CameraUsage.chat)
                          ChatOptions(),
                      ])),
            ]));
  }
}

class PreviewView extends StatelessWidget {
  // Displays the post preview in a rectangular container with rounded corners.

  const PreviewView({
    Key key,
    @required this.height,
  }) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) {
    double width = height / globals.goldenRatio;
    double cornerRadius = height * globals.cornerRadiusRatio;
    PreviewProvider provider =
        Provider.of<PreviewProvider>(context, listen: false);

    return Center(
      child: Stack(alignment: Alignment.center, children: <Widget>[
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cornerRadius),
            border: Border.all(width: 1.0, color: const Color(0xff707070)),
          ),
        ),
        Container(
            height: height - 2,
            width: width - 2,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(cornerRadius - 1),
                child: (provider.isImage)
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: Image(
                            image: Image.file(File(provider.filePath)).image))
                    : VideoPreview(file: File(provider.filePath)))),
      ]),
    );
  }
}

class VideoPreview extends StatefulWidget {
  VideoPreview({Key key, @required this.file}) : super(key: key);

  final File file;

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController videoController;

  @override
  void dispose() {
    videoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeVideoController(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return VideoPlayer(videoController);
        } else {
          return Center(child: Text("Loading..."));
        }
      },
    );
  }

  Future<void> initializeVideoController() async {
    print(widget.file);
    videoController = VideoPlayerController.file(widget.file);
    await videoController.initialize();
    await videoController.setLooping(true);
    await videoController.play();
  }
}

class PostOptions extends StatefulWidget {
  // Displays a list of options for what to do with the post. These options
  // include posting the post publicly and sharing the post in selected group
  // chats. If the user decides to share the post, then a SnackBar() is
  // displayed that allows the user to select which chats to send the post in.

  @override
  _PostOptionsState createState() => _PostOptionsState();
}

class _PostOptionsState extends State<PostOptions> {
  bool showOptions = true;

  @override
  Widget build(BuildContext context) {
    PreviewProvider provider =
        Provider.of<PreviewProvider>(context, listen: false);

    return Container(
      height: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (showOptions)
            GestureDetector(
              child:
                  Button(buttonName: "Post", backgroundColor: Colors.grey[200]),
              onTap: () async {
                if (provider.allowNewPost) {
                  provider.allowNewPost = false;
                  await uploadPost(provider.isImage, false, provider.filePath);
                  int count = 0;
                  Navigator.popUntil(context, (route) {
                    return count++ == 2;
                  });
                }
              },
            ),
          if (showOptions)
            GestureDetector(
                child: Button(
                    buttonName: "Share", backgroundColor: Colors.grey[200]),
                onTap: () {
                  setState(() {
                    showOptions = false;
                  });
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(
                        backgroundColor: Colors.white.withOpacity(.7),
                        duration: Duration(days: 365),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        padding: EdgeInsets.only(left: 5, right: 5),
                        content: ChatListSnackBar(
                          isImage: provider.isImage,
                          filePath: provider.filePath,
                        ),
                      ))
                      .closed
                      .then((value) => setState(() {
                            showOptions = true;
                          }));
                })
        ],
      ),
    );
  }
}

class ProfileOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PreviewProvider provider =
        Provider.of<PreviewProvider>(context, listen: false);

    return GestureDetector(
      child: Button(buttonName: "Save", backgroundColor: Colors.grey[100]),
      onTap: () async {
        if (provider.allowNewPost) {
          provider.allowNewPost = false;
          await uploadProfilePic(provider.isImage, provider.filePath);
          Navigator.pop(context);
        }
      },
    );
  }
}

class ChatOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PreviewProvider provider =
        Provider.of<PreviewProvider>(context, listen: false);

    return GestureDetector(
      child: Button(buttonName: "Send", backgroundColor: Colors.grey[100]),
      onTap: () async {
        if (provider.allowNewPost) {
          provider.allowNewPost = false;
          await sendChatPost(
              provider.isImage, provider.filePath, provider.chat.chatID);
          Navigator.pop(context);
        }
      },
    );
  }
}
