import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountSubmitButton extends StatelessWidget {
  AccountSubmitButton({@required this.buttonName});

  final String buttonName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 174.0,
      height: 52.0,
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                buttonName,
                style: TextStyle(
                  fontFamily: 'Devanagari Sangam MN',
                  fontSize: 35,
                  color: const Color(0xff000000),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(0.0, 51.5, 174.0, 0.0),
            size: Size(174.0, 51.5),
            pinLeft: true,
            pinRight: true,
            pinBottom: true,
            fixedHeight: true,
            child: Stack(
              children: <Widget>[
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(0.0, 0.0, 174.0, 1.0),
                  size: Size(174.0, 0.0),
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
