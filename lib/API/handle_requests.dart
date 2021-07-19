import 'package:flutter/material.dart';

import 'baseAPI.dart';

<<<<<<< HEAD
bool alertShown = false;
=======
bool isDialogDisplayed = false;
>>>>>>> develop

// An async function that performs an HTTP request is passed here to be
// completed. That way, if an exception occurs, it is caught here.
Future<dynamic> handleRequest(BuildContext context, Future future) async {
  try {
    return await future;
  } catch (exception) {
    handleException(context, exception);
    return null;
  }
}

// Determines what kind of exception was thrown and displays the corresponding
// alert dialog. The boolean alertShown is used to make sure than only on alert
// is displayed at any given time.
Future<void> handleException(BuildContext context, Exception exception) async {
<<<<<<< HEAD
  if (!alertShown) {
    if (exception is NoInternetException) {
      alertShown = true;
      showDialog(
        context: context,
        builder: (context) => NoInternetAlert(),
      ).then((_) => alertShown = false);
    } else if (exception is ClientFailedException) {
      alertShown = true;
      showDialog(
        context: context,
        builder: (context) => ClientErrorAlert(),
      ).then((_) => alertShown = false);
    } else if (exception is ServerFailedException) {
      alertShown = true;
      showDialog(
        context: context,
        builder: (context) => ServerErrorAlert(),
      ).then((_) => alertShown = false);
    } else {
      alertShown = true;
      showDialog(
        context: context,
        builder: (context) => UnknownErrorAlert(),
      ).then((_) => alertShown = false);
=======
  if (!isDialogDisplayed) {
    if (exception is NoInternetException) {
      isDialogDisplayed = true;
      showDialog(
        context: context,
        builder: (context) => NoInternetAlert(),
      ).then((value) => isDialogDisplayed = false);
    } else if (exception is ClientFailedException) {
      isDialogDisplayed = true;
      showDialog(
        context: context,
        builder: (context) => ClientErrorAlert(),
      ).then((value) => isDialogDisplayed = false);
    } else if (exception is ServerFailedException) {
      isDialogDisplayed = true;
      showDialog(
        context: context,
        builder: (context) => ServerErrorAlert(),
      ).then((value) => isDialogDisplayed = false);
    } else {
      isDialogDisplayed = true;
      showDialog(
        context: context,
        builder: (context) => UnknownErrorAlert(),
      ).then((value) => isDialogDisplayed = false);
>>>>>>> develop
    }
  }
}

class ExceptionAlert extends StatelessWidget {
  const ExceptionAlert({@required this.child, Key key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: 280,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(40))),
      child: Center(
        child: child,
      ),
    );
  }
}

class NoInternetAlert extends StatelessWidget {
  const NoInternetAlert({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: ExceptionAlert(
        child: Text(
          "No internet",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class ClientErrorAlert extends StatelessWidget {
  const ClientErrorAlert({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Colors.transparent,
        content: ExceptionAlert(
            child: Container(
          height: 140,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "It looks like a client-side error has occurred. Would you like to report it?",
                    textAlign: TextAlign.center,
                  ),
                ),
                GestureDetector(
                  child: Container(
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.red[200],
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Center(
                        child: Text(
                      "Report error",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[200]),
                    )),
                  ),
                )
              ]),
        )));
  }
}

class ServerErrorAlert extends StatelessWidget {
  const ServerErrorAlert({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: ExceptionAlert(
        child: Text("Sorry, it looks like an error has occurred on the server.",
            textAlign: TextAlign.center),
      ),
    );
  }
}

class UnknownErrorAlert extends StatelessWidget {
  const UnknownErrorAlert({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: ExceptionAlert(
        child:
            Text("Sorry, an error has occurred.", textAlign: TextAlign.center),
      ),
    );
  }
}
