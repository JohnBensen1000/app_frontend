import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'backend_connect.dart';
import 'user_info.dart';

final backendConnection = new BackendConnection();

class NewPost extends StatefulWidget {
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
  String imagePath;

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
      imagePath = join((await getTemporaryDirectory()).path, 'image.png');
      await _controller.takePicture(imagePath);

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

  void _uploadPost(String imagePath) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse(backendConnection.url + 'posts/$userID/posts/'));

    request.files.add(await http.MultipartFile.fromPath('media', imagePath));

    var response = await request.send();
    print(response.statusCode);
  }

  // void _uploadPost(File imageFile) async {
  //   String fileName = '1111';
  //   StorageReference firebaseStorageRef =
  //       FirebaseStorage.instance.ref().child('uploads/$fileName');

  //   StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
  //   StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  //   taskSnapshot.ref.getDownloadURL().then(
  //         (value) => print("Done: $value"),
  //       );
  // }

  @override
  Widget build(BuildContext context) {
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
                            return _cameraView(context);
                          } else {
                            return _postPreview(context);
                          }
                        } else {
                          return Center(child: Text("Loading camera preview."));
                        }
                      })),
              Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(40.0),
                  child: RaisedButton(
                      onPressed: () {
                        _deletePhoto();
                        Navigator.pop(context);
                      },
                      child: Text("Exit Camera"))),
            ])),
      ],
    ));
  }

  Widget _cameraView(BuildContext context) {
    File imageFile = File(imagePath);

    return Stack(children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: Image.file(imageFile).image,
          ),
        ),
      ),
      Container(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                child: RaisedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                              padding: EdgeInsets.all(40),
                              child: Column(
                                children: <Widget>[
                                  RaisedButton(
                                    onPressed: null,
                                    child: Text("To Friend"),
                                  ),
                                  RaisedButton(
                                    onPressed: () async {
                                      await _uploadPost(imagePath);
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                    },
                                    child: Text("Post"),
                                  ),
                                ],
                              ));
                        });
                  },
                  child: Text("Post"),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: RaisedButton(
                  onPressed: () => _deletePhoto(),
                  child: Text("Redo"),
                ),
              )
            ],
          ))
    ]);
  }

  Widget _postPreview(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(child: CameraPreview(_controller))),
      Container(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.all(20),
          child: RaisedButton(
              onPressed: () => _takePhoto(), child: Text("Take Photo")),
        ),
      ),
    ]);
  }
}
