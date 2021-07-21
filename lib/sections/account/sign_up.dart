import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:test_flutter/sections/account/agreements.dart';
import 'package:test_flutter/widgets/forward_arrow.dart';

import '../../API/methods/users.dart';
import '../../globals.dart' as globals;

import 'widgets/input_field.dart';
import 'widgets/account_app_bar.dart';

firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

class SignUpProvider extends ChangeNotifier {
  // Contains state of entire sign up page. Contains InputField object for
  // every input field. Has functionality for checking if input data is
  // valid and creating a new account. If there are any errors  with the input
  // data, create appropriate error messages. Creates both a firebase and a
  // user account in the database.

  final InputField name;
  final InputField email;
  final InputField username;
  final InputField password;
  final InputField confirmPassword;

  SignUpProvider({
    @required this.name,
    @required this.email,
    @required this.username,
    @required this.password,
    @required this.confirmPassword,
  });

  List<InputField> get inputFields =>
      [name, email, username, password, confirmPassword];

  Future<bool> createNewAccount(BuildContext context) async {
    // Clears all error messages. Checks if the inputs are valid and if the
    // given userID and/or email have been taken. Also checks if the passwords
    // match and are strong enough. Returns true if all checks pass,
    // false otherwise.

    for (InputField inputField in inputFields) inputField.errorText = "";
    bool isNewAccountValid = true;

    if (_checkIfEmpty()) {
      isNewAccountValid = false;
    } else {
      if (!_checkIfPasswordsMatch()) isNewAccountValid = false;
      if (!_checkIfEmailValid()) isNewAccountValid = false;
      if (!(await _checkIfEmailNotTaken())) isNewAccountValid = false;
      if (!(await _checkIfUserIdNotTaken(context))) isNewAccountValid = false;
      if (!_checkIfPasswordStrongEnough()) isNewAccountValid = false;
    }

    notifyListeners();
    return isNewAccountValid;
  }

  bool _checkIfEmpty() {
    bool isEmpty = false;
    for (InputField inputField in inputFields) {
      if (inputField.textEditingController.text == "") {
        inputField.errorText = "No input";
        isEmpty = true;
      }
    }
    return isEmpty;
  }

  bool _checkIfPasswordsMatch() {
    if (password.textEditingController.text !=
        confirmPassword.textEditingController.text) {
      confirmPassword.errorText = "Does not match password";
      return false;
    }
    return true;
  }

  bool _checkIfEmailValid() {
    // Uses regular expressions to check if the given email is formated
    // correctly: "{name}@{email_service}.{domain}", e.g. "john@gmail.com"

    bool isEmailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email.textEditingController.text);

    if (!isEmailValid) email.errorText = "Not a valid email address";
    return isEmailValid;
  }

  Future<bool> _checkIfUserIdNotTaken(BuildContext context) async {
    Map response = await handleRequest(
        context, getIfUserIdTaken((username.textEditingController.text)));
    bool isUserIdNotTaken = !response["isUserIdTaken"];

    if (!isUserIdNotTaken) username.errorText = "Username already taken";

    return isUserIdNotTaken;
  }

  Future<bool> _checkIfEmailNotTaken() async {
    // Uses the method fetchSignInMethodsForEmail() to check if the given email
    // exists in firebase. Returns true if the email is taken, false otherwise.

    bool isEmailNotTaken = (await auth
            .fetchSignInMethodsForEmail(email.textEditingController.text))
        .isEmpty;

    if (!isEmailNotTaken) email.errorText = "Email is already taken.";
    return isEmailNotTaken;
  }

  bool _checkIfPasswordStrongEnough() {
    bool isPasswordStrongEnough =
        password.textEditingController.text.length >= 6;

    if (!isPasswordStrongEnough) password.errorText = "Password too weak";

    return isPasswordStrongEnough;
  }
}

class SignUp extends StatefulWidget {
  // Initializes SignUpProvider() with all the appropraite InputFields. Returns
  // a ListView.builder() with all the InputWidgets. Hides AccountSubmitButton()
  // when the user starts typing in one of the InputFieldWidgets(). If the
  // input fields are valid, sends the user to the agreements page

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    double titleBarHeight = .21;
    double forwardButtonHeight = .15;

    bool keyboardActivated = (MediaQuery.of(context).viewInsets.bottom != 0.0);

    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return ChangeNotifierProvider(
        create: (_) => SignUpProvider(
              name: InputField(hintText: "Your Name"),
              email: InputField(hintText: "E-mail"),
              username: InputField(hintText: "username"),
              password: InputField(hintText: "password", obscureText: true),
              confirmPassword:
                  InputField(hintText: "confirm password", obscureText: true),
            ),
        child: Consumer<SignUpProvider>(builder: (context, provider, child) {
          return Scaffold(
            appBar: AccountAppBar(height: titleBarHeight * globals.size.height),
            body: Center(
              child: Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(
                        top: .05 * globals.size.height,
                      ),
                      height: (keyboardActivated)
                          ? (1 - titleBarHeight) * globals.size.height -
                              keyboardHeight
                          : (1 - titleBarHeight - forwardButtonHeight) *
                              globals.size.height,
                      child: ListView.builder(
                          itemCount: provider.inputFields.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InputFieldWidget(
                                inputField: provider.inputFields[index]);
                          })),
                  if (keyboardActivated == false)
                    Container(
                      height: forwardButtonHeight * globals.size.height,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                          child: ForwardArrow(),
                          onTap: () async {
                            if (await provider.createNewAccount(context))
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PolicyAgreementPage(
                                            name: provider.name
                                                .textEditingController.text,
                                            email: provider.email
                                                .textEditingController.text,
                                            username: provider.username
                                                .textEditingController.text,
                                            password: provider.password
                                                .textEditingController.text,
                                          )));
                          }),
                    ),
                ],
              ),
            ),
          );
        }));
  }
}
