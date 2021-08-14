import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../globals.dart' as globals;

class AccountSubmitButton extends StatelessWidget {
  AccountSubmitButton({@required this.buttonName});

  final String buttonName;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: .446 * globals.size.width,
      height: .0616 * globals.size.height,
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                buttonName,
                style: TextStyle(
                  fontFamily: 'Devanagari Sangam MN',
                  fontSize: .0415 * globals.size.height,
                  color: const Color(0xff000000),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(0.0, .061 * globals.size.height,
                .206 * globals.size.height, 0.0),
            size: Size(.206 * globals.size.height, .061 * globals.size.height),
            pinLeft: true,
            pinRight: true,
            pinBottom: true,
            fixedHeight: true,
            child: Stack(
              children: <Widget>[
                Pinned.fromSize(
                  bounds:
                      Rect.fromLTWH(0.0, 0.0, .206 * globals.size.height, 1.0),
                  size: Size(.206 * globals.size.height, 0.0),
                  pinLeft: true,
                  pinRight: true,
                  pinTop: true,
                  pinBottom: true,
                  child: SvgPicture.string(
                    _svg_hyabiz,
                    allowDrawingOutsideViewBox: true,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const String _svg_hyabiz =
    '<svg viewBox="13.5 328.5 174.0 1.0" ><path transform="translate(13.5, 328.5)" d="M 0 0 L 174 0" fill="none" stroke="#1de0e0" stroke-width="4" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
