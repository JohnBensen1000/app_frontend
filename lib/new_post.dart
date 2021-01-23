import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class NewPost extends StatefulWidget {
  final CameraDescription camera;

  NewPost({this.camera});

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text("This is supposed to be the camera page"));
  }
}
