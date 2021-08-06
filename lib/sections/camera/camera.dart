import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as image;
import 'package:permission_handler/permission_handler.dart';

import '../../globals.dart' as globals;
import '../../models/chat.dart';
import '../../widgets/back_arrow.dart';

import 'preview.dart';

import 'widgets/button.dart';

enum CameraUsage {
  post,
  chat,
  profile,
}

class CameraProvider extends ChangeNotifier {
  // Manages state for the entire post page. Keeps track of whether the user has
  // captured a post and whether the post is an image or video. Also provides
  // functionality for taking an image and starting/stopping a video recording.
  // Contains a future of a camera controller. This camera controller is
  // re-initialized every time cameraIndex changes.
  CameraProvider({@required this.cameraUsage, this.chat}) {
    _cameraIndex = 0;
    isImage = true;
    showCapturedPost = false;
    cameraControllerFuture = _getCameraControllerFuture(cameraIndex);
  }

  final CameraUsage cameraUsage;
  final Chat chat;

  int _cameraIndex;
  bool isImage;
  bool showCapturedPost;
  String filePath;
  Future<CameraController> cameraControllerFuture;

  File get file => File(filePath);

  int get cameraIndex => _cameraIndex;

  set cameraIndex(int newCameraIndex) {
    _cameraIndex = newCameraIndex;
    cameraControllerFuture = _getCameraControllerFuture(cameraIndex);

    notifyListeners();
  }

  Future<CameraController> _getCameraControllerFuture(int cameraIndex) async {
    CameraController controller;

    final cameras = await availableCameras();
    final camera = cameras[cameraIndex];

    controller = CameraController(camera, ResolutionPreset.high);
    await controller.initialize();
    await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);

    return controller;
  }

  Future<void> deleteFile() async {
    if (showCapturedPost) imageCache.clear();
    if (filePath != null && File(filePath).existsSync()) {
      File(filePath).deleteSync();
    }
    showCapturedPost = false;
  }

  Future<void> takeImage() async {
    // If the image has been taken with the user-facing camera, flips/rotates
    // the image so that its orientation is correct.
    XFile file = await (await cameraControllerFuture).takePicture();
    filePath = file.path;

    if (cameraIndex == 1) {
      image.Image capturedImage =
          image.decodeImage(await File(filePath).readAsBytes());
      capturedImage = image.flip(capturedImage, image.Flip.vertical);
      capturedImage = image.copyRotate(capturedImage, 90);

      await File(filePath).writeAsBytes(image.encodePng(capturedImage));
    }
    isImage = true;
    showCapturedPost = true;
  }

  Future<void> startRecording() async {
    (await cameraControllerFuture).startVideoRecording();
  }

  Future<void> stopRecording() async {
    XFile file = await (await cameraControllerFuture).stopVideoRecording();
    filePath = file.path;

    showCapturedPost = true;
    isImage = false;
  }
}

class Camera extends StatelessWidget {
  // Simply initializes the CameraProvider and Camera Page.

  Camera({
    @required this.cameraUsage,
    this.chat,
  });

  final CameraUsage cameraUsage;
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: _getPermissions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.hasData) {
                return ChangeNotifierProvider(
                    create: (_) =>
                        CameraProvider(cameraUsage: cameraUsage, chat: chat),
                    child: CameraPage(
                      cameraUsage: cameraUsage,
                      chat: chat,
                    ));
              } else {
                return Container();
              }
            }));
  }

  Future<void> _getPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    PermissionStatus microphoneStatus = await Permission.microphone.request();

    return cameraStatus == PermissionStatus.granted &&
        microphoneStatus == PermissionStatus.granted;
  }
}

class CameraPage extends StatelessWidget {
  // Main Widget for the Camera Page. Displays the camera preview, along with
  // a back button, a capture image/video button, and a flip camera button.

  CameraPage({
    @required this.cameraUsage,
    this.chat,
  });

  final CameraUsage cameraUsage;
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    double height = .711 * globals.size.height;

    CameraProvider provider =
        Provider.of<CameraProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(
                top: .06 * globals.size.height,
                left: .04 * globals.size.width,
                bottom: .02 * globals.size.height),
            child: GestureDetector(
                child: BackArrow(), onTap: () => Navigator.pop(context))),
        CameraView(
          height: height,
        ),
        Container(
          padding: EdgeInsets.only(top: .0059 * globals.size.height),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.bottomLeft,
                child: Container(
                    width: .269 * globals.size.width,
                    child: Center(
                      child: GestureDetector(
                          child: Button(
                            buttonName: "Flip Camera",
                          ),
                          onTap: () => provider.cameraIndex =
                              (provider.cameraIndex + 1) % 2),
                    )),
              ),
              PostButton(diameter: .12 * globals.size.height),
              Container(
                width: .269 * globals.size.width,
              )
            ],
          ),
        ),
      ],
    );
  }
}

class CameraView extends StatelessWidget {
  // Displays what the camera sees in a rectangular container with rounded
  // corners. Changes size and aspect ratio of camera preview to fit nicely
  // in the container.

  const CameraView({
    Key key,
    @required this.height,
  }) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) {
    double width = height / globals.goldenRatio;
    double cornerRadius = height * globals.cornerRadiusRatio;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(cornerRadius),
              border: Border.all(width: 1.0, color: globals.user.profileColor),
            ),
          ),
          Container(
              height: height - 2,
              width: width - 2,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(cornerRadius - 1),
                  child: Consumer<CameraProvider>(
                      builder: (context, provider, child) => FutureBuilder(
                            future: provider.cameraControllerFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                CameraController cameraController =
                                    snapshot.data;

                                return Transform.scale(
                                  scale: (cameraController.value.aspectRatio) /
                                      (globals.goldenRatio),
                                  child: Center(
                                    child: AspectRatio(
                                        aspectRatio: (1 /
                                            cameraController.value.aspectRatio),
                                        child: CameraPreview(cameraController)),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          )))),
        ],
      ),
    );
  }
}

class PostButton extends StatefulWidget {
  // Button that takes an image when tapped, and takes a video when held down.
  // If a video is being recorded, then displays a CircularProgressIndicator
  // that wraps around a PostButtonCircle. Otherwise displays a PostButtonCircle
  // When the user takes an image or stops recording a video, the user is taken
  // to the Preview page.

  const PostButton({
    Key key,
    @required this.diameter,
    this.strokeWidth = 2,
  }) : super(key: key);

  final double diameter;
  final double strokeWidth;

  @override
  _PostButtonState createState() => _PostButtonState();
}

class _PostButtonState extends State<PostButton> {
  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    CameraProvider provider =
        Provider.of<CameraProvider>(context, listen: false);

    return Container(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
                child: (isRecording)
                    ? StreamBuilder(
                        stream: PostButtonVideoTimer().stream,
                        builder: (context, snapshot) {
                          return Stack(alignment: Alignment.center, children: [
                            PostButtonCircle(diameter: widget.diameter),
                            SizedBox(
                              child: CircularProgressIndicator(
                                strokeWidth: widget.strokeWidth,
                                value: snapshot.data,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    globals.user.profileColor),
                              ),
                              height: widget.diameter + widget.strokeWidth,
                              width: widget.diameter + widget.strokeWidth,
                            ),
                          ]);
                        },
                      )
                    : PostButtonCircle(diameter: widget.diameter),
                onTap: () async {
                  await provider.takeImage();
                  await pushPreviewPage(context, provider);
                },
                onLongPress: () async {
                  await provider.startRecording();
                  setState(() {
                    isRecording = true;
                  });
                },
                onLongPressEnd: (_) async {
                  await provider.stopRecording();
                  await pushPreviewPage(context, provider);
                  setState(() {
                    isRecording = false;
                  });
                }),
          )
        ],
      ),
    );
  }

  Future<void> pushPreviewPage(
      BuildContext context, CameraProvider provider) async {
    CameraController cameraController = await provider.cameraControllerFuture;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Preview(
                  controller: cameraController,
                  isImage: provider.isImage,
                  cameraUsage: provider.cameraUsage,
                  file: provider.file,
                  chat: provider.chat,
                ))).then((_) async => await provider.deleteFile());
  }
}

class PostButtonCircle extends StatelessWidget {
  PostButtonCircle({@required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        PostButtonSubCircle(diameter: 1.00 * diameter, color: Colors.black),
        PostButtonSubCircle(diameter: 0.95 * diameter, color: Colors.white),
        PostButtonSubCircle(diameter: 0.85 * diameter, color: Colors.black),
        PostButtonSubCircle(diameter: 0.80 * diameter, color: Colors.white),
      ],
    );
  }
}

class PostButtonSubCircle extends StatelessWidget {
  /* A stack of PostButtonSubCircle of alternating colors is used to compose
     the "capture image" button.
  */
  const PostButtonSubCircle({
    Key key,
    @required this.diameter,
    @required this.color,
  }) : super(key: key);

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: new BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class PostButtonVideoTimer {
  // Stream that keeps track of how much time has elapsed since the beginning
  // of the recording. This stream is used for the circular progress indicator.

  PostButtonVideoTimer() {
    Timer.periodic(Duration(milliseconds: 1), (_) {
      _progress >= 1 ? _progress = 0 : _progress += (1.0 / 6666.666666667);
      _controller.sink.add(_progress);
    });
  }

  double _progress = 0.0;
  StreamController<double> _controller = StreamController<double>();

  Stream<double> get stream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
