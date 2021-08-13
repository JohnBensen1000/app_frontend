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
    cameraControllerFuture = _getCameraControllerFuture(_cameraIndex);
  }

  final CameraUsage cameraUsage;
  final Chat chat;

  int _cameraIndex;
  bool isImage;
  bool showCapturedPost;
  String filePath;
  Future<CameraController> cameraControllerFuture;

  File get file => File(filePath);

  void toggleCamera() {
    // Changes the camera index and sets cameraControllerFuture to the correct
    // camera future.
    _cameraIndex = (_cameraIndex + 1) % 2;
    cameraControllerFuture = _getCameraControllerFuture(_cameraIndex);

    notifyListeners();
  }

  Future<CameraController> _getCameraControllerFuture(int cameraIndex) async {
    // Gets the camera controller and initializes it.
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

  Future<void> takeImage(BuildContext context) async {
    // If the image has been taken with the user-facing camera, flips/rotates
    // the image so that its orientation is correct. Pushs the user to the
    // preview page after capturing the image.
    XFile file = await (await cameraControllerFuture).takePicture();
    filePath = file.path;

    if (_cameraIndex == 1) {
      image.Image capturedImage =
          image.decodeImage(await File(filePath).readAsBytes());
      capturedImage = image.flip(capturedImage, image.Flip.vertical);
      capturedImage = image.copyRotate(capturedImage, 90);

      await File(filePath).writeAsBytes(image.encodePng(capturedImage));
    }
    isImage = true;
    showCapturedPost = true;

    _pushPreviewPage(context);
  }

  Future<void> startRecording() async {
    (await cameraControllerFuture).startVideoRecording();
  }

  Future<void> stopRecording(BuildContext context) async {
    // Saves the recorded video and sends the user to the preview page.
    XFile file = await (await cameraControllerFuture).stopVideoRecording();
    filePath = file.path;

    showCapturedPost = true;
    isImage = false;

    _pushPreviewPage(context);
  }

  Future<void> _pushPreviewPage(BuildContext context) async {
    CameraController cameraController = await cameraControllerFuture;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Preview(
                  controller: cameraController,
                  isImage: isImage,
                  cameraUsage: cameraUsage,
                  file: file,
                  chat: chat,
                ))).then((_) async => await deleteFile());
  }
}

class Camera extends StatelessWidget {
  // Simply initializes the CameraProvider and Camera Page. Checks to see if
  // it has to ask for permissions.

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

class CameraPage extends StatefulWidget {
  // Returns a stack with the camera view on bottom and a bunch of bottons on
  // top. These buttons include a back arrow, a capture image/video button,
  // a flip camera button, and a timer button. When the timer is pressed, a
  // 3-second countdown is started. When this countdown ends, an image is
  // captured.

  CameraPage({
    @required this.cameraUsage,
    this.chat,
  });

  final CameraUsage cameraUsage;
  final Chat chat;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String _timerString = "";

  @override
  Widget build(BuildContext context) {
    CameraProvider provider =
        Provider.of<CameraProvider>(context, listen: false);
    return Stack(
      children: [
        CameraView(),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(
                    top: .06 * globals.size.height,
                    left: .04 * globals.size.width,
                    bottom: .02 * globals.size.height),
                child: GestureDetector(
                    child: BackArrow(color: Colors.white),
                    onTap: () => Navigator.pop(context))),
            Container(
              padding: EdgeInsets.only(bottom: .06 * globals.size.height),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                          width: .26 * globals.size.width,
                          child: Center(
                            child: GestureDetector(
                                child: _button(
                                  "Flip Camera",
                                ),
                                onTap: () => provider.toggleCamera()),
                          )),
                    ),
                    PostButton(diameter: .12 * globals.size.height),
                    Container(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                          width: .26 * globals.size.width,
                          child: Center(
                            child: GestureDetector(
                                child: _button(
                                  "Start Timer",
                                ),
                                onTap: () => _startTimer(context, provider)),
                          )),
                    ),
                  ],
                ),
                Container(
                    padding: EdgeInsets.only(top: .02 * globals.size.height),
                    child: Text("Hold down to record video",
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: .016 * globals.size.height)))
              ]),
            ),
          ],
        ),
        Container(
            child: Center(
                child: Text(_timerString,
                    style: TextStyle(
                        fontSize: .35 * globals.size.height,
                        color: Colors.white))))
      ],
    );
  }

  Widget _button(String buttonName) {
    return Container(
      width: .2 * globals.size.width,
      height: .0533 * globals.size.height,
      decoration: new BoxDecoration(
        borderRadius:
            BorderRadius.all(Radius.circular(.02 * globals.size.height)),
        color: Colors.grey[200].withOpacity(.7),
      ),
      child: Center(
          child: Text(buttonName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: .0213 * globals.size.height))),
    );
  }

  Future<void> _startTimer(
      BuildContext context, CameraProvider provider) async {
    for (int i = 3; i >= 1; i--) {
      _timerString = i.toString();
      setState(() {});
      await Future.delayed(const Duration(seconds: 1));
    }
    ;
    _timerString = "";
    setState(() {});

    provider.takeImage(context);
  }
}

class CameraView extends StatelessWidget {
  // Displays what the camera sees. Resizes this to take up the entire screen.

  const CameraView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<CameraProvider>(
          builder: (context, provider, child) => FutureBuilder(
                future: provider.cameraControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    CameraController cameraController = snapshot.data;

                    return Transform.scale(
                      scale: (globals.size.height / globals.size.width) /
                          (cameraController.value.aspectRatio),
                      child: Center(
                        child: AspectRatio(
                            aspectRatio:
                                (1 / cameraController.value.aspectRatio),
                            child: CameraPreview(cameraController)),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              )),
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
        children: <Widget>[
          Container(
            child: GestureDetector(
                child: (isRecording)
                    ? StreamBuilder(
                        stream: PostButtonVideoTimer().stream,
                        builder: (context, snapshot) {
                          return Stack(alignment: Alignment.center, children: [
                            _postButtonCircle(widget.diameter),
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
                    : _postButtonCircle(widget.diameter),
                onTap: () async {
                  await provider.takeImage(context);
                },
                onLongPress: () async {
                  await provider.startRecording();
                  setState(() {
                    isRecording = true;
                  });
                },
                onLongPressEnd: (_) async {
                  await provider.stopRecording(context);
                  setState(() {
                    isRecording = false;
                  });
                }),
          )
        ],
      ),
    );
  }

  Widget _postButtonCircle(double diameter) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        _postButtonSubCircle(0.95 * diameter, Colors.white),
        _postButtonSubCircle(0.80 * diameter, Colors.white),
      ],
    );
  }

  Widget _postButtonSubCircle(double diameter, Color color) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: new BoxDecoration(
        border: Border.all(
          color: color,
          width: 2,
        ),
        borderRadius: BorderRadius.all(Radius.circular(globals.size.height)),
        color: Colors.transparent,
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
