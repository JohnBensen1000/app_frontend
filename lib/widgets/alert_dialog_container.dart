import 'package:flutter/material.dart';

import '../globals.dart' as globals;

class AlertDialogContainer extends StatelessWidget {
  // A generic alert dialog used for confirming certain actions. Displays a
  // question (given by the String dialogText). Displays two buttons, 'yes' and
  // 'no'. When either is pressed, the alert dialog is popped and a boolean is
  // returned (true if yes, false if no).

  const AlertDialogContainer({
    @required this.dialogText,
    Key key,
  }) : super(key: key);

  final String dialogText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: Container(
        child: Center(
          child: Container(
            height: .189 * globals.size.height,
            width: .821 * globals.size.width,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                    Radius.circular(.0296 * globals.size.height))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: EdgeInsets.only(
                        bottom: .0237 * globals.size.height,
                        left: .064 * globals.size.width,
                        right: .064 * globals.size.width),
                    child: Text(
                      dialogText,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: .0189 * globals.size.height),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: AlertDialogContainerButton(
                          color: Colors.red, text: 'Yes'),
                      onTap: () => Navigator.pop(context, true),
                    ),
                    Container(
                      width: .0518 * globals.size.width,
                    ),
                    GestureDetector(
                      child: AlertDialogContainerButton(
                          color: Colors.grey[200], text: 'No'),
                      onTap: () => Navigator.pop(context, false),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AlertDialogContainerButton extends StatelessWidget {
  // Stateless widget used for 'yes' and 'no' buttons in SettingsAlertDialog.
  const AlertDialogContainerButton({
    @required this.color,
    @required this.text,
    Key key,
  }) : super(key: key);

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: .244 * globals.size.width,
        height: .0427 * globals.size.height,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.all(Radius.circular(14))),
        child: Center(child: Text(text)));
  }
}
