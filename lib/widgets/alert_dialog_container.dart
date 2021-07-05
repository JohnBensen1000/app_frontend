import 'package:flutter/material.dart';

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
            height: 160,
            width: 320,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(25))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: EdgeInsets.only(bottom: 20, left: 25, right: 25),
                    child: Text(
                      dialogText,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
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
                      width: 20,
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
        width: 95,
        height: 36,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.all(Radius.circular(14))),
        child: Center(child: Text(text)));
  }
}
