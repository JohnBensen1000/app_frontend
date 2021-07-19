import 'package:flutter/material.dart';

class InputField {
  // Object that contains the state of an individual InputFieldWidget.
  final String hintText;
  final bool obscureText;

  String errorText;
  TextEditingController textEditingController;

  InputField({@required this.hintText, this.obscureText = false}) {
    this.errorText = "";
    this.textEditingController = TextEditingController();
  }
}

class InputFieldWidget extends StatelessWidget {
  InputFieldWidget({@required this.inputField});

  final InputField inputField;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 308.0,
          height: 46.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23.0),
            color: const Color(0xffffffff),
            border: Border.all(width: 1.0, color: const Color(0xff707070)),
          ),
          child: Transform.translate(
            // offset to center text
            offset: Offset(0, 5),
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              controller: inputField.textEditingController,
              textAlign: TextAlign.center,
              obscureText: inputField.obscureText,
              decoration: InputDecoration(
                hintText: inputField.hintText,
                border: InputBorder.none,
                errorStyle: TextStyle(fontSize: 12),
              ),
              style: TextStyle(
                fontFamily: 'Devanagari Sangam MN',
                fontSize: 20,
                color: const Color(0xc1000000),
              ),
            ),
          ),
        ),
        Container(
            child: Text(
          inputField.errorText,
          style: TextStyle(color: Colors.red, fontSize: 12.0),
        ))
      ],
    );
  }
}
