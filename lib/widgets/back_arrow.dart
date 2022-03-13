import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';

import '../globals.dart' as globals;

class BackArrow extends StatelessWidget {
  BackArrow({this.color = const Color(0xffa2a2a2)});
  final Color color;

  @override
  Widget build(BuildContext context) {
    double size = 2.5;

    return Container(
      padding: EdgeInsets.only(
        top: .01 * globals.size.height,
        bottom: .01 * globals.size.height,
        right: .1 * globals.size.width,
      ),
      color: Colors.transparent,
      child: SizedBox(
        width: size * 14.0,
        height: size * 10.0,
        child: Stack(
          children: <Widget>[
            Pinned.fromSize(
              bounds: Rect.fromLTWH(
                  size * 0.6, size * 4.6, size * 13.0, size * 1.0),
              size: Size(size * 13.6, size * 10.2),
              pinLeft: true,
              pinRight: true,
              fixedHeight: true,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 30.0),
                  color: color,
                  border: Border.all(width: size * 1.0, color: color),
                ),
              ),
            ),
            Pinned.fromSize(
              bounds: Rect.fromLTWH(
                  size * -0.6, size * 6.6, size * 6.9, size * 1.3),
              size: Size(size * 13.6, size * 10.2),
              pinLeft: true,
              pinBottom: true,
              fixedWidth: true,
              fixedHeight: true,
              child: Transform.rotate(
                angle: 0.7854,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size * 30.0),
                    color: color,
                    border: Border.all(width: size * 1.0, color: color),
                  ),
                ),
              ),
            ),
            Pinned.fromSize(
              bounds: Rect.fromLTWH(
                  size * -0.6, size * 2.4, size * 6.9, size * 1.3),
              size: Size(size * 13.6, size * 10.2),
              pinLeft: true,
              pinTop: true,
              fixedWidth: true,
              fixedHeight: true,
              child: Transform.rotate(
                angle: -0.7854,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: color,
                    border: Border.all(width: size * 1.0, color: color),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
