import 'package:flutter/material.dart';

class ReactiveButton extends StatefulWidget {
  ReactiveButton(
      {this.onTap,
      this.onLongPress,
      this.onLongPressEnd,
      @required this.child});

  final Function onTap;
  final Function onLongPress;
  final Function onLongPressEnd;
  final Widget child;

  @override
  State<ReactiveButton> createState() => _ReactiveButtonState();
}

class _ReactiveButtonState extends State<ReactiveButton> {
  double scaler = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Transform.scale(scale: scaler, child: widget.child),
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) async {
        await _onTapUp();
        widget.onTap();
      },
      onLongPress: () async => widget.onLongPress(),
      onLongPressEnd: (_) async {
        await _onTapUp();
        widget.onLongPressEnd();
      },
    );
  }

  Future<void> _onTapDown() async {
    setState(() {
      scaler = .95;
    });
  }

  Future<void> _onTapUp() async {
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      scaler = 1.0;
    });
  }
}
