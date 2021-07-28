import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/baseAPI.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:test_flutter/sections/camera/widgets/button.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/scheduler.dart';

import '../../globals.dart' as globals;
import '../../API/methods/posts.dart';
import '../../API/methods/chats.dart';
import '../../models/chat.dart';
import '../../widgets/back_arrow.dart';
import '../../widgets/generic_alert_dialog.dart';

import '../../widgets/loading_icon.dart';

import 'camera.dart';
import 'chat_list.dart';

class PreviewProvider extends ChangeNotifier {
  // Contains state variables used throughout the page. Also contains two
  // booleans: allowNewPost and _showOptions. allowNewPost determines whether a
  // user could press one of the buttons. This value is automatically set to
  // true, and is set to false after a user presses a button. This variable is
  // used to ensure that a user could only press one button at a time.
  // _showOptions determines whether to show the buttons or not. This is set to
  // false when "share" is pressed.

  PreviewProvider(
      {@required this.controller,
      @required this.isImage,
      @required this.cameraUsage,
      @required this.file,
      this.chat});

  final CameraController controller;
  final bool isImage;
  final CameraUsage cameraUsage;
  final File file;
  final Chat chat;

  bool allowNewPost = true;
  bool _showOptions = true;

  bool get showOptions => _showOptions;

  set showOptions(bool newShowOptions) {
    _showOptions = newShowOptions;
    notifyListeners();
  }
}

class Preview extends StatefulWidget {
  // Simply initializes PreviewProvider() and PreviewPage().

  Preview(
      {@required this.controller,
      @required this.isImage,
      @required this.cameraUsage,
      @required this.file,
      this.chat});

  final CameraController controller;
  final bool isImage;
  final CameraUsage cameraUsage;
  final File file;
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
                file: widget.file,
                chat: widget.chat),
            child: PreviewPage()));
  }
}

class PreviewPage extends StatelessWidget {
  // Returns a column of the image/video preview and possible actions to take
  // with the image/video. The type of preview (image or video) is determined by
  // PreviewProvider. Determines what options to give the user based on what the
  // camera is being used for. These buttons are rebuilt every time
  // provider.showOptions changes. PreviewButton() is a widget that is used for
  // every option that isn't the "share" button. A function is passed to this
  // widget, which is called when the button is pressed. The functions for each
  // option (that isn't "share") are defined here.

  @override
  Widget build(BuildContext context) {
    double height = .711 * globals.size.height;

    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(
              top: .06 * globals.size.height,
              left: .04 * globals.size.width,
              bottom: .02 * globals.size.height),
          child: GestureDetector(
              child: BackArrow(), onTap: () => Navigator.pop(context))),
      PreviewView(height: height),
      Consumer<PreviewProvider>(builder: (context, provider, child) {
        CameraUsage cameraUsage = provider.cameraUsage;

        if (provider.showOptions)
          return Container(
              padding: EdgeInsets.only(
                  top: .047 * globals.size.height,
                  bottom: .047 * globals.size.height),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (cameraUsage == CameraUsage.post)
                      PreviewButton(
                        name: "Post",
                        function: _uploadPost,
                      ),
                    if (cameraUsage == CameraUsage.post)
                      ShareButton(
                        name: "Share",
                      ),
                    if (cameraUsage == CameraUsage.chat)
                      PreviewButton(
                        name: "Send",
                        function: _sendInChat,
                      ),
                    if (cameraUsage == CameraUsage.post ||
                        cameraUsage == CameraUsage.profile)
                      PreviewButton(
                        name: "Save as Profile",
                        function: _uploadProfile,
                      ),
                  ]));
        else
          return Container();
      }),
    ]);
  }

  Future<Map> _uploadPost(
      PreviewProvider provider, BuildContext context) async {
    return await handleRequest(
        context, postNewPost(provider.isImage, false, provider.file));
  }

  Future<Map> _uploadProfile(
      PreviewProvider provider, BuildContext context) async {
    return await handleRequest(context,
        globals.postRepository.postProfile(provider.isImage, provider.file));
  }

  Future<Map> _sendInChat(
      PreviewProvider provider, BuildContext context) async {
    return await handleRequest(context,
        postChatPost(provider.isImage, provider.file, provider.chat.chatID));
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
            border: Border.all(width: 1.0, color: globals.user.profileColor),
          ),
        ),
        Container(
            height: height - 2,
            width: width - 2,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(cornerRadius - 1),
                child: (provider.isImage)
                    ? Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: Image.file(provider.file).image)))
                    : VideoPreview())),
      ]),
    );
  }
}

class VideoPreview extends StatefulWidget {
  // Widget used if the post is a video. Creates/initializes a video player when
  // created, disposes this video play when disposed.

  VideoPreview({Key key}) : super(key: key);

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController videoPlayerController;

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PreviewProvider provider =
        Provider.of<PreviewProvider>(context, listen: false);

    return FutureBuilder(
      future: initializeVideoPlayer(provider.file.path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return VideoPlayer(videoPlayerController);
        } else {
          return Center(child: Text("Loading..."));
        }
      },
    );
  }

  Future<void> initializeVideoPlayer(String filePath) async {
    videoPlayerController = VideoPlayerController.file(File(filePath));
    await videoPlayerController.setLooping(true);
    await videoPlayerController.initialize();
    await videoPlayerController.play();
  }
}

class PreviewButton extends StatefulWidget {
  // A generic button used on the preview page. A function is passed to this
  // widget. This function is called whenever this button is pressed. When
  // pressed, rebuilds the state with showLoadingIcon set to true. This will
  // lead to an AlertDialog being displayed after the widget is rebuilt. This
  // alert dialog will show that the app is waiting for the function to finish.
  // If the function returns a json object containing a none-null value for
  // "reasonForRejection", then displays an alert dialog explaning why the
  // post was rejected.

  PreviewButton({@required this.name, @required this.function});

  final String name;
  final Future<Map> Function(PreviewProvider, BuildContext) function;

  @override
  _PreviewButtonState createState() => _PreviewButtonState();
}

class _PreviewButtonState extends State<PreviewButton> {
  bool showLoadingIcon = false;

  @override
  Widget build(BuildContext context) {
    PreviewProvider provider =
        Provider.of<PreviewProvider>(context, listen: false);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (showLoadingIcon)
        showDialog(
          context: context,
          builder: (context) {
            return LoadingIcon();
          },
        );
    });

    return GestureDetector(
      child: Button(buttonName: widget.name),
      onTap: () async {
        provider.allowNewPost = false;
        setState(() {
          showLoadingIcon = true;
        });
        Map response = await widget.function(provider, context);

        switch (response["denied"]) {
          case "NSFW":
            await showDialog(
                context: context,
                builder: (BuildContext context) => GenericAlertDialog(
                    text:
                        "Our automatic filter has determined that your post has violated our guidelines. Our team will review your post and release it if your post does not actually violate our guidelines."));
        }

        int numPops = (provider.cameraUsage == CameraUsage.profile) ? 3 : 2;
        int count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == numPops;
        });
      },
    );
  }
}

class ShareButton extends StatelessWidget {
  // A widget specific for the "share" button. When pressed, displays a
  // the ChatListSnackBar snackbar.
  ShareButton({@required this.name});

  final String name;
  @override
  Widget build(BuildContext context) {
    PreviewProvider provider =
        Provider.of<PreviewProvider>(context, listen: false);

    return GestureDetector(
        child: Button(
          buttonName: name,
        ),
        onTap: () {
          provider.showOptions = false;
          Scaffold.of(context)
              .showSnackBar(SnackBar(
                backgroundColor: Colors.white.withOpacity(.7),
                duration: Duration(days: 365),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                padding: EdgeInsets.only(
                    left: .0128 * globals.size.width,
                    right: .0128 * globals.size.width),
                content: ChatListSnackBar(
                  isImage: provider.isImage,
                  file: provider.file,
                ),
              ))
              .closed
              .then((value) => provider.showOptions = true);
        });
  }
}
