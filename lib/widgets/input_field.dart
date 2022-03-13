import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import '../globals.dart' as globals;

class InputField {
  // Object that contains the state of an individual InputFieldWidget. Has a
  // stream so that when the parent widget updates the text or the error text,
  // the InputFieldWidget also updates.

  final String hintText;
  final bool obscureText;

  bool allowTextUpdate;
  String _errorText;
  TextEditingController _textEditingController;

  final controller = StreamController<bool>.broadcast();
  Stream<bool> get stream => controller.stream;

  void dispose() {
    controller.close();
  }

  InputField({@required this.hintText, this.obscureText = false}) {
    allowTextUpdate = true;
    this._errorText = "";
    this._textEditingController = TextEditingController();
  }

  TextEditingController get textEditingController => _textEditingController;
  String get errorText => _errorText;
  String get text => _textEditingController.text;

  set errorText(String newErrorText) {
    _errorText = newErrorText;
    controller.sink.add(true);
  }

  set text(String newText) {
    if (allowTextUpdate) {
      _textEditingController.text = newText;
      controller.sink.add(true);
      allowTextUpdate = false;
    }
  }
}

class InputFieldWidget extends StatefulWidget {
  InputFieldWidget(
      {@required this.inputField, this.child, @required this.widthFraction});

  final InputField inputField;
  final Widget child;
  final double widthFraction;

  @override
  State<InputFieldWidget> createState() => _InputFieldWidgetState();
}

class _InputFieldWidgetState extends State<InputFieldWidget> {
  @override
  void initState() {
    widget.inputField.stream.listen((event) {
      widget.inputField.allowTextUpdate = true;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      if (widget.child == null)
        TextInputWidget(
            textEditingController: widget.inputField.textEditingController,
            obscureText: widget.inputField.obscureText,
            widthFraction: widget.widthFraction,
            hintText: widget.inputField.hintText)
      else
        TextFormField(
          // cursorHeight: 0,
          // cursorWidth: 0,
          cursorHeight: .06 * globals.size.height,
          textAlignVertical: TextAlignVertical.center,
          controller: widget.inputField.textEditingController,
          textAlign: TextAlign.center,
          obscureText: widget.inputField.obscureText,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "------",
            hintStyle: TextStyle(
              letterSpacing: .016 * globals.size.height,
              fontFamily: 'Devanagari Sangam MN',
              fontSize: .07 * globals.size.height,
              color: const Color(0xc1000000),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          style: TextStyle(
            letterSpacing: .016 * globals.size.height,
            fontFamily: 'Devanagari Sangam MN',
            fontSize: .07 * globals.size.height,
            color: const Color(0xc1000000),
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      Container(
          padding: EdgeInsets.only(top: .01 * globals.size.height),
          child: Text(
            widget.inputField.errorText,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colors.red, fontSize: .018 * globals.size.height),
          ))
    ]);
  }
}

class TextInputWidget extends StatelessWidget {
  TextInputWidget(
      {@required this.textEditingController,
      @required this.hintText,
      this.obscureText = false,
      this.widthFraction = .789,
      this.onChange});

  final TextEditingController textEditingController;
  final bool obscureText;
  final String hintText;
  final double widthFraction;
  final Function onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: widthFraction * globals.size.width,
            height: .0545 * globals.size.height,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1.0, color: const Color(0xff707070)),
              ),
            ),
            child: Transform.translate(
              offset: Offset(0, .015 * globals.size.height),
              child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: textEditingController,
                  textAlign: TextAlign.left,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                        fontFamily: 'Devanagari Sangam MN',
                        color: Colors.grey[300],
                        fontSize: .03 * globals.size.height),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontFamily: 'Devanagari Sangam MN',
                    fontSize: .027 * globals.size.height,
                    color: const Color(0xc1000000),
                  ),
                  onChanged: (text) {
                    if (onChange != null) onChange(text);
                  }),
            ),
          ),
        ]);
  }
}
