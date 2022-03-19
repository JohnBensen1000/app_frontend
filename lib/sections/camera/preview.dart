import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
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
import '../../widgets/reactive_button.dart';
import '../../widgets/entropy_scaffold.dart';

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
      @required this.cameraAspectRatio,
      this.chat});

  final CameraController controller;
  final bool isImage;
  final CameraUsage cameraUsage;
  final File file;
  final Chat chat;
  final double cameraAspectRatio;

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
        child: Consumer<PreviewProvider>(builder: (context, provider, child) {
          return EntropyScaffold(
            backgroundWidget: GestureDetector(
                child: PreviewView(
                    cameraAspectRatio: widget.cameraAspectRatio,
                    keyboardHeight: keyboardHeight),
                onTap: () => provider.isAddingCaption = false),
            body: Container(
              alignment: Alignment.bottomCenter,
              child: provider.isAddingCaption == false
                  ? PreviewOptions()
                  : AddCaption(),
            ),
          );
        }));
  }
}

class PreviewView extends StatelessWidget {
  // Displays the post preview in a rectangular container with rounded corners.

  const PreviewView({
    @required this.cameraAspectRatio,
    @required this.keyboardHeight,
    Key key,
  }) : super(key: key);

  final double cameraAspectRatio;
  final double keyboardHeight;

  @override
  Widget build(BuildContext context) {
    PreviewProvider provider =
        Provider.of<PreviewProvider>(context, listen: false);
    if (provider.isImage == false) {
      return VideoPreview();
    }

    double height = MediaQuery.of(context).size.height - keyboardHeight;
    double width = MediaQuery.of(context).size.width;

    BoxFit fit = BoxFit.fitHeight;
    if (cameraAspectRatio > 1) {
      if (height / width < cameraAspectRatio) {
        fit = BoxFit.fitWidth;
      }
    } else {
      if (width / height > cameraAspectRatio) {
        fit = BoxFit.fitWidth;
      }
    }

    return Container(
        height: height,
        width: width,
        child: FittedBox(
            fit: fit,
            child: Container(
                height: height,
                width: height / cameraAspectRatio,
                child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.fitWidth,
                            image: Image.file(
                              provider.file,
                            ).image))))));

    // return Container(
    //     child: (provider.isImage)
    //         ? Container(
    //             decoration: BoxDecoration(
    //                 image: DecorationImage(
    //                     fit: BoxFit.fitWidth,
    //                     image: Image.file(
    //                       provider.file,
    //                     ).image)))
    //         : VideoPreview());
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

class PreviewOptions extends StatefulWidget {
  @override
  State<PreviewOptions> createState() => _PreviewOptionsState();
}

class _PreviewOptionsState extends State<PreviewOptions> {
  @override
  Widget build(BuildContext context) {
    PreviewProvider provider =
        Provider.of<PreviewProvider>(context, listen: false);

    return Container(
      padding: EdgeInsets.only(
        top: .08 * globals.size.height,
        left: .06 * globals.size.width,
        right: .06 * globals.size.width,
        bottom: .08 * globals.size.height,
      ),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(
              child: BackArrow(color: Colors.white),
              onTap: () => Navigator.pop(context)),
        ]),
        Column(
          children: [
            GestureDetector(
              child: Container(
                  padding: EdgeInsets.only(bottom: .01 * globals.size.height),
                  child: provider.cameraUsage != CameraUsage.profile
                      ? provider.caption != ""
                          ? PostCaption(text: provider.caption)
                          : PostCaption(
                              text: "Add caption...",
                              textColor: Colors.grey[300])
                      : Container()),
              onTap: () => provider.isAddingCaption = true,
            ),
            PreviewButtons(height: .1 * globals.size.height),
          ],
        )
      ]),
    );
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

class PreviewButtons extends StatelessWidget {
  // Determines what options to give the user based on what the camera is being
  // used for. These buttons are rebuilt every timw provider.showOptions
  // changes. PreviewButton() is a widget that is used for every option that
  // isn't the "share" button. A function is passed to this widget, which is
  // called when the button is pressed. The functions for each option (that
  // isn't "share") are defined here.

  PreviewButtons({@required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Consumer<PreviewProvider>(builder: (context, provider, child) {
      CameraUsage cameraUsage = provider.cameraUsage;

      if (provider.showOptions)
        return Container(
          alignment: Alignment.topCenter,
          height: height,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if ((cameraUsage == CameraUsage.post ||
                    cameraUsage == CameraUsage.profile))
                  PreviewButton(
                      name: "Save as Profile",
                      function: _uploadProfile,
                      color: provider.caption == ""
                          ? Colors.white
                          : Colors.grey[400]),
                if (cameraUsage == CameraUsage.post)
                  ShareButton(
                    name: "Share",
                  ),
                if (cameraUsage == CameraUsage.chat)
                  PreviewButton(
                    name: "Send",
                    function: _sendInChat,
                  ),
                if (cameraUsage == CameraUsage.post)
                  PreviewButton(
                    name: "Post",
                    function: _uploadPost,
                  ),
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
    if (provider.caption == "") {
      return await globals.profileRepository
          .update(provider.isImage, provider.file);
    } else {
      showDialog(
          context: context,
          builder: (context) => GenericAlertDialog(
              text:
                  "You cannot save an image/video as your profile if it has a caption."));
      return null;
    }

    // return await handleRequest(context,
    //     globals.postRepository.postProfile(provider.isImage, provider.file));
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

  PreviewButton(
      {@required this.name,
      @required this.function,
      this.color = Colors.white});

  final String name;
  final Future<Map> Function(PreviewProvider, BuildContext) function;
  final Color color;

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

    return ReactiveButton(
      child: PreviewButtonWidget(buttonName: widget.name, color: widget.color),
      onTap: () async {
        setState(() {
          showLoadingIcon = true;
        });
        Map response = await widget.function(provider, context);

        if (response != null) {
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
        } else {
          setState(() {
            showLoadingIcon = false;
          });
        }
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

    return ReactiveButton(
        child: PreviewButtonWidget(buttonName: name, color: Colors.white),
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

class PreviewButtonWidget extends StatelessWidget {
  PreviewButtonWidget({@required this.buttonName, @required this.color});

  final String buttonName;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: .07 * globals.size.height,
        width: .25 * globals.size.width,
        decoration: BoxDecoration(
            color: color.withOpacity(.25),
            border: Border.all(color: color, width: 4),
            borderRadius: BorderRadius.all(Radius.circular(22))),
        child: Center(
            child: Text(
          buttonName,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontSize: .025 * globals.size.height),
        )));
  }
}
