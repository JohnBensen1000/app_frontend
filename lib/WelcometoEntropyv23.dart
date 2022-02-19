import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';

import 'globals.dart' as globals;

class WelcometoEntropyv23 extends StatelessWidget {
  double height;
  double width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: const Color(0xffffffff),
        body: Stack(children: <Widget>[
          _circleWidget(-.19, .9, const Color(0x2cffadbf)),
          _circleWidget(-.01, .85, const Color(0x2c1365d1)),
          _circleWidget(.01, .94, const Color(0x2c00f8fe)),
          _circleWidget(.12, .89, const Color(0x2cffc900)),
          _circleWidget(.27, .92, const Color(0x2cf7000e)),
          _circleWidget(.21, .84, const Color(0x2cff4800)),
          _circleWidget(.43, .90, const Color(0x2c1365d1)),
          _circleWidget(.37, .83, const Color(0x2cffadbf)),
          _circleWidget(.54, .93, const Color(0x2c00f8fe)),
          _circleWidget(.51, .84, const Color(0x2cf7000e)),
          _circleWidget(.65, .91, const Color(0x2cffc900)),
          _circleWidget(.79, .84, const Color(0x2c1365d1)),
          _circleWidget(.81, .91, const Color(0x2cffadbf)),
        ]));
  }

  Widget _circleWidget(double x, double y, Color color) {
    return Transform.translate(
      offset: Offset(x * width, y * height),
      child: Container(
        width: 101,
        height: 101,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
          color: color.withOpacity(.15),
          border: Border.all(
              width: 1.0, color: const Color(0x2c707070).withOpacity(.1)),
        ),
      ),
    );
  }

  //     Pinned.fromSize(
  //       bounds: Rect.fromLTWH(428.0, 17.0, 100.0, 101.0),
  //       size: Size(555.0, 190.0),
  //       pinRight: true,
  //       pinTop: true,
  //       fixedWidth: true,
  //       fixedHeight: true,
  //       child: Container(
  //         decoration: BoxDecoration(
  //           borderRadius:
  //               BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
  //           color: const Color(0x2c1365d1),
  //           border: Border.all(width: 1.0, color: const Color(0x2c707070)),
  //         ),
  //       ),
  //     ),
  //     Pinned.fromSize(
  //       bounds: Rect.fromLTWH(455.0, 89.0, 100.0, 101.0),
  //       size: Size(555.0, 190.0),
  //       pinRight: true,
  //       pinBottom: true,
  //       fixedWidth: true,
  //       fixedHeight: true,
  //       child: Container(
  //         decoration: BoxDecoration(
  //           borderRadius:
  //               BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
  //           color: const Color(0x2cffadbf),
  //           border: Border.all(width: 1.0, color: const Color(0x2c707070)),
  //         ),
  //       ),
  //     ),
  //   ],
  // ),

  //  Stack(
  //   children: <Widget>[
  // Transform.translate(
  //   offset: Offset(153.0, 868.0),
  //   child: Container(
  //     width: 11.0,
  //     height: 11.0,
  //     decoration: BoxDecoration(
  //       borderRadius:
  //           BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
  //       color: const Color(0xff727273),
  //       border: Border.all(width: 1.0, color: const Color(0xff727273)),
  //     ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(167.0, 868.0),
  //   child: Container(
  //     width: 11.0,
  //     height: 11.0,
  //     decoration: BoxDecoration(
  //       borderRadius:
  //           BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
  //       color: const Color(0xffffffff),
  //       border: Border.all(width: 1.0, color: const Color(0xff727272)),
  //     ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(181.0, 868.0),
  //   child: Container(
  //     width: 11.0,
  //     height: 11.0,
  //     decoration: BoxDecoration(
  //       borderRadius:
  //           BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
  //       color: const Color(0xffffffff),
  //       border: Border.all(width: 1.0, color: const Color(0xff727272)),
  //     ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(195.0, 868.0),
  //   child: Container(
  //     width: 11.0,
  //     height: 11.0,
  //     decoration: BoxDecoration(
  //       borderRadius:
  //           BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
  //       color: const Color(0xffffffff),
  //       border: Border.all(width: 1.0, color: const Color(0xff727272)),
  //     ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(209.0, 868.0),
  //   child: Container(
  //     width: 11.0,
  //     height: 11.0,
  //     decoration: BoxDecoration(
  //       borderRadius:
  //           BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
  //       color: const Color(0xffffffff),
  //       border: Border.all(width: 1.0, color: const Color(0xff727272)),
  //     ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(223.0, 868.0),
  //   child: Container(
  //     width: 11.0,
  //     height: 11.0,
  //     decoration: BoxDecoration(
  //       borderRadius:
  //           BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
  //       color: const Color(0xffffffff),
  //       border: Border.all(width: 1.0, color: const Color(0xff727272)),
  //     ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(237.0, 868.0),
  //   child: Container(
  //     width: 11.0,
  //     height: 11.0,
  //     decoration: BoxDecoration(
  //       borderRadius:
  //           BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
  //       color: const Color(0xffffffff),
  //       border: Border.all(width: 1.0, color: const Color(0xff727272)),
  //     ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(251.0, 868.0),
  //   child: Container(
  //     width: 11.0,
  //     height: 11.0,
  //     decoration: BoxDecoration(
  //       borderRadius:
  //           BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
  //       color: const Color(0xffffffff),
  //       border: Border.all(width: 1.0, color: const Color(0xff727272)),
  //     ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(265.0, 868.0),
  //   child: Container(
  //     width: 11.0,
  //     height: 11.0,
  //     decoration: BoxDecoration(
  //       borderRadius:
  //           BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
  //       color: const Color(0xffffffff),
  //       border: Border.all(width: 1.0, color: const Color(0xff727272)),
  //     ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(14.0, 18.0),
  //   child: Text.rich(
  //     TextSpan(
  //       style: TextStyle(
  //         fontFamily: 'Helvetica Neue',
  //         fontSize: 50,
  //         color: const Color(0xff000000),
  //       ),
  //       children: [
  //         TextSpan(
  //           text: 'Welcome to\n',
  //         ),
  //         TextSpan(
  //           text: 'Entropy\n',
  //           style: TextStyle(
  //             fontWeight: FontWeight.w700,
  //           ),
  //         ),
  //         TextSpan(
  //           text: 'Let’s get you\nStarted. ',
  //         ),
  //       ],
  //     ),
  //     textAlign: TextAlign.left,
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(37.0, 420.0),
  //   child: Container(
  //     width: 354.0,
  //     height: 47.0,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(21.0),
  //       color: const Color(0xffffffff),
  //       border: Border.all(width: 1.0, color: const Color(0xff707070)),
  //     ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(110.0, 426.0),
  //   child: Text(
  //     'Sign in with Phone',
  //     style: TextStyle(
  //       fontFamily: 'PingFang HK',
  //       fontSize: 25,
  //       color: const Color(0xff727272),
  //       fontWeight: FontWeight.w100,
  //     ),
  //     textAlign: TextAlign.left,
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(37.0, 347.0),
  //   child: Container(
  //     width: 354.0,
  //     height: 47.0,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(21.0),
  //       color: const Color(0xffffffff),
  //       border: Border.all(width: 1.0, color: const Color(0xff707070)),
  //     ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(114.0, 353.0),
  //   child: Text(
  //     'Sign in with Email',
  //     style: TextStyle(
  //       fontFamily: 'PingFang HK',
  //       fontSize: 25,
  //       color: const Color(0xff727272),
  //       fontWeight: FontWeight.w100,
  //     ),
  //     textAlign: TextAlign.left,
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(37.0, 551.0),
  //   child: SizedBox(
  //     width: 354.0,
  //     height: 47.0,
  //     child: Stack(
  //       children: <Widget>[
  //         Pinned.fromSize(
  //           bounds: Rect.fromLTWH(0.0, 0.0, 354.0, 47.0),
  //           size: Size(354.0, 47.0),
  //           pinLeft: true,
  //           pinRight: true,
  //           pinTop: true,
  //           pinBottom: true,
  //           child: Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(21.0),
  //               color: const Color(0xffffffff),
  //               border: Border.all(
  //                   width: 1.0, color: const Color(0xff707070)),
  //             ),
  //           ),
  //         ),
  //         Pinned.fromSize(
  //           bounds: Rect.fromLTWH(72.0, 6.0, 210.0, 36.0),
  //           size: Size(354.0, 47.0),
  //           pinTop: true,
  //           pinBottom: true,
  //           fixedWidth: true,
  //           child: Text(
  //             'Sign in with Apple ',
  //             style: TextStyle(
  //               fontFamily: 'PingFang HK',
  //               fontSize: 25,
  //               color: const Color(0xff727272),
  //               fontWeight: FontWeight.w100,
  //             ),
  //             textAlign: TextAlign.left,
  //           ),
  //         ),
  //       ],
  //     ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(37.0, 486.0),
  //   child: SizedBox(
  //     width: 354.0,
  //     height: 47.0,
  //     child: Stack(
  //       children: <Widget>[
  //         Pinned.fromSize(
  //           bounds: Rect.fromLTWH(0.0, 0.0, 354.0, 47.0),
  //           size: Size(354.0, 47.0),
  //           pinLeft: true,
  //           pinRight: true,
  //           pinTop: true,
  //           pinBottom: true,
  //           child: Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(21.0),
  //               color: const Color(0xffffffff),
  //               border: Border.all(
  //                   width: 1.0, color: const Color(0xff707070)),
  //             ),
  //           ),
  //         ),
  //         Pinned.fromSize(
  //           bounds: Rect.fromLTWH(68.0, 6.0, 219.0, 36.0),
  //           size: Size(354.0, 47.0),
  //           pinTop: true,
  //           pinBottom: true,
  //           fixedWidth: true,
  //           child: Text(
  //             'Sign in with Google',
  //             style: TextStyle(
  //               fontFamily: 'PingFang HK',
  //               fontSize: 25,
  //               color: const Color(0xff727272),
  //               fontWeight: FontWeight.w100,
  //             ),
  //             textAlign: TextAlign.left,
  //           ),
  //         ),
  //       ],
  //     ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(66.0, 563.0),
  //   child:
  //       // Adobe XD layer: 'Apple-logo-black-an…' (shape)
  //       Container(
  //     width: 20.0,
  //     height: 23.0,
  //     decoration: BoxDecoration(
  //         // image: DecorationImage(
  //         //   image: const AssetImage(''),
  //         //   fit: BoxFit.fill,
  //         //   colorFilter: new ColorFilter.mode(
  //         //       Colors.black.withOpacity(0.75), BlendMode.dstIn),
  //         // ),
  //         ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(58.0, 492.0),
  //   child:
  //       // Adobe XD layer: 'google-logo-png-web…' (shape)
  //       Container(
  //     width: 35.0,
  //     height: 35.0,
  //     decoration: BoxDecoration(
  //         // image: DecorationImage(
  //         //   image: const AssetImage(''),
  //         //   fit: BoxFit.fill,
  //         // ),
  //         ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(51.0, 357.0),
  //   child:
  //       // Adobe XD layer: 'Unknown' (shape)
  //       Container(
  //     width: 42.0,
  //     height: 27.0,
  //     decoration: BoxDecoration(
  //         // image: DecorationImage(
  //         //   image: const AssetImage(''),
  //         //   fit: BoxFit.fill,
  //         // ),
  //         ),
  //   ),
  // ),
  // Transform.translate(
  //   offset: Offset(59.0, 426.0),
  //   child:
  //       // Adobe XD layer: 'Unknown-1' (shape)
  //       Container(
  //     width: 27.0,
  //     height: 36.0,
  //     decoration: BoxDecoration(
  //         // image: DecorationImage(
  //         //   image: const AssetImage(''),
  //         //   fit: BoxFit.fill,
  //         // ),
  //         ),
  //   ),
  // ),
  // ],
  // );

}
