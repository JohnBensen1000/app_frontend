import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'backend_connect.dart';
import 'user_info.dart';

final backendConnection = new ServerAPI();

class NewPost extends StatefulWidget {
  /* Allows users to use the camera to make a new post. This widget is divided
     into 3 main parts: connecting to the camera _initializeCamera(), seeing a 
     the input from the camera , _cameraView(), and after capturing an image, 
     seeing a preview of the image, _postPreview(). 
  */

  final CameraDescription camera;

  NewPost({this.camera});

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool isCameraReady = false;
  bool _showCapturedPhoto = false;
  String _imagePath;
  Size _size;
  double _deviceRatio;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      isCameraReady = true;
    });
  }

  void _takePhoto() async {
    try {
      _imagePath = join((await getTemporaryDirectory()).path, 'image.png');
      await _controller.takePicture(_imagePath);

      setState(() {
        _showCapturedPhoto = true;
      });
    } catch (e) {
      print(e);
    }
  }

  void _deletePhoto() {
    setState(() {
      _showCapturedPhoto = false;
      imageCache.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _deviceRatio = _size.width / _size.height;

    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(children: <Widget>[
              Container(
                  child: FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (_showCapturedPhoto) {
                            return _postPreview(context);
                          } else {
                            return _cameraView(context);
                          }
                        } else {
                          return Center(child: Text("Loading camera preview."));
                        }
                      })),
              Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(top: 50, left: 5),
                  child: FlatButton(
                    child: NewPostFlatButton(
                        buttonName: "Exit Camera",
                        backgroundColor: Colors.white),
                    onPressed: () {
                      _deletePhoto();
                      Navigator.pop(context);
                    },
                  )),
            ])),
      ],
    ));
  }

  Widget _cameraView(BuildContext context) {
    return Stack(
      children: <Widget>[
        Transform.scale(
            scale: _controller.value.aspectRatio / _deviceRatio,
            child: Center(
                child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller)))),
        Transform.translate(
          offset: Offset(0, .375 * MediaQuery.of(context).size.height),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () => _takePhoto(),
              // Button is made up of stack of sub circles
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  PostButtonSubCircle(diameter: 105, color: Colors.black),
                  PostButtonSubCircle(diameter: 100, color: Colors.white),
                  PostButtonSubCircle(diameter: 80, color: Colors.black),
                  PostButtonSubCircle(diameter: 70, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _postPreview(BuildContext context) {
    File imageFile = File(_imagePath);

    return Stack(children: <Widget>[
      Transform.scale(
          scale: _controller.value.aspectRatio / _deviceRatio,
          child: Center(
              child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Image(image: Image.file(imageFile).image)))),
      Container(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(20),
                  child: FlatButton(
                    child: NewPostFlatButton(
                      buttonName: "Post",
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return PostOptions(imagePath: _imagePath);
                          });
                    },
                  )),
              Container(
                  padding: EdgeInsets.all(20),
                  child: FlatButton(
                    child: NewPostFlatButton(
                        buttonName: "Redo", backgroundColor: Colors.white),
                    onPressed: () => _deletePhoto(),
                  )),
            ],
          ))
    ]);
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
      decoration: new BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class PostOptions extends StatelessWidget {
  /* When the user decides to post an image, a widget pops up that gives the
     user several options for what to do with the image. 
  */
  const PostOptions({
    Key key,
    @required String imagePath,
  })  : _imagePath = imagePath,
        super(key: key);

  final String _imagePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
        ),
        Container(
            padding: EdgeInsets.all(10),
            width: 150,
            height: 200,
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.white,
            ),
            child: Column(
              children: <Widget>[
                FlatButton(
                  onPressed: null,
                  child: NewPostFlatButton(
                      buttonName: "To Friend",
                      backgroundColor: Colors.purple[300]),
                ),
                FlatButton(
                  onPressed: () async {
                    await _uploadPost(_imagePath);
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: NewPostFlatButton(
                      buttonName: "Post", backgroundColor: Colors.purple[300]),
                ),
                FlatButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                    child: NewPostFlatButton(
                        buttonName: "Exit",
                        backgroundColor: Colors.purple[300]))
              ],
            )),
      ],
    );
  }

  Future<int> _uploadPost(String imagePath) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse(backendConnection.url + 'posts/$userID/posts/'));

    request.files.add(await http.MultipartFile.fromPath('media', imagePath));

    var response = await request.send();
    return response.statusCode;
  }
}

class NewPostFlatButton extends StatelessWidget {
  /* Every button on the new_post.dart page is shaped/formatted the same way. */
  const NewPostFlatButton({
    Key key,
    @required String buttonName,
    @required Color backgroundColor,
  })  : _buttonName = buttonName,
        _backgroundColor = backgroundColor,
        super(key: key);

  final String _buttonName;
  final Color _backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100,
        height: 30,
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: _backgroundColor,
        ),
        child: Transform.translate(
          offset: Offset(0, 7),
          child: Text(_buttonName, textAlign: TextAlign.center),
        ));
  }
}
