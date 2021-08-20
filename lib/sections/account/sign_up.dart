import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:test_flutter/sections/account/agreements.dart';
import 'package:test_flutter/widgets/forward_arrow.dart';

import '../../API/methods/users.dart';
import '../../globals.dart' as globals;
import '../../models/user.dart';

import 'widgets/input_field.dart';
import 'widgets/account_app_bar.dart';

firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

class SignUpProvider extends ChangeNotifier {
  // Contains state of entire sign up page. Contains InputField object for
  // every input field. Has functionality for checking if input data is
  // valid and creating a new account. If there are any errors with the input
  // data, create appropriate error messages.

  final InputField name;
  final InputField email;
  final InputField username;
  final InputField password;

  SignUpProvider({
    @required this.name,
    @required this.email,
    @required this.username,
    @required this.password,
  });

  List<InputField> get inputFields => [name, email, username, password];

  Future<void> createNewAccount(BuildContext context) async {
    // Clears all error messages. Checks if the inputs are valid and if the
    // given userID and/or email have been taken. Also checks if the passwords
    // are strong enough. Returns true if all checks pass, false otherwise. If
    // the new account is valid, sends user to agreements page. Otherwise,
    // rebuilds sign up page with appropriate error messages.

    for (InputField inputField in inputFields) inputField.errorText = "";
    bool isNewAccountValid = true;

    if (_checkIfEmpty()) {
      isNewAccountValid = false;
    } else {
      if (!_checkIfEmailValid()) isNewAccountValid = false;
      if (!(await _checkIfEmailNotTaken())) isNewAccountValid = false;
      if (!(await _checkIfUserIdAvailable())) isNewAccountValid = false;
      if (!_checkIfPasswordStrongEnough()) isNewAccountValid = false;
    }
    if (isNewAccountValid)
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PolicyAgreementPage(
                    name: name.textEditingController.text,
                    email: email.textEditingController.text,
                    username: username.textEditingController.text,
                    password: password.textEditingController.text,
                  )));
    else
      notifyListeners();
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

  bool _checkIfEmailValid() {
    // Uses regular expressions to check if the given email is formated
    // correctly: "{name}@{email_service}.{domain}", e.g. "john@gmail.com"

    bool isEmailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email.textEditingController.text);

    if (!isEmailValid) email.errorText = "Not a valid email address";
    return isEmailValid;
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

  Future<bool> _checkIfUserIdAvailable() async {
    List<User> users =
        await getUsersFromSearchString((username.textEditingController.text));

    bool isUserIdTaken = false;

    for (User user in users) {
      print(user.toDict());
      if (user.userID == username.textEditingController.text)
        isUserIdTaken = true;
    }
    if (isUserIdTaken) username.errorText = "Username already taken";

    return !isUserIdTaken;
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
  // when the user starts typing in one of the InputFieldWidgets().

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
                          onTap: () => provider.createNewAccount(context)),
                    ),
                ],
              ),
            ),
          );
        }));
  }
}
