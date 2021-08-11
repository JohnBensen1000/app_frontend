import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
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
import '../../widgets/post_caption.dart';

import 'camera.dart';
import 'chat_list.dart';

class PreviewProvider extends ChangeNotifier {
  // Contains all data for the preview page. Has two booleans: isAddingCaption
  // and showOptions. Both of these booleans controls who the preview page is
  // built.
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

  bool _isAddingCaption = false;
  bool _showOptions = true;

  String caption = "";

  bool get isAddingCaption => _isAddingCaption;

  set isAddingCaption(bool value) {
    _isAddingCaption = value;
    notifyListeners();
  }

  bool get showOptions => _showOptions;

  set showOptions(bool value) {
    _showOptions = value;
    notifyListeners();
  }
}

class Preview extends StatefulWidget {
  // Main widget for the Preview Page. Initalizes the provider. If the user is
  // currently adding a caption, returns PreviewPageStack, if the user is not
  // adding a caption, returns PreviewPageColumn. This widget rebuilds every
  // time provider.isAddingCaption is changed.

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
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return ChangeNotifierProvider(
        create: (context) => PreviewProvider(
            controller: widget.controller,
            isImage: widget.isImage,
            cameraUsage: widget.cameraUsage,
            file: widget.file,
            chat: widget.chat),
        child: Consumer<PreviewProvider>(
          builder: (context, provider, child) {
            if (provider.isAddingCaption)
              return PreviewPageStack(keyboardHeight: keyboardHeight);
            else
              return PreviewPageColumn();
          },
        ));
  }
}

class PreviewPageColumn extends StatelessWidget {
  // Returns a column that contains: a back button, the post, and a list of
  // options that let the user do different things with the post. A caption
  // widget is placed on top of the post. When the caption widget is pressed,
  // provider.isAddingCaption is set to true, and the user is allowed to add a
  // caption.

  const PreviewPageColumn({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PreviewProvider provider =
        Provider.of<PreviewProvider>(context, listen: false);

    return Scaffold(
        body: Column(
      children: [
        Container(
            height: .12 * globals.size.height,
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(
                top: .06 * globals.size.height,
                left: .04 * globals.size.width,
                bottom: .02 * globals.size.height),
            child: GestureDetector(
                child: BackArrow(), onTap: () => Navigator.pop(context))),
        Stack(alignment: Alignment.bottomCenter, children: [
          PreviewView(
              height: .7 * globals.size.height,
              aspectRatio: globals.goldenRatio,
              cornerRadius:
                  .7 * globals.size.height * globals.cornerRadiusRatio),
          if (provider.cameraUsage != CameraUsage.profile)
            GestureDetector(
              child: Container(
                  child: provider.caption != ""
                      ? PostCaption(text: provider.caption)
                      : PostCaption(
                          text: "Add caption...", textColor: Colors.grey[300])),
              onTap: () => provider.isAddingCaption = true,
            )
        ]),
        PreviewOptions(height: .18 * globals.size.height)
      ],
    ));
  }
}

class PreviewPageStack extends StatelessWidget {
  // Returns a stack that lets the user add a caption. The post is on the bottom
  // of the stack, followed by a transparent button that, when tapped, exits
  // exits from the stack. A semi-transparent text field is on the bottom of the
  // page. This text field allows the user to add a caption to the post.

  const PreviewPageStack({
    Key key,
    @required this.keyboardHeight,
  }) : super(key: key);

  final double keyboardHeight;

  @override
  Widget build(BuildContext context) {
    PreviewProvider provider =
        Provider.of<PreviewProvider>(context, listen: false);
    return Scaffold(
        body: WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: Stack(alignment: Alignment.bottomCenter, children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  PreviewView(
                    height: globals.size.height - keyboardHeight + 2,
                    aspectRatio: (globals.size.height - keyboardHeight + 2) /
                        (globals.size.width + 2),
                    cornerRadius: 0,
                  ),
                  GestureDetector(
                    child: Container(
                      height: globals.size.width,
                      width: globals.size.width,
                      color: Colors.transparent,
                    ),
                    onTap: () => provider.isAddingCaption = false,
                  ),
                ],
              ),
              AddCaption()
            ])));
  }
}

class PreviewView extends StatelessWidget {
  // Displays the post preview in a rectangular container with rounded corners.

  const PreviewView({
    Key key,
    @required this.height,
    @required this.aspectRatio,
    @required this.cornerRadius,
  }) : super(key: key);

  final double height;
  final double aspectRatio;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    double width = height / aspectRatio;
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

class PreviewOptions extends StatelessWidget {
  // Determines what options to give the user based on what the camera is being
  // used for. These buttons are rebuilt every timw provider.showOptions
  // changes. PreviewButton() is a widget that is used for every option that
  // isn't the "share" button. A function is passed to this widget, which is
  // called when the button is pressed. The functions for each option (that
  // isn't "share") are defined here.

  PreviewOptions({@required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Consumer<PreviewProvider>(builder: (context, provider, child) {
      CameraUsage cameraUsage = provider.cameraUsage;

      if (provider.showOptions)
        return Container(
          height: height,
          padding: EdgeInsets.only(
              top: .01 * globals.size.height,
              bottom: .08 * globals.size.height),
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
                if (provider.caption == "" &&
                    (cameraUsage == CameraUsage.post ||
                        cameraUsage == CameraUsage.profile))
                  PreviewButton(
                    name: "Save as Profile",
                    function: _uploadProfile,
                  )
              ]),
        );
      else
        return Container();
    });
  }

  Future<Map> _uploadPost(
      PreviewProvider provider, BuildContext context) async {
    return await postNewPost(
        provider.isImage, false, provider.file, provider.caption);
  }

  Future<Map> _uploadProfile(
      PreviewProvider provider, BuildContext context) async {
    return await globals.profileRepository
        .update(provider.isImage, provider.file);
  }

  Future<Map> _sendInChat(
      PreviewProvider provider, BuildContext context) async {
    return await postChatPost(provider.isImage, provider.file,
        provider.chat.chatID, provider.caption);
  }
}

class PreviewButton extends StatefulWidget {
  // A button, that when pressed, calls the function that was passed to it.
  // Displays a circular icon while waiting for the function to complete. If
  // the post was denied, displays an alert dialog explaining why it was denied.

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
  // A button, that when pressed, displays a snackbar dispalying
  // ChatListSnackBar().
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
                    caption: provider.caption),
              ))
              .closed
              .then((value) => provider.showOptions = true);
        });
  }
}

class AddCaption extends StatefulWidget {
  // A widget that returns a text field allowing the user to add a caption to
  // their post.

  @override
  _AddCaptionState createState() => _AddCaptionState();
}

class _AddCaptionState extends State<AddCaption> {
  final TextEditingController textController = new TextEditingController();

  @override
  void initState() {
    textController.text =
        Provider.of<PreviewProvider>(context, listen: false).caption;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: .01 * globals.size.height),
      child: Container(
        width: .6 * globals.size.width,
        padding: EdgeInsets.symmetric(horizontal: .04 * globals.size.width),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.45),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: new ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 300.0,
          ),
          child: TextField(
              maxLength: 144,
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: .018 * globals.size.height,
                color: Colors.white,
              ),
              maxLines: null,
              autofocus: true,
              decoration: InputDecoration(
                counterStyle: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: .01 * globals.size.height,
                  color: Colors.white,
                ),
                border: InputBorder.none,
              ),
              controller: textController,
              onChanged: (text) =>
                  Provider.of<PreviewProvider>(context, listen: false).caption =
                      text),
        ),
      ),
    );
  }
}
