import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import '../../API/methods/users.dart';
import '../../API/baseAPI.dart';
import '../../widgets/generic_alert_dialog.dart';

import 'widgets/input_field.dart';
import 'widgets/account_input_page.dart';
import 'set_account_info.dart';
import '../home/home_page.dart';

firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

class SignUpEmail extends StatefulWidget {
  /*
    Allows users to sign-up/sign-in using their email. This page asks the user
    to enter their email account. If the email is not in a valid format, 
    displays the appropriate error message. Checks if the email is associated
    with an existing account before sending the user to the next page. 
   */
  @override
  _SignUpEmailState createState() => _SignUpEmailState();
}

class _SignUpEmailState extends State<SignUpEmail> {
  InputField _inputField;

  @override
  void initState() {
    _inputField = InputField(hintText: "email");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AccountInputPage(
        child: InputFieldWidget(inputField: _inputField), onTap: _submitEmail);
  }

  Future<void> _submitEmail() async {
    bool isEmailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_inputField.textEditingController.text);

    if (!isEmailValid) {
      setState(() {
        _inputField.errorText = "not a valid email";
      });
      return;
    }

    bool isEmailAvailable = (await auth
            .fetchSignInMethodsForEmail(_inputField.textEditingController.text))
        .isEmpty;

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignUpPassword(
                email: _inputField.textEditingController.text,
                isNewAccount: isEmailAvailable)));
  }
}

class SignUpPassword extends StatefulWidget {
  /*
    If the user is signing up, then the user is asked to create a password. If 
    the user is signing in, asks the user to submit their password. If the user
    is signing up, or if the user is signing in but hasn't completed setting up
    their account, then sends the user to the SetAccountInfo page. If the user
    is signing in and has already set up their account, then sends the user to
    the home page. If the user is signing in, allows the user to reset their
    password. 
   */
  final String email;
  final bool isNewAccount;

  SignUpPassword({@required this.email, @required this.isNewAccount});

  @override
  _SignUpPasswordState createState() => _SignUpPasswordState();
}

class _SignUpPasswordState extends State<SignUpPassword> {
  InputField _inputField;
  bool _didAttemptToSubmit;

  @override
  void initState() {
    _didAttemptToSubmit = false;
    _inputField = InputField(hintText: "password", obscureText: true);
    _inputField.textEditingController.addListener(() => _inputTextListener());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AccountInputPage(
        child: Column(children: [
          if (widget.isNewAccount == true)
            Container(
                child: Text("Please select a password",
                    style: TextStyle(fontSize: 24))),
          InputFieldWidget(
            inputField: _inputField,
          ),
          if (widget.isNewAccount == false)
            GestureDetector(
                child: Container(
                    child: Text("Forgot password?",
                        style: TextStyle(color: Colors.grey[500]))),
                onTap: () => _resetPassword())
        ]),
        onTap: _enterAccount);
  }

  Future<void> _inputTextListener() async {
    if (_didAttemptToSubmit) {
      _inputField.textEditingController.text = "";
      _inputField.errorText = "";
      setState(() {});
      _didAttemptToSubmit = false;
    }
  }

  Future<void> _enterAccount() async {
    _didAttemptToSubmit = true;
    if (widget.isNewAccount) {
      await _signUp();
    } else {
      await _signIn();
    }
  }

  Future<void> _signUp() async {
    // If the given email address is not associated with a firebase account,
    // then creates an account in firebase and sends the user to set their
    // account info.
    String email = widget.email;
    String password = _inputField.textEditingController.text;
    try {
      firebase_auth.User firebaseUser =
          (await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ))
              .user;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SetAccountInfoPage(uid: firebaseUser.uid)));
    } on firebase_auth.FirebaseAuthException catch (error) {
      _displayErrorMessages(error.code);
    }
  }

  Future<void> _signIn() async {
    // If the given email address is associated with a firebase account, checks
    // the given password to see if it's the correct password. if it is, sends
    // the user to the next page (which page that is is determined by
    // _sendToNextPage()).
    String email = widget.email;
    String password = _inputField.textEditingController.text;
    firebase_auth.User firebaseUser;
    try {
      firebaseUser = (await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user;
      _sendToNextPage(firebaseUser.uid);
    } on firebase_auth.FirebaseAuthException catch (error) {
      _displayErrorMessages(error.code);
    }
  }

  Future<void> _sendToNextPage(String uid) async {
    // THIS IS A HACK. To check if the user has an account set up in the
    // database, checks if an error occurs when looking for this account. If
    // ServerFailedException occurs, then the user's account doesn't exist and
    // the user is asked to set up their account.
    try {
      await getUserFromUID(uid);
      await globals.accountRepository.signIn(uid);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } on ServerFailedException catch (e) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SetAccountInfoPage(uid: uid)));
    }
  }

  Future<void> _resetPassword() async {
    // If the given email exists in firebase, sends a password reset email to
    // the user. Displays an alert dialog to confirm that the email has been
    // sent. If any errors occur, display appropraite error messages.

    _inputField.errorText = "";
    try {
      await auth.sendPasswordResetEmail(email: widget.email);
      showDialog(
          context: context,
          builder: (context) => GenericAlertDialog(
              text:
                  "An email has been sent to you address that will allow you to reset your email"));
    } on firebase_auth.FirebaseAuthException catch (error) {
      _displayErrorMessages(error.code);
    }
  }

  void _displayErrorMessages(String errorCode) {
    // Goes through each possible error and displays the appropriate error
    // message.

    switch (errorCode) {
      case "wrong-password":
        _inputField.errorText = "wrong password";
        break;
      case "weak-password":
        _inputField.errorText = "password must have at least 6 characters";
        break;
      case "too-many-requests":
        _inputField.errorText =
            "too many password attempts, please try again later";
        break;

      default:
        print(" [Firebase authentication error code]: $errorCode");
    }
    setState(() {});
  }
}
