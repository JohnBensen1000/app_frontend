import 'package:flutter/material.dart';
import 'package:test_flutter/sections/account/take_profile_pic.dart';

import '../../globals.dart' as globals;
import '../../models/user.dart';
import '../../API/methods/users.dart';

import 'widgets/input_field.dart';
import 'widgets/account_input_page.dart';

import '../personalization/choose_color.dart';
import '../home/home_page.dart';

class SignUpNamePage extends StatefulWidget {
  final String uid;

  SignUpNamePage({@required this.uid});

  @override
  State<SignUpNamePage> createState() => _SignUpNamePageState();
}

class _SignUpNamePageState extends State<SignUpNamePage> {
  InputField _inputField;

  @override
  void initState() {
    _inputField = InputField(hintText: "username");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: AccountInputPageWrapper(
            showBackArrow: false,
            key: UniqueKey(),
            headerText: "What's\nYour\nName?",
            child: InputFieldWidget(inputField: _inputField),
            onTap: _askForName));
  }

  Future<void> _askForName() async {
    String username = _inputField.textEditingController.text;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignUpUsername(
                  uid: widget.uid,
                  username: username,
                ))).then((value) {
      setState(() {});
    });
  }
}

class SignUpUsername extends StatefulWidget {
  final String uid;
  final String username;

  SignUpUsername({@required this.uid, @required this.username});

  @override
  State<SignUpUsername> createState() => _SignUpUsernameState();
}

class _SignUpUsernameState extends State<SignUpUsername> {
  InputField _inputField;
  bool _hasUserIdFailed;

  @override
  void initState() {
    _hasUserIdFailed = false;
    _inputField = InputField(hintText: "username");
    _inputField.textEditingController.addListener(() => _keyboardListener());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AccountInputPageWrapper(
        key: UniqueKey(),
        headerText: "What's\nYour\nUsername?",
        child: InputFieldWidget(inputField: _inputField),
        onTap: _createAccount);
  }

  void _keyboardListener() {
    if (_hasUserIdFailed) {
      _inputField.errorText = "";
      _hasUserIdFailed = false;
    }
  }

  Future<void> _createAccount() async {
    String userId = _inputField.textEditingController.text;

    List<User> users = await getUsersFromSearchString(userId);
    for (User user in users) {
      if (user.userID == userId) {
        _inputField.errorText = "Username not available";
        _hasUserIdFailed = true;
        setState(() {});

        return;
      }
    }

    await globals.accountRepository
        .createAccount(widget.uid, userId, widget.username);
    await globals.accountRepository.signIn(widget.uid);

    globals.setUpRepositorys();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ColorsPage(
                  isPartOfSignUpProcess: true,
                )));
  }
}
