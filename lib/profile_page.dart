import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adobe_xd/pinned.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'user_info.dart';
import 'backend_connect.dart';

final backendConnection = new BackendConnection();

class ProfilePage extends StatefulWidget {
  ProfilePage({this.user});

  final User user;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(height: 80, width: double.infinity),
        Container(
          width: 148.0,
          height: 148.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
            // image: DecorationImage(
            //   image: const AssetImage(''),
            //   fit: BoxFit.cover,
            // ),
            border: Border.all(width: 3.0, color: const Color(0xff22a2ff)),
          ),
        ),
        Container(
          child: Text(
            '${widget.user.username}',
            style: TextStyle(
              fontFamily: 'Helvetica Neue',
              fontSize: 25,
              color: const Color(0xff000000),
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          child: Text(
            '${widget.user.userID}',
            style: TextStyle(
              fontFamily: 'Helvetica Neue',
              fontSize: 12,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          height: 20,
          child: SvgPicture.string(
            _svg_jmyh3o,
            allowDrawingOutsideViewBox: true,
          ),
        ),
        Container(
          width: 125.0,
          height: 31.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: const Color(0xffffffff),
            border: Border.all(width: 1.0, color: const Color(0xff707070)),
          ),
          child: Center(
            child: Text(
              'Follow',
              style: TextStyle(
                fontFamily: 'Helvetica Neue',
                fontSize: 25,
                color: const Color(0xff000000),
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(20),
          child: Container(
            // width: 342.0,
            height: 201.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                // image: DecorationImage(
                //   image: const AssetImage(''),
                //   fit: BoxFit.cover,
                // ),
                border: Border.all(width: 1.0, color: const Color(0xff707070))),
          ),
        ),
        Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              child: Container(
                  height: 300,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    // image: DecorationImage(
                    //   image: const AssetImage(''),
                    //   fit: BoxFit.cover,
                    // ),
                    border:
                        Border.all(width: 1.0, color: const Color(0xff707070)),
                  )),
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: Container(
                  height: 300,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    // image: DecorationImage(
                    //   image: const AssetImage(''),
                    //   fit: BoxFit.cover,
                    // ),
                    border:
                        Border.all(width: 1.0, color: const Color(0xff707070)),
                  )),
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: Container(
                  height: 300,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    // image: DecorationImage(
                    //   image: const AssetImage(''),
                    //   fit: BoxFit.cover,
                    // ),
                    border:
                        Border.all(width: 1.0, color: const Color(0xff707070)),
                  )),
            ),
          ],
        ),

        // Transform.translate(
        //   offset: Offset(13.0, 602.0),
        //   child: SizedBox(
        //     width: 349.0,
        //     height: 136.0,
        //     child: Stack(
        //       children: <Widget>[
        //         Pinned.fromSize(
        //           bounds: Rect.fromLTWH(0.0, 0.0, 107.0, 136.0),
        //           size: Size(349.0, 136.0),
        //           pinLeft: true,
        //           pinTop: true,
        //           pinBottom: true,
        //           fixedWidth: true,
        //           child: Stack(
        //             children: <Widget>[
        //               Pinned.fromSize(
        //                 bounds: Rect.fromLTWH(0.0, 0.0, 107.0, 136.0),
        //                 size: Size(107.0, 136.0),
        //                 pinLeft: true,
        //                 pinRight: true,
        //                 pinTop: true,
        //                 pinBottom: true,
        //                 child:
        //                     // Adobe XD layer: 'e36749e2bd53a0c8e5d…' (shape)
        //                     Container(
        //                   decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(15.0),
        //                     image: DecorationImage(
        //                       image: const AssetImage(''),
        //                       fit: BoxFit.cover,
        //                     ),
        //                     border: Border.all(
        //                         width: 1.0, color: const Color(0xff707070)),
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         Pinned.fromSize(
        //           bounds: Rect.fromLTWH(121.0, 0.0, 107.0, 136.0),
        //           size: Size(349.0, 136.0),
        //           pinTop: true,
        //           pinBottom: true,
        //           fixedWidth: true,
        //           child: Stack(
        //             children: <Widget>[
        //               Pinned.fromSize(
        //                 bounds: Rect.fromLTWH(0.0, 0.0, 107.0, 136.0),
        //                 size: Size(107.0, 136.0),
        //                 pinLeft: true,
        //                 pinRight: true,
        //                 pinTop: true,
        //                 pinBottom: true,
        //                 child:
        //                     // Adobe XD layer: '56683dd4d77767d0c0c…' (shape)
        //                     Container(
        //                   decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(15.0),
        //                     image: DecorationImage(
        //                       image: const AssetImage(''),
        //                       fit: BoxFit.cover,
        //                     ),
        //                     border: Border.all(
        //                         width: 1.0, color: const Color(0xff707070)),
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         Pinned.fromSize(
        //           bounds: Rect.fromLTWH(242.0, 0.0, 107.0, 136.0),
        //           size: Size(349.0, 136.0),
        //           pinRight: true,
        //           pinTop: true,
        //           pinBottom: true,
        //           fixedWidth: true,
        //           child: Stack(
        //             children: <Widget>[
        //               Pinned.fromSize(
        //                 bounds: Rect.fromLTWH(0.0, 0.0, 107.0, 136.0),
        //                 size: Size(107.0, 136.0),
        //                 pinLeft: true,
        //                 pinRight: true,
        //                 pinTop: true,
        //                 pinBottom: true,
        //                 child:
        //                     // Adobe XD layer: '1a5e51394094cc0f1e4…' (shape)
        //                     Container(
        //                   decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(7.0),
        //                     image: DecorationImage(
        //                       image: const AssetImage(''),
        //                       fit: BoxFit.cover,
        //                     ),
        //                     border: Border.all(
        //                         width: 1.0, color: const Color(0xff707070)),
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        // Transform.translate(
        //   offset: Offset(13.0, 758.0),
        //   child: SizedBox(
        //     width: 349.0,
        //     height: 136.0,
        //     child: Stack(
        //       children: <Widget>[
        //         Pinned.fromSize(
        //           bounds: Rect.fromLTWH(0.0, 0.0, 107.0, 136.0),
        //           size: Size(349.0, 136.0),
        //           pinLeft: true,
        //           pinTop: true,
        //           pinBottom: true,
        //           fixedWidth: true,
        //           child: Stack(
        //             children: <Widget>[
        //               Pinned.fromSize(
        //                 bounds: Rect.fromLTWH(0.0, 0.0, 107.0, 136.0),
        //                 size: Size(107.0, 136.0),
        //                 pinLeft: true,
        //                 pinRight: true,
        //                 pinTop: true,
        //                 pinBottom: true,
        //                 child:
        //                     // Adobe XD layer: '6cbba7cea9f72ad8cdb…' (shape)
        //                     Container(
        //                   decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(15.0),
        //                     image: DecorationImage(
        //                       image: const AssetImage(''),
        //                       fit: BoxFit.cover,
        //                     ),
        //                     border: Border.all(
        //                         width: 1.0, color: const Color(0xff707070)),
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         Pinned.fromSize(
        //           bounds: Rect.fromLTWH(121.0, 0.0, 107.0, 136.0),
        //           size: Size(349.0, 136.0),
        //           pinTop: true,
        //           pinBottom: true,
        //           fixedWidth: true,
        //           child: Stack(
        //             children: <Widget>[
        //               Pinned.fromSize(
        //                 bounds: Rect.fromLTWH(0.0, 0.0, 107.0, 136.0),
        //                 size: Size(107.0, 136.0),
        //                 pinLeft: true,
        //                 pinRight: true,
        //                 pinTop: true,
        //                 pinBottom: true,
        //                 child:
        //                     // Adobe XD layer: '1a5e51394094cc0f1e4…' (shape)
        //                     Container(
        //                   decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(15.0),
        //                     image: DecorationImage(
        //                       image: const AssetImage(''),
        //                       fit: BoxFit.cover,
        //                     ),
        //                     border: Border.all(
        //                         width: 1.0, color: const Color(0xff707070)),
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         Pinned.fromSize(
        //           bounds: Rect.fromLTWH(242.0, 0.0, 107.0, 136.0),
        //           size: Size(349.0, 136.0),
        //           pinRight: true,
        //           pinTop: true,
        //           pinBottom: true,
        //           fixedWidth: true,
        //           child: Stack(
        //             children: <Widget>[
        //               Pinned.fromSize(
        //                 bounds: Rect.fromLTWH(0.0, 0.0, 107.0, 136.0),
        //                 size: Size(107.0, 136.0),
        //                 pinLeft: true,
        //                 pinRight: true,
        //                 pinTop: true,
        //                 pinBottom: true,
        //                 child:
        //                     // Adobe XD layer: 'b201619b73bfd7087d2…' (shape)
        //                     Container(
        //                   decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(7.0),
        //                     image: DecorationImage(
        //                       image: const AssetImage(''),
        //                       fit: BoxFit.cover,
        //                     ),
        //                     border: Border.all(
        //                         width: 1.0, color: const Color(0xff707070)),
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    ));
  }
}

const String _svg_cdsk62 =
    '<svg viewBox="289.0 36.0 57.0 11.0" ><path transform="translate(289.0, 36.0)" d="M 6.397959232330322 0 L 50.60204315185547 0 C 54.13554000854492 0 57.00000381469727 2.462433815002441 57.00000381469727 5.5 C 57.00000381469727 8.537566184997559 54.13554000854492 11 50.60204315185547 11 L 6.397959232330322 11 C 2.864464044570923 11 0 8.537566184997559 0 5.5 C 0 2.462433815002441 2.864464044570923 0 6.397959232330322 0 Z" fill="#22a2ff" stroke="#22a2ff" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_jmyh3o =
    '<svg viewBox="119.5 286.0 136.0 1.0" ><path transform="translate(119.5, 286.0)" d="M 0 0 L 136 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
