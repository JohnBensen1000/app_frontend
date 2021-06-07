import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as image;

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
  // captured a post, whether the post is an image or video, and whether or not
  // the user is currently recording a video. Also provides functionality for
  // taking an image and starting/stopping a video recording. Deletes the last
  // image/video when a new image/video is being taken.

  CameraProvider(
      {@required this.cameraUsage,
      @required this.controller,
      @required this.isFlipped,
      this.chat});

  final CameraUsage cameraUsage;
  final Chat chat;
  final CameraController controller;
  final bool isFlipped;

  int cameraIndex = 0;
  bool isImage = true;
  bool showCapturedPost = false;
  bool isRecording = false;
  String filePath;

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
    filePath = join((await getTemporaryDirectory()).path, 'post.png');
    await controller.takePicture(filePath);

    if (isFlipped) {
      image.Image capturedImage =
          image.decodeImage(await File(filePath).readAsBytes());
      capturedImage = image.flip(capturedImage, image.Flip.vertical);
      capturedImage = image.copyRotate(capturedImage, 90);

      await File(filePath).writeAsBytes(image.encodePng(capturedImage));
    }
    isImage = true;
    showCapturedPost = true;

    notifyListeners();
  }

  Future<void> startRecording() async {
    filePath = join((await getTemporaryDirectory()).path, 'post.mp4');
    await controller.startVideoRecording(filePath);

    isRecording = true;
    notifyListeners();
  }

  Future<void> stopRecording() async {
    controller.stopVideoRecording();

    showCapturedPost = true;
    isImage = false;
    isRecording = false;

    notifyListeners();
  }
}

class Camera extends StatefulWidget {
  // Main Widget for the Camera Page. Has buttons for taking an image/video,
  // changing the camera, and exiting from the camera. This widget is rebuilt
  // everytime the user changes the camera (from front camera to back camera
  // or vica versa).

  Camera({
    @required this.cameraUsage,
    this.chat,
    this.height = 600,
  });

  final CameraUsage cameraUsage;
  final Chat chat;
  final double height;

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  int cameraIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: initializeCamera(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                CameraController cameraController = snapshot.data;

                return ChangeNotifierProvider(
                    create: (_) => CameraProvider(
                        cameraUsage: widget.cameraUsage,
                        controller: cameraController,
                        isFlipped: cameraIndex == 1,
                        chat: widget.chat),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(top: 20, left: 5),
                            child: FlatButton(
                                child: BackArrow(),
                                onPressed: () => Navigator.pop(context))),
                        CameraView(
                            height: widget.height,
                            widget: CameraPreview(cameraController)),
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                    width: 105,
                                    height: 105,
                                    child: Center(
                                      child: GestureDetector(
                                        child: Button(
                                          backgroundColor: Colors.grey[100],
                                          buttonName: "Flip Camera",
                                        ),
                                        onTap: () => setState(() {
                                          cameraIndex = (cameraIndex + 1) % 2;
                                        }),
                                      ),
                                    )),
                              ),
                              PostButton(diameter: 105),
                              Container(
                                width: 105,
                              )
                            ],
                          ),
                        ),
                      ],
                    ));
              } else {
                return Container(color: Colors.black);
              }
            }));
  }

  Future<CameraController> initializeCamera() async {
    CameraController controller;

    final cameras = await availableCameras();
    final camera = cameras[cameraIndex];

    controller = CameraController(camera, ResolutionPreset.high);
    await controller.initialize();

    return controller;
  }
}

class CameraView extends StatelessWidget {
  // Displays what the camera sees in a rectangular container with rounded
  // corners.

  const CameraView({
    Key key,
    @required this.height,
    @required this.widget,
  }) : super(key: key);

  final double height;
  final Widget widget;

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
              borderRadius: BorderRadius.circular(cornerRadius),
              border: Border.all(width: 1.0, color: const Color(0xff707070)),
            ),
          ),
          Container(
              height: height - 2,
              width: width - 2,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(cornerRadius - 1),
                  child: widget)),
        ],
      ),
    );
  }
}

class PostButton extends StatelessWidget {
  // Button that takes an image when tapped, and takes a video when held down.
  // If a video is being recorded, then displays a red CircularProgressIndicator
  // that wraps around a PostButtonCircle. Otherwise displays a PostButtonCircle
  // When the user takes an image or stops recording a video, the user is taken
  // to the Preview page.

  const PostButton({
    Key key,
    @required this.diameter,
  }) : super(key: key);

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(builder: (context, provider, child) {
      return Container(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                  child: (provider.isRecording)
                      ? StreamBuilder(
                          stream: PostButtonVideoTimer().stream,
                          builder: (context, snapshot) {
                            return Stack(children: [
                              PostButtonCircle(diameter: diameter),
                              SizedBox(
                                child: CircularProgressIndicator(
                                  value: snapshot.data,
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.red),
                                ),
                                height: diameter,
                                width: diameter,
                              ),
                            ]);
                          },
                        )
                      : PostButtonCircle(diameter: diameter),
                  onTap: () async {
                    await provider.takeImage();
                    await pushPreviewPage(context, provider);
                  },
                  onLongPress: () async {
                    await provider.startRecording();
                  },
                  onLongPressEnd: (_) async {
                    await provider.stopRecording();
                    await pushPreviewPage(context, provider);
                  }),
            )
          ],
        ),
      );
    });
  }

  Future<void> pushPreviewPage(
      BuildContext context, CameraProvider provider) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Preview(
                  controller: provider.controller,
                  isImage: provider.isImage,
                  cameraUsage: provider.cameraUsage,
                  filePath: provider.filePath,
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
