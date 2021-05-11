import 'package:flutter/material.dart';

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
