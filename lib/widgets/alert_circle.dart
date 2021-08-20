import 'package:flutter/material.dart';

import '../globals.dart' as globals;

class AlertCircle extends StatelessWidget {
  AlertCircle({@required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: globals.userRepository.get(globals.uid),
        builder: (context, snapshot) => Container(
              height: diameter,
              width: diameter,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(globals.size.height),
                  color: snapshot.hasData
                      ? snapshot.data.profileColor
                      : Colors.transparent),
            ));

    ;
  }
}
