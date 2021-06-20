import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/account_app_bar.dart';
import 'widgets/input_field.dart';
import 'widgets/account_submit_button.dart';

import '../../globals.dart' as globals;
import '../../API/methods/authentication.dart';
import '../../models/user.dart';
import '../navigation/home_screen.dart';

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
        appBar: AccountAppBar(
          height: 160,
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
                GestureDetector(
                    child: AccountSubmitButton(
                      buttonName: "Sign In",
                    ),
                    onTap: () async {
                      if (await _signIn()) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Home(
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

  Future<bool> _signIn() async {
    // Signs into firebase account. If any errors, updates appropraite error
    // messages. Returns true if successfully authenticated with firebase and
    // backend, false otherwise. After authenticating with backend, backend
    // returns a user model for the signed-in user. The variable, global.users
    // is set to this user model.

    passwordInputField.errorText = "";
    emailInputField.errorText = "";

    try {
      if (!areInputsValid()) return false;

      firebase_auth.User firebaseUser = (await auth.signInWithEmailAndPassword(
        email: emailInputField.textEditingController.text,
        password: passwordInputField.textEditingController.text,
      ))
          .user;
      Map response = await postSignIn(firebaseUser.uid);
      globals.user = User.fromJson(response['user']);
      await globals.accountRepository.setUid(uid: firebaseUser.uid);

      return true;
    } on firebase_auth.FirebaseAuthException catch (error) {
      print(error.code);
      switch (error.code) {
        case "user-not-found":
          emailInputField.errorText = "This email is not recognized";
          break;
      }
      return false;
    }
  }

  bool areInputsValid() {
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

    if (isEmpty) return false;

    return true;
  }
}
