import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:adobe_xd/blend_mask.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                  padding: EdgeInsets.only(top: 50, left: 5),
                  child: FlatButton(
                      onPressed: () {
                        _deletePhoto();
                        Navigator.pop(context);
                      },
                      child: Container(
                          width: 100,
                          height: 30,
                          decoration: new BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Colors.white,
                          ),
                          child: Transform.translate(
                            offset: Offset(0, 7),
                            child: Text("Exit Camera",
                                textAlign: TextAlign.center),
                          )))),
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
    return Stack(
      children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(child: CameraPreview(_controller))),
        Transform.translate(
          offset: Offset(0, .35 * MediaQuery.of(context).size.height),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: FlatButton(
              onPressed: () => _takePhoto(),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: 120,
                    decoration: new BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 110,
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 85,
                    decoration: new BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 70,
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const String _svg_nzdss2 =
    '<svg viewBox="126.2 672.3 122.6 119.0" ><path transform="translate(126.18, 672.25)" d="M 61.31533813476562 0 C 80.99004364013672 0 98.50040435791016 8.992035865783691 109.9596633911133 23.27257919311523 C 117.8112106323242 33.05385589599609 122.6306762695312 45.72988891601562 122.6306762695312 59.49820709228516 C 122.6306762695312 92.358154296875 95.17886352539062 118.9964141845703 61.31533813476562 118.9964141845703 C 27.45181274414062 118.9964141845703 0 92.358154296875 0 59.49820709228516 C 0 47.11000442504883 3.901699066162109 35.60608673095703 10.81383895874023 25.74596214294434 C 21.60995674133301 10.33907985687256 40.21836471557617 0 61.31533813476562 0 Z" fill="#ffffff" stroke="#000000" stroke-width="4" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_dhgtvw =
    '<svg viewBox="142.8 687.6 89.5 88.2" ><path transform="translate(142.76, 687.64)" d="M 44.74025344848633 0 C 69.44961547851562 0 89.48050689697266 19.74792671203613 89.48050689697266 44.10822296142578 C 89.48050689697266 68.46852111816406 69.44961547851562 88.21644592285156 44.74025344848633 88.21644592285156 C 20.0308952331543 88.21644592285156 0 68.46852111816406 0 44.10822296142578 C 0 19.74792671203613 20.0308952331543 0 44.74025344848633 0 Z" fill="#ffffff" fill-opacity="0.07" stroke="#000000" stroke-width="6" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_bscobc =
    '<svg viewBox="90.0 751.0 26.0 25.0" ><path transform="translate(90.0, 751.0)" d="M 18.38477516174316 2.419335032755043e-06 L 26 7.322331428527832 L 25.99999809265137 17.67767143249512 L 18.38477516174316 25 C 18.38477516174316 25 15.98467063903809 25 13.19084930419922 25 C 11.8945198059082 25 10.2551383972168 25 9.199722290039062 25 C 6.507334232330322 25 7.615222930908203 25 7.615222930908203 25 L 0 17.67766761779785 L 2.516108224881464e-06 7.322328567504883 L 7.615228176116943 0 L 18.38477516174316 2.419335032755043e-06 Z" fill="#ffffff" fill-opacity="0.0" stroke="#000000" stroke-width="4" stroke-opacity="1.0" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_wmd048 =
    '<svg viewBox="90.0 688.0 26.0 25.0" ><path transform="translate(90.0, 688.0)" d="M 18.38477516174316 2.419335032755043e-06 L 26 7.322331428527832 L 25.99999809265137 17.67767143249512 L 18.38477516174316 25 C 18.38477516174316 25 15.98467063903809 25 13.19084930419922 25 C 11.8945198059082 25 10.2551383972168 25 9.199722290039062 25 C 6.507334232330322 25 7.615222930908203 25 7.615222930908203 25 L 0 17.67766761779785 L 2.516108224881464e-06 7.322328567504883 L 7.615228176116943 0 L 18.38477516174316 2.419335032755043e-06 Z" fill="#ffffff" fill-opacity="0.0" stroke="#000000" stroke-width="4" stroke-opacity="1.0" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
