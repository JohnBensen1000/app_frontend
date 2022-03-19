import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as image;
import 'package:permission_handler/permission_handler.dart';

import '../../globals.dart' as globals;
import '../../models/chat.dart';
import '../../widgets/back_arrow.dart';
import '../../widgets/reactive_button.dart';
import '../../widgets/entropy_scaffold.dart';

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
  // re-initialized every time cameraIndex changes. Also keeps track of which
  // flash mode the camera is currently in.

  CameraProvider({@required this.cameraUsage, this.chat}) {
    _flashIndex = 0;
    _cameraIndex = 0;
    _isTimerOn = false;

    isImage = true;
    showCapturedPost = false;
    timerString = "";
    cameraControllerFuture = _getCameraControllerFuture(_cameraIndex);
    flashModes = [FlashMode.auto, FlashMode.always, FlashMode.off];
  }
  final CameraUsage cameraUsage;
  final Chat chat;

  int _cameraIndex;
  bool _isTimerOn;
  int _flashIndex;

  bool isImage;
  bool showCapturedPost;
  String filePath;
  String timerString;
  Future<CameraController> cameraControllerFuture;
  List<FlashMode> flashModes;

  File get file => File(filePath);

  bool get isTimerOn => _isTimerOn;
  int get flashIndex => _flashIndex;

  void toggleCamera() {
    // Changes the camera index and sets cameraControllerFuture to the correct
    // camera future.
    print(" [DEBUG] toggling...");
    _cameraIndex = (_cameraIndex + 1) % 2;
    cameraControllerFuture = _getCameraControllerFuture(_cameraIndex);
    print(" [DEBUG] Notifying listeners");
    notifyListeners();
  }

  void toggleFlash() async {
    // After user initially taps on flash, only toggles between on/off
    _flashIndex = (_flashIndex + 1) % 3;
    notifyListeners();
  }

  void toggleTimer() {
    _isTimerOn = !_isTimerOn;
    notifyListeners();
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

    CameraController controller = await cameraControllerFuture;

    await controller.setFlashMode(flashModes[_flashIndex]);

    if (_isTimerOn) await _startTimer(context);

    XFile file = await controller.takePicture();
    filePath = file.path;

    if (_cameraIndex == 1 && Platform.isIOS) {
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

  Future<void> _startTimer(BuildContext context) async {
    for (int i = 3; i >= 1; i--) {
      timerString = i.toString();
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
    }
    ;
    timerString = "";
    notifyListeners();
  }

  Future<void> _pushPreviewPage(BuildContext context) async {
    CameraController cameraController = await cameraControllerFuture;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Preview(
                  cameraAspectRatio: cameraController.value.aspectRatio,
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
    return FutureBuilder(
        future: _getPermissions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return ChangeNotifierProvider(
                create: (_) =>
                    CameraProvider(cameraUsage: cameraUsage, chat: chat),
                child: Consumer<CameraProvider>(
                    builder: (context, provider, child) => EntropyScaffold(
                          backgroundWidget: CameraView(),
                          body: CameraOptions(
                              cameraUsage: cameraUsage, chat: chat),
                        )));
          } else {
            return Container();
          }
        });
  }

  Future<void> _getPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    PermissionStatus microphoneStatus = await Permission.microphone.request();

    return cameraStatus == PermissionStatus.granted &&
        microphoneStatus == PermissionStatus.granted;
  }
}

class CameraView extends StatelessWidget {
  // Displays what the camera sees. Resizes this to take up the entire screen.

  const CameraView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CameraProvider provider =
        Provider.of<CameraProvider>(context, listen: false);

    return Center(
      child: FutureBuilder(
        future: provider.cameraControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            CameraController cameraController = snapshot.data;

            double height = MediaQuery.of(context).size.height;
            double width = MediaQuery.of(context).size.width;

            BoxFit fit = BoxFit.fitHeight;
            if (cameraController.value.aspectRatio > 1) {
              if (height / width < cameraController.value.aspectRatio) {
                fit = BoxFit.fitWidth;
              }
            } else {
              if (width / height > cameraController.value.aspectRatio) {
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
                        width: height / cameraController.value.aspectRatio,
                        child: CameraPreview(
                          cameraController,
                        ))));
          } else {
            return Container();
          }
        },
      ),
    );
  }
}

class CameraOptions extends StatefulWidget {
  // Returns a stack with the camera view on bottom and a bunch of bottons on
  // top. These buttons include a back arrow, a capture image/video button,
  // a flip camera button, and a timer toggle botton. If the timer is on, then
  // when the user presses on the capture image button, a 3 second timer is
  // started. When the time ends, an image is captured and the user is sent to
  // the preview page.

  CameraOptions({
    @required this.cameraUsage,
    this.chat,
  });

  final CameraUsage cameraUsage;
  final Chat chat;

  @override
  State<CameraOptions> createState() => _CameraOptionsState();
}

class _CameraOptionsState extends State<CameraOptions> {
  @override
  Widget build(BuildContext context) {
    CameraProvider provider =
        Provider.of<CameraProvider>(context, listen: false);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
        Container(
          height: globals.size.height,
          width: globals.size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: .06 * globals.size.height,
                  left: .04 * globals.size.width,
                  right: .04 * globals.size.width,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        child: BackArrow(color: Colors.white),
                        onTap: () => Navigator.pop(context)),
                    Column(
                      children: [
                        ReactiveButton(child: _flashButton()),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: .06 * globals.size.height),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: .26 * globals.size.width,
                          child: Center(
                            child: ReactiveButton(
                                child: SvgPicture.asset(
                                  "assets/images/flip_camera.svg",
                                  height: .07 * globals.size.height,
                                ),
                                onTap: () {
                                  print(" [DEBUG] tapped");
                                  provider.toggleCamera();
                                }),
                          )),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: .02 * globals.size.width),
                          child:
                              PostButton(diameter: .12 * globals.size.height)),
                      Container(
                        width: .26 * globals.size.width,
                        child: Center(
                          child: ReactiveButton(
                              child: provider.isTimerOn
                                  ? SvgPicture.asset(
                                      "assets/images/timer_icon.svg",
                                      height: .07 * globals.size.height,
                                    )
                                  : SvgPicture.asset(
                                      "assets/images/timer_icon_off.svg",
                                      height: .07 * globals.size.height,
                                    ),
                              onTap: provider.toggleTimer),
                        ),
                      )
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
        ),
        Container(
            child: Center(
                child: Text(provider.timerString,
                    style: TextStyle(
                        fontSize: .35 * globals.size.height,
                        color: Colors.white))))
      ],
    );
  }

  Widget _flashButton() {
    CameraProvider provider =
        Provider.of<CameraProvider>(context, listen: false);

    Widget child;
    switch (Provider.of<CameraProvider>(context, listen: false).flashIndex) {
      case 0:
        child = Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              child: SvgPicture.asset(
                "assets/images/flash_on.svg",
                height: .07 * globals.size.height,
              ),
            ),
            Container(
                padding: EdgeInsets.all(.002 * globals.size.height),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(.005 * globals.size.height)),
                  color: Colors.white,
                ),
                child: Text("auto",
                    style: TextStyle(fontSize: .015 * globals.size.height)))
          ],
        );
        break;
      case 1:
        child = SvgPicture.asset(
          "assets/images/flash_on.svg",
          height: .07 * globals.size.height,
        );
        break;
      case 2:
        child = SvgPicture.asset(
          "assets/images/flash_off.svg",
          height: .07 * globals.size.height,
        );
    }

    return ReactiveButton(child: child, onTap: () => provider.toggleFlash());
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
  double scaler = 1.0;

  @override
  Widget build(BuildContext context) {
    CameraProvider provider =
        Provider.of<CameraProvider>(context, listen: false);

    return Container(
      child: Stack(
        children: <Widget>[
          Container(
              height: widget.diameter + widget.strokeWidth,
              width: widget.diameter + widget.strokeWidth,
              child: FutureBuilder(
                  future: globals.userRepository.get(globals.uid),
                  builder: (context, snapshot) => ReactiveButton(
                        child: (isRecording)
                            ? StreamBuilder(
                                stream: PostButtonVideoTimer().stream,
                                builder: (context, timerSnapshot) {
                                  return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        _postButtonCircle(widget.diameter),
                                        SizedBox(
                                          child: CircularProgressIndicator(
                                            strokeWidth: widget.strokeWidth,
                                            value: timerSnapshot.data,
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                    Color>(snapshot
                                                        .hasData
                                                    ? snapshot.data.profileColor
                                                    : Colors.white),
                                          ),
                                          height: scaler * widget.diameter +
                                              widget.strokeWidth,
                                          width: scaler * widget.diameter +
                                              widget.strokeWidth,
                                        ),
                                      ]);
                                },
                              )
                            : _postButtonCircle(widget.diameter),
                        onTap: _takeImage,
                        onLongPress: _startRecording,
                        onLongPressEnd: _stopRecording,
                      )))
        ],
      ),
    );
  }

  Future<void> _takeImage() async {
    await Provider.of<CameraProvider>(context, listen: false)
        .takeImage(context);
  }

  Future<void> _startRecording() async {
    setState(() {
      isRecording = true;
    });
    await Provider.of<CameraProvider>(context, listen: false).startRecording();
  }

  Future<void> _stopRecording() async {
    setState(() {
      isRecording = false;
    });
    await Provider.of<CameraProvider>(context, listen: false)
        .stopRecording(context);
  }

  Widget _postButtonCircle(double diameter) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        _postButtonSubCircle(scaler * 0.95 * diameter, Colors.white),
        _postButtonSubCircle(scaler * 0.80 * diameter, Colors.white),
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
