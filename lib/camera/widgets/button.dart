import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    Key key,
    @required String buttonName,
    @required Color backgroundColor,
  })  : _buttonName = buttonName,
        _backgroundColor = backgroundColor,
        super(key: key);

  final String _buttonName;
  final Color _backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100,
        height: 30,
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: _backgroundColor,
        ),
        child: Transform.translate(
          offset: Offset(0, 7),
          child: Text(_buttonName, textAlign: TextAlign.center),
        ));
  }
}
