import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:test_flutter/widgets/generic_alert_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'widgets/account_app_bar.dart';
import 'widgets/input_field.dart';
import 'widgets/account_submit_button.dart';

import '../../globals.dart' as globals;
import '../home/home_screen.dart';
import '../../API/methods/users.dart';

firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  InputField emailInputField, passwordInputField;

  @override
  void initState() {
    super.initState();

    emailInputField = InputField(
      obscureText: false,
      hintText: "email",
    );
    passwordInputField = InputField(
      obscureText: true,
      hintText: "password",
    );
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardActivated = (MediaQuery.of(context).viewInsets.bottom != 0.0);

    // emailInputField.textEditingController.text = 'john@gmail.com';
    // passwordInputField.textEditingController.text = 'test12345';

    return Scaffold(
        appBar: AccountAppBar(height: .25 * globals.size.height),
        body: Padding(
          padding: EdgeInsets.only(
              top: .01 * globals.size.height, bottom: .1 * globals.size.height),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: double.infinity,
                child: Column(
                  children: [
                    InputFieldWidget(inputField: emailInputField),
                    InputFieldWidget(inputField: passwordInputField),
                    GestureDetector(
                        child: Container(
                            child: Text("Forgot password?",
                                style: TextStyle(color: Colors.grey[500]))),
                        onTap: () => _resetPassword())
                  ],
                ),
              ),
              if (!keyboardActivated)
                GestureDetector(
                    child: AccountSubmitButton(
                      buttonName: "Sign In",
                    ),
                    onTap: () => _signIn()),
            ],
          ),
        ));
  }

  Future<void> _signIn() async {
    // Signs into firebase account. If any errors, updates appropraite error
    // messages. If no errors, sets the global user the newly signed in user,
    // and pushes the user to the next page. If there are errors, updates the
    // state with the appropriate error messages.

    passwordInputField.errorText = "";
    emailInputField.errorText = "";

    try {
      if (!_areInputsValid()) return;

      firebase_auth.User firebaseUser = (await auth.signInWithEmailAndPassword(
        email: emailInputField.textEditingController.text,
        password: passwordInputField.textEditingController.text,
      ))
          .user;

      if ((await FirebaseMessaging.instance.getNotificationSettings())
              .authorizationStatus !=
          AuthorizationStatus.authorized)
        await FirebaseMessaging.instance.requestPermission();

      globals.user =
          await handleRequest(context, getUserFromUID(firebaseUser.uid));
      await handleRequest(context,
          updateDeviceToken(await FirebaseMessaging.instance.getToken()));

      await globals.accountRepository.setUid(uid: firebaseUser.uid);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Home(
                    pageLabel: PageLabel.friends,
                  )));
    } on firebase_auth.FirebaseAuthException catch (error) {
      _displayErrorMessages(error.code);
    }
  }

  Future<void> _resetPassword() async {
    // If the given email exists in firebase, sends a password reset email to
    // the user. Displays an alert dialog to confirm that the email has been
    // sent. If any errors occur, display appropraite error messages.

    passwordInputField.errorText = "";
    emailInputField.errorText = "";
    try {
      await auth.sendPasswordResetEmail(
          email: emailInputField.textEditingController.text);
      showDialog(
          context: context,
          builder: (context) => GenericAlertDialog(
              text:
                  "An email has been sent to you address that will allow you to reset your email"));
    } on firebase_auth.FirebaseAuthException catch (error) {
      _displayErrorMessages(error.code);
    }
  }

  bool _areInputsValid() {
    // Checks if inputs are empty.

    bool isEmpty = false;
    if (passwordInputField.textEditingController.text == "") {
      passwordInputField.errorText = "No input";
      isEmpty = true;
    }
    if (emailInputField.textEditingController.text == "") {
      emailInputField.errorText = "No input";
      isEmpty = true;
    }

    setState(() {});

    if (isEmpty) return false;

    return true;
  }

  void _displayErrorMessages(String errorCode) {
    // Goes through each possible error and displays the appropriate error
    // message.

    switch (errorCode) {
      case "wrong-password":
        passwordInputField.errorText = "Wrong password";
        break;
      case "missing-email":
        emailInputField.errorText = "No input";
        break;
      case "user-not-found":
        emailInputField.errorText =
            "There is no user associated with this email";
        break;
      case "invalid-email":
        emailInputField.errorText = "This email is not valid";
        break;
      case "too-many-requests":
        passwordInputField.errorText =
            "You have reached your attempt limit, please try again later";
        break;
      default:
        print(" [Firebase authentication error code]: $errorCode");
    }
    setState(() {});
  }
}
