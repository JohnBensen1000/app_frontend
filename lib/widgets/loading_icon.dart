import 'package:flutter/material.dart';
import 'dart:async';

import '../globals.dart' as globals;

class ProgressCircle extends StatelessWidget {
  ProgressCircle({this.color = Colors.black12});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          height: .1 * globals.size.width,
          width: .1 * globals.size.width,
          child: CircularProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(
              color,
            ),
            strokeWidth: 3,
          )),
    );
  }
}

class LoadingIcon extends StatelessWidget {
  const LoadingIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return AlertDialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(0),
        content: Stack(children: [
          Container(
            width: width,
            height: height,
          ),
          Center(
              child: StreamBuilder(
                  stream: LoadingIconTimer().stream,
                  builder: (context, snapshot) {
                    return CircularProgressIndicator(
                      strokeWidth: 2,
                      value: snapshot.data,
                    );
                  })),
        ]));
  }
}

class LoadingIconTimer {
  LoadingIconTimer() {
    Timer.periodic(Duration(milliseconds: 1), (_) {
      _progress >= 1 ? _progress = 0 : _progress += (4.0 / 6666.666666667);
      _controller.sink.add(_progress);
    });
  }

  double _progress = 0.0;
  StreamController<double> _controller = StreamController<double>();

  Stream<double> get stream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
