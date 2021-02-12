import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'backend_connect.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final FirebaseAuth _auth = FirebaseAuth.instance;
final backendConnection = new BackendConnection();

class NewAccount {
  // Responsible for storing, validating, and creating a new account.

  final InputField name;
  final InputField email;
  final InputField username;
  final InputField phone;
  final InputField password;
  final InputField confirmPassword;

  bool accountCreated = false;

  NewAccount({
    this.name,
    this.email,
    this.username,
    this.password,
    this.phone,
    this.confirmPassword,
  });

  List<InputField> get inputFields =>
      [name, email, username, phone, password, confirmPassword];

  List<Widget> get inputWidgets {
    List<Widget> widgetList = [];
    for (InputField inputField in inputFields) {
      widgetList.add(inputField.inputWidget);
    }
    return widgetList;
  }

  Map<String, dynamic> get inputTextJson => {
        "userID": username.textController.text,
        "preferredLanguage": "english",
        "username": name.textController.text,
        "email": email.textController.text,
        "phone": phone.textController.text,
      };

  Future<bool> createNewAccount() async {
    // Clears all error messages. Validates if each input is formatted correct,
    // then checks if unique user account identifiers (userID, email, etc) are
    // already taken. If inputs are correct and identifiers are not taken, creates
    // new account. If an account has already been created, do nothing.

    _clearErrors();

    bool isNewAccountValid = true;

    if (!accountCreated) {
      if (_checkIfEmpty()) isNewAccountValid = false;
      if (!_doPasswordsMatch()) isNewAccountValid = false;
      if (!_isEmailValid()) isNewAccountValid = false;

      if (isNewAccountValid && !(await _createNewAccount()))
        isNewAccountValid = false;

      if (isNewAccountValid) accountCreated = true;
    }
    return isNewAccountValid;
  }

  void _clearErrors() {
    for (InputField inputField in inputFields) inputField.errorText = "";
  }

  bool _checkIfEmpty() {
    bool isEmpty = false;
    for (InputField inputField in inputFields) {
      if (inputField.textController.text == "") {
        inputField.errorText = "No input";
        isEmpty = true;
      }
    }
    return isEmpty;
  }

  bool _doPasswordsMatch() {
    if (password.textController.text != confirmPassword.textController.text) {
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
        .hasMatch(email.textController.text);

    if (!isEmailValid && email.errorText == "")
      email.errorText = "Not a valid email address";
    return isEmailValid;
  }

  Future<bool> _createNewAccount() async {
    // Sends post request to backend. If a new account wasn't created (status=200),
    // Then checks to see which unique identifier was already taken. Updated error
    // messages accordingly. Returns true if a new account has been created,
    // false otherwise.

    String url = backendConnection.url + "users/new_user/";
    var response = await http.post(url, body: this.inputTextJson);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody["userID"])
        username.errorText = "This username is already taken";
      if (responseBody["email"])
        email.errorText = "This email is already taken";
      if (responseBody["phone"])
        phone.errorText = "This phone number is already taken";

      return false;
    }
    return true;
  }
}

class InputField {
  final String hintText;
  final bool obscureText;

  InputField({this.hintText, this.obscureText});

  String errorText = "";
  TextEditingController textController = TextEditingController();

  Widget get inputWidget => InputFieldWidget(
        hintText: hintText,
        errorText: errorText,
        textController: textController,
        obscureText: obscureText,
      );
}

class InputFieldWidget extends StatelessWidget {
  final String hintText;
  final String errorText;
  final TextEditingController textController;
  final bool obscureText;

  InputFieldWidget(
      {this.hintText, this.errorText, this.textController, this.obscureText});

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
              controller: textController,
              textAlign: TextAlign.center,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
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
          errorText,
          style: TextStyle(color: Colors.red, fontSize: 12.0),
        ))
      ],
    );
  }
}
