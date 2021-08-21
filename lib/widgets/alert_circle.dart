import 'dart:async';

import 'package:flutter/material.dart';

import '../globals.dart' as globals;

class AlertCircle extends StatelessWidget {
  AlertCircle({@required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: globals.userRepository.get(globals.uid),
        builder: (context, futureSnapshot) => StreamBuilder(
            stream: globals.userRepository.stream,
            builder: (context, streamSnapshot) => Container(
                  height: diameter,
                  width: diameter,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(globals.size.height),
                      color: futureSnapshot.hasData
                          ? streamSnapshot.hasData
                              ? streamSnapshot.data.profileColor
                              : futureSnapshot.data.profileColor
                          : Colors.transparent),
                )));

    ;
  }
}
