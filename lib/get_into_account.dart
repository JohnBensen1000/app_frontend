import 'dart:convert';

import 'package:adobe_xd/pinned.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/home_screen.dart';
import 'package:http/http.dart' as http;

import 'globals.dart' as globals;
import 'backend_connect.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final serverAPI = new ServerAPI();
FirebaseAuth auth = FirebaseAuth.instance;

class SignInProvider extends ChangeNotifier {
  // Contains state for sign in page.
  final InputField email;
  final InputField password;

  bool accountCreated;

  SignInProvider({
    @required this.email,
    @required this.password,
  }) {
    this.accountCreated = false;
    this.email.textController.text = "john@gmail.com";
    this.password.textController.text = "test12345";
  }

  List<InputField> get inputFields => [email, password];

  Future<bool> signIn() async {
    // Signs into firebase account. If any errors, updates appropraite error
    // messages. Returns true if successfully authenticated with firebase and
    // backend, false otherwise.
    try {
      final FirebaseUser firebaseUser = (await auth.signInWithEmailAndPassword(
              email: email.textController.text,
              password: password.textController.text))
          .user;
      bool authenticated = await authenticateUserWithBackend(
          (await firebaseUser.getIdToken()).token);
      return authenticated;
    } catch (error) {
      switch (error.code) {
        case "ERROR_WRONG_PASSWORD":
          password.errorText = "This password is incorrected";
          break;
        case "ERROR_USER_NOT_FOUND":
          email.errorText = "This email is not recognized";
      }
      notifyListeners();

      return false;
    }
  }
}

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
      if (inputField.textController.text == "") {
        inputField.errorText = "No input";
        isEmpty = true;
      }
    }
    return isEmpty;
  }

  bool _checkIfPasswordsMatch() {
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

  Future<bool> _checkIfUniqueFieldsTaken() async {
    // Sends http post request to check if any unique identifiers (userID, email
    // and/or phone) has been taken by another user. If any of these identifiers
    // have been taken, updates respective error messages and returs true.
    String url = serverAPI.url + "users/check/";

    Map<dynamic, dynamic> postBody = {
      "userID": username.textController.text,
      "email": email.textController.text,
      "phone": phone.textController.text,
    };

    var response = await http.post(url, body: postBody);

    Map<String, dynamic> responseBody = json.decode(response.body);

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
              email: email.textController.text,
              password: password.textController.text))
          .user;
    } catch (error) {
      switch (error.code) {
        case "ERROR_WEAK_PASSWORD":
          password.errorText = "The selected password is too weak.";
          confirmPassword.textController.clear();
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

    String url = serverAPI.url + "users/${username.textController.text}/";

    Map<dynamic, dynamic> postBody = {
      "idToken": idToken,
      "userID": username.textController.text,
      "preferredLanguage": "english",
      "username": name.textController.text,
      "email": email.textController.text,
      "phone": phone.textController.text,
    };

    await http.post(url, body: postBody);
  }
}

Future<bool> authenticateUserWithBackend(String idToken) async {
  // Authenticates the user with the backend. First gets deviceToken. Sends
  // idToken and deviceToken to backend. Then sets the global variable userID to
  // the data that the backend returns. Returns false if an error occurred on
  // the backend, true otherwise.

  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  String deviceToken = await _firebaseMessaging.getToken();

  String _url = serverAPI.url + "authenticate/";
  http.Response response = await http
      .post(_url, body: {"idToken": idToken, "deviceToken": deviceToken});

  if (response.statusCode == 200) {
    globals.userID = json.decode(response.body)["userID"];
    return true;
  }
  return false;
}

enum PageType { signIn, signUp }

class InputField {
  // Object that contains the state of an individual InputFieldWidget.
  final String hintText;
  final bool obscureText;

  String errorText;
  TextEditingController textController;

  InputField({@required this.hintText, this.obscureText = false}) {
    this.errorText = "";
    this.textController = TextEditingController();
  }
}

class InputFieldsPageState extends StatelessWidget {
  // The whole point of this widget is to decide which provider to use. Could
  // be either SignUpProvider or ChangeNotifierProvider, depending on the value
  // of pageType.

  InputFieldsPageState({@required this.pageType});

  final PageType pageType;

  @override
  Widget build(BuildContext context) {
    switch (pageType) {
      case PageType.signUp:
        return ChangeNotifierProvider(
            create: (_) => SignUpProvider(
                  name: InputField(hintText: "Your Name"),
                  email: InputField(hintText: "E-mail"),
                  username: InputField(hintText: "username"),
                  phone: InputField(hintText: "phone number"),
                  password: InputField(hintText: "password", obscureText: true),
                  confirmPassword: InputField(
                      hintText: "confirm password", obscureText: true),
                ),
            child: InputFieldsPage(
              pageType: pageType,
            ));
        break;
      case PageType.signIn:
        return ChangeNotifierProvider(
            create: (_) => SignInProvider(
                  email: InputField(hintText: "E-mail"),
                  password: InputField(hintText: "password", obscureText: true),
                ),
            child: InputFieldsPage(
              pageType: pageType,
            ));
        break;
    }
    return null;
  }
}

class InputFieldsPage extends StatelessWidget {
  // Gets the right provider depending on the value of pageType. Returns
  // a ListView.builder() containing a list of InputField widgets. Only displays
  // InputSubmitButton() if the keyboard is activated.

  InputFieldsPage({@required this.pageType});

  final PageType pageType;

  @override
  Widget build(BuildContext context) {
    double titleBarHeight = 200;
    double height = MediaQuery.of(context).size.height;
    bool keyboardActivated = (MediaQuery.of(context).viewInsets.bottom != 0.0);

    var provider;
    switch (pageType) {
      case PageType.signIn:
        provider = Provider.of<SignInProvider>(context);
        break;
      case PageType.signUp:
        provider = Provider.of<SignUpProvider>(context);
        break;
    }

    return Scaffold(
      appBar: InputFieldsAppBar(
        height: titleBarHeight,
      ),
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
              InputSubmitButton(
                pageType: pageType,
              ),
          ],
        ),
      ),
    );
  }
}

class InputFieldsAppBar extends PreferredSize {
  final double height;

  InputFieldsAppBar({@required this.height});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      Row(
        children: <Widget>[
          Container(
            child: FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back"),
            ),
          ),
        ],
      ),
      SizedBox(
        width: 161.0,
        child: Text(
          'Entropy',
          style: TextStyle(
            fontFamily: 'Devanagari Sangam MN',
            fontSize: 40,
            color: const Color(0xff000000),
            shadows: [
              Shadow(
                color: const Color(0x29000000),
                offset: Offset(0, 3),
                blurRadius: 6,
              )
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      Container(
        width: double.infinity,
      ),
      Container(
        width: 112.0,
        height: 105.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
          // image: DecorationImage(
          //   image: const AssetImage(''),
          //   fit: BoxFit.cover,
          // ),
          border: Border.all(width: 3.0, color: const Color(0xff1de0e0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0x29000000),
              offset: Offset(0, 5),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    ]);
  }
}

class InputFieldWidget extends StatelessWidget {
  // Widget for an individual input field. Contains a TextFormField() and
  // Container() under the TextFormField() to display error messages. This
  // widget is rebuilt every time inputField changes.
  final InputField inputField;

  InputFieldWidget({@required this.inputField});

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
              controller: inputField.textController,
              textAlign: TextAlign.center,
              obscureText: inputField.obscureText,
              decoration: InputDecoration(
                hintText: inputField.hintText,
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
          inputField.errorText,
          style: TextStyle(color: Colors.red, fontSize: 12.0),
        ))
      ],
    );
  }
}

class InputSubmitButton extends StatelessWidget {
  // This button could either call SignInProvider.signIn() or
  // SignUpProvider.signUp(), depending on the value of pageType. When either
  // function completes successfully, pushes the user to HomeScreen() page.

  InputSubmitButton({@required this.pageType});

  final PageType pageType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 174.0,
      height: 52.0,
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  switch (pageType) {
                    case PageType.signIn:
                      _signIn(context);
                      break;
                    case PageType.signUp:
                      _signUp(context);
                      break;
                  }
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontFamily: 'Devanagari Sangam MN',
                    fontSize: 35,
                    color: const Color(0xff000000),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(0.0, 51.5, 174.0, 0.0),
            size: Size(174.0, 51.5),
            pinLeft: true,
            pinRight: true,
            pinBottom: true,
            fixedHeight: true,
            child: Stack(
              children: <Widget>[
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(0.0, 0.0, 174.0, 1.0),
                  size: Size(174.0, 0.0),
                  pinLeft: true,
                  pinRight: true,
                  pinTop: true,
                  pinBottom: true,
                  child: SvgPicture.string(
                    _svg_hyabiz,
                    allowDrawingOutsideViewBox: true,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signIn(BuildContext context) async {
    if (await Provider.of<SignInProvider>(context, listen: false).signIn()) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    pageLabel: PageLabel.friends,
                  )));
    }
  }

  Future<void> _signUp(BuildContext context) async {
    if (await Provider.of<SignUpProvider>(context, listen: false)
        .createNewAccount()) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    pageLabel: PageLabel.friends,
                  )));
    }
  }
}

const String _svg_hyabiz =
    '<svg viewBox="13.5 328.5 174.0 1.0" ><path transform="translate(13.5, 328.5)" d="M 0 0 L 174 0" fill="none" stroke="#1de0e0" stroke-width="4" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
