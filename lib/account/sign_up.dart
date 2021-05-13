import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../backend_connect.dart';
import 'widgets/input_field.dart';
import 'widgets/account_app_bar.dart';
import 'widgets/account_submit_button.dart';

final serverAPI = new ServerAPI();
FirebaseAuth auth = FirebaseAuth.instance;

class SignUpProvider extends ChangeNotifier {
  // Contains state of entire sign up page. Contains InputField object for
  // every input field. Has functionality for checking if input data is
  // valid and creating a new account. If there are any errors  with the input
  // data, create appropriate error messages. Creates both a firebase and a
  // user account in the database.

  final InputField name;
  final InputField email;
  final InputField username;
  final InputField phone;
  final InputField password;
  final InputField confirmPassword;

  bool accountCreated;
  FirebaseUser firebaseUser;

  SignUpProvider({
    @required this.name,
    @required this.email,
    @required this.username,
    @required this.password,
    @required this.phone,
    @required this.confirmPassword,
  }) {
    this.accountCreated = false;
  }

  List<InputField> get inputFields =>
      [name, email, username, phone, password, confirmPassword];

  Future<bool> createNewAccount() async {
    // Clears all error messages. Validates if each input is formatted correct
    // and checks if unique user account identifiers (userID, email, etc) are
    // already taken. If inputs are correct and identifiers are not taken,
    // creates new firebase account. If a firebase account is created, then
    // create an account in the database. If an account has already been
    // created, do nothing.

    for (InputField inputField in inputFields) inputField.errorText = "";
    bool isNewAccountValid = true;

    if (!accountCreated) {
      if (_checkIfEmpty()) isNewAccountValid = false;
      if (!_checkIfPasswordsMatch()) isNewAccountValid = false;
      if (!_isEmailValid()) isNewAccountValid = false;
      if (await _checkIfUniqueFieldsTaken()) isNewAccountValid = false;

      if (isNewAccountValid) {
        isNewAccountValid = await _createFirebaseAccount();
      }
      if (isNewAccountValid) {
        await _createAccount();
        accountCreated = true;

        bool authenticated = await authenticateUserWithBackend(
            (await firebaseUser.getIdToken()).token);
        return authenticated;
      }
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

  bool _isEmailValid() {
    // Uses regular expressions to check if the given email is formated
    // correctly: "{name}@{email_service}.{domain}", e.g. "john@gmail.com"

    bool isEmailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email.textEditingController.text);

    if (!isEmailValid && email.errorText == "")
      email.errorText = "Not a valid email address";
    return isEmailValid;
  }

  Future<bool> _checkIfUniqueFieldsTaken() async {
    // Sends http post request to check if any unique identifiers (userID, email
    // and/or phone) has been taken by another user. If any of these identifiers
    // have been taken, updates respective error messages and returs true.

    Map<dynamic, dynamic> postBody = {
      "userID": username.textEditingController.text,
      "email": email.textEditingController.text,
      "phone": phone.textEditingController.text,
    };

    Map<String, dynamic> responseBody = await postUniqueIdentifiers(postBody);

    if (responseBody["userID"])
      username.errorText = "This username is already taken";
    if (responseBody["email"]) email.errorText = "This email is already taken";
    if (responseBody["phone"])
      phone.errorText = "This phone number is already taken";

    if (responseBody.containsValue(true)) return true;
    return false;
  }

  Future<bool> _createFirebaseAccount() async {
    // Creates an account in firebase. If firebase returns any errors, then
    // updates the appropriate error messages.
    try {
      firebaseUser = (await auth.createUserWithEmailAndPassword(
              email: email.textEditingController.text,
              password: password.textEditingController.text))
          .user;
    } catch (error) {
      switch (error.code) {
        case "ERROR_WEAK_PASSWORD":
          password.errorText = "The selected password is too weak.";
          confirmPassword.textEditingController.clear();
          break;
      }
      return false;
    }
    return true;
  }

  Future<void> _createAccount() async {
    // Sends a post request to create a new account. This new account will
    // contain all of the information that the user just typed in. One
    // additional field is sent: "idToken", this is needed to communicate with
    // the corresponding firebase account.

    String idToken = (await firebaseUser.getIdToken()).token;

    Map<dynamic, dynamic> postBody = {
      "idToken": idToken,
      "userID": username.textEditingController.text,
      "preferredLanguage": "english",
      "username": name.textEditingController.text,
      "email": email.textEditingController.text,
      "phone": phone.textEditingController.text,
    };

    await postCreateAccount(postBody, username.textEditingController.text);
  }
}

class SignUp extends StatefulWidget {
  // Initializes SignUpProvider() with all the appropraite InputFields. Returns
  // a ListView.builder() with all the InputWidgets. Hides AccountSubmitButton()
  // when the user starts typing in one of the InputFieldWidgets().
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    double titleBarHeight = 200;
    double height = MediaQuery.of(context).size.height;
    bool keyboardActivated = (MediaQuery.of(context).viewInsets.bottom != 0.0);

    return ChangeNotifierProvider(
        create: (_) => SignUpProvider(
              name: InputField(hintText: "Your Name"),
              email: InputField(hintText: "E-mail"),
              username: InputField(hintText: "username"),
              phone: InputField(hintText: "phone number"),
              password: InputField(hintText: "password", obscureText: true),
              confirmPassword:
                  InputField(hintText: "confirm password", obscureText: true),
            ),
        child: Consumer<SignUpProvider>(
            builder: (context, provider, child) => Scaffold(
                  appBar: AccountAppBar(height: titleBarHeight),
                  body: Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(top: 20),
                            height: (keyboardActivated)
                                ? height / 2 - titleBarHeight
                                : height - titleBarHeight - 200,
                            width: 400,
                            child: ListView.builder(
                                itemCount: provider.inputFields.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InputFieldWidget(
                                      inputField: provider.inputFields[index]);
                                })),
                        if (keyboardActivated == false)
                          AccountSubmitButton(
                            buttonName: "Sign Up",
                          ),
                      ],
                    ),
                  ),
                )));
  }
}
