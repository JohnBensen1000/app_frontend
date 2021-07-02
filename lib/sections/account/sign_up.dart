import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/handle_requests.dart';

import '../../globals.dart' as globals;

import '../../API/methods/authentication.dart';
import '../../API/methods/users.dart';
import '../../models/user.dart';

import '../navigation/home_screen.dart';
import '../personalization/choose_color.dart';
import '../personalization/preferences.dart';

import 'widgets/input_field.dart';
import 'widgets/account_app_bar.dart';
import 'widgets/account_submit_button.dart';

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
  // final InputField phone;
  final InputField password;
  final InputField confirmPassword;

  bool accountCreated;
  firebase_auth.User firebaseUser;

  SignUpProvider({
    @required this.name,
    @required this.email,
    @required this.username,
    @required this.password,
    // @required this.phone,
    @required this.confirmPassword,
  }) {
    this.accountCreated = false;
  }

  List<InputField> get inputFields =>
      [name, email, username, password, confirmPassword];

  Future<bool> createNewAccount(BuildContext context) async {
    // Clears all error messages. Validates if each input is formatted
    // correctly. If inputs are correct, creates an account in firebase
    // authentication and in the backend database. If the given email, phone,
    // and/or userID are taken, then an account is not created and the user is
    // notified which fields are taken. If an account is successfully created,
    // signs into the account.

    for (InputField inputField in inputFields) inputField.errorText = "";
    bool isNewAccountValid = true;

    if (!accountCreated) {
      if (_checkIfEmpty()) isNewAccountValid = false;
      if (!_checkIfPasswordsMatch()) isNewAccountValid = false;
      if (!_isEmailValid()) isNewAccountValid = false;

      if (isNewAccountValid) {
        isNewAccountValid = await _createFirebaseAccount();
      }
      if (isNewAccountValid) {
        isNewAccountValid = await _createAccount(context);
      }
      if (isNewAccountValid) accountCreated = true;
    }

    if (accountCreated)
      await postSignIn(globals.user.uid);
    else if (firebaseUser != null) {
      await firebaseUser.delete();
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

  Future<bool> _createFirebaseAccount() async {
    // Creates an account in firebase. If firebase returns any errors, then
    // updates the appropriate error messages.
    try {
      firebaseUser = (await auth.createUserWithEmailAndPassword(
              email: email.textEditingController.text,
              password: password.textEditingController.text))
          .user;
    } on firebase_auth.FirebaseAuthException catch (error) {
      switch (error.code) {
        case "ERROR_WEAK_PASSWORD":
          password.errorText = "The selected password is too weak.";
          confirmPassword.textEditingController.clear();
          break;
        case "email-already-in-use":
          email.errorText = "This email is already taken";
      }
      return false;
    }
    return true;
  }

  Future<bool> _createAccount(BuildContext context) async {
    // Sends a post request to the server with all the needed information for a
    // new account. If the given userID, email, and/or phone have been taken by
    // another user, updated the appropriate error messages. Otherwise updated
    // globals.user with the new user data.

    Map<dynamic, dynamic> postBody = {
      "uid": firebaseUser.uid,
      "userID": username.textEditingController.text,
      "username": name.textEditingController.text,
      "email": email.textEditingController.text,
      // "phone": ""
      // "phone": phone.textEditingController.text,
    };

    var response = await handleRequest(context, postNewAccount(postBody));

    if (response == null) return false;

    if (response.containsKey('fieldsTaken')) {
      if (response['fieldsTaken'].contains("userID"))
        username.errorText = "This username is already taken";

      if (response['fieldsTaken'].contains("email"))
        email.errorText = "This email is already taken";

      // if (response['fieldsTaken'].contains("phone"))
      //   phone.errorText = "This phone number is already taken";

      return false;
    } else if (response != null) {
      globals.user = User.fromJson(response['user']);
      await globals.accountRepository.setUid(uid: firebaseUser.uid);

      return true;
    }
    return false;
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
    double titleBarHeight = 160;
    double height = MediaQuery.of(context).size.height;
    bool keyboardActivated = (MediaQuery.of(context).viewInsets.bottom != 0.0);

    return ChangeNotifierProvider(
        create: (_) => SignUpProvider(
              name: InputField(hintText: "Your Name"),
              email: InputField(hintText: "E-mail"),
              username: InputField(hintText: "username"),
              // phone: InputField(hintText: "phone number"),
              password: InputField(hintText: "password", obscureText: true),
              confirmPassword:
                  InputField(hintText: "confirm password", obscureText: true),
            ),
        child: Consumer<SignUpProvider>(builder: (context, provider, child) {
          // provider.name.textEditingController.text = 'John';
          // provider.email.textEditingController.text = 'john@gmail.com';
          // provider.username.textEditingController.text = 'John';
          // provider.phone.textEditingController.text = '5164979872';
          // provider.password.textEditingController.text = 'test12345';
          // provider.confirmPassword.textEditingController.text = 'test12345';

          return Scaffold(
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
                    FlatButton(
                        child: AccountSubmitButton(
                          buttonName: "Sign Up",
                        ),
                        onPressed: () async {
                          if (await provider.createNewAccount(context))
                            _pushNextPages();
                        }),
                ],
              ),
            ),
          );
        }));
  }

  void _pushNextPages() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Home(
                  pageLabel: PageLabel.friends,
                )));

    Navigator.push(context, SlideRightRoute(page: PreferencesPage()));
    Navigator.push(context, SlideRightRoute(page: ColorsPage()));
  }
}

class SlideRightRoute extends PageRouteBuilder {
  // Custon PageRouteBuilder. Routes slide to the left when popped.
  final Widget page;

  SlideRightRoute({this.page})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                page,
            transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) =>
                SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child));
}
