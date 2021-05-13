import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/home_screen.dart';

import '../backend_connect.dart';
import 'widgets/account_app_bar.dart';
import 'widgets/input_field.dart';
import 'widgets/account_submit_button.dart';

final serverAPI = new ServerAPI();
FirebaseAuth auth = FirebaseAuth.instance;

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

    emailInputField.textEditingController.text = "john@gmail.com";
    passwordInputField.textEditingController.text = "test12345";
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardActivated = (MediaQuery.of(context).viewInsets.bottom != 0.0);

    return Scaffold(
        appBar: AccountAppBar(
          height: 200,
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 80),
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
                  ],
                ),
              ),
              if (!keyboardActivated)
                FlatButton(
                    child: AccountSubmitButton(
                      buttonName: "Sign In",
                    ),
                    onPressed: () async {
                      if (await signIn()) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                      pageLabel: PageLabel.friends,
                                    )));
                      } else {
                        setState(() {});
                      }
                    }),
            ],
          ),
        ));
  }

  Future<bool> signIn() async {
    // Signs into firebase account. If any errors, updates appropraite error
    // messages. Returns true if successfully authenticated with firebase and
    // backend, false otherwise.

    passwordInputField.errorText = "";
    emailInputField.errorText = "";

    try {
      if (checkInputs()) return false;

      final FirebaseUser firebaseUser = (await auth.signInWithEmailAndPassword(
        email: emailInputField.textEditingController.text,
        password: passwordInputField.textEditingController.text,
      ))
          .user;
      bool authenticated = await authenticateUserWithBackend(
          (await firebaseUser.getIdToken()).token);
      return authenticated;
    } catch (error) {
      switch (error.code) {
        case "ERROR_WRONG_PASSWORD":
          passwordInputField.errorText = "This password is incorrected";
          break;
        case "ERROR_USER_NOT_FOUND":
          emailInputField.errorText = "This email is not recognized";
          break;
      }

      return false;
    }
  }

  bool checkInputs() {
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
    if (isEmpty)
      return false;
    else
      return true;
  }
}
