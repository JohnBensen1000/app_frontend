import 'package:flutter/material.dart';

class ProfilePicOutline extends StatelessWidget {
  // Returns a semitransparent rectangle that takes up the full screen with a
  // circle cut out from the center of it. This circle is completely
  // transparent.
  ProfilePicOutline({@required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ProfilePicOutlineClip(size: size),
      child: Container(
        color: Colors.black54,
      ),
    );
  }
}

class ProfilePicOutlineClip extends CustomClipper<Path> {
  // Provides the functionality for actually cutting out the circle from the
  // semitransparent rectangle.
  ProfilePicOutlineClip({@required this.size});

  final Size size;

  @override
  Path getClip(Size size) {
    return new Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: .45 * size.width))
      ..fillType = PathFillType.evenOdd;
    ;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
