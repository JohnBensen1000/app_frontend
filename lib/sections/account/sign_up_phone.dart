import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:test_flutter/widgets/forward_arrow.dart';

import '../../globals.dart' as globals;

import '../../API/methods/users.dart';

import 'widgets/input_field.dart';
import 'widgets/account_app_bar.dart';
import 'set_account_info.dart';
import '../home/home_page.dart';

firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

class SignUpPhonePage extends StatefulWidget {
  /*
    Allows a user to sign in/sign up using their phone number. Sends the user
    a verification code via SMS to confirm their account. Then sends the user
    to the verification page. 
   */
  @override
  _SignUpPhonePageState createState() => _SignUpPhonePageState();
}

class _SignUpPhonePageState extends State<SignUpPhonePage> {
  InputField _inputField;
  bool _didUserStartTyping;
  String _prevString;

  @override
  void initState() {
    _prevString = "";
    _didUserStartTyping = false;
    _inputField = new InputField(hintText: "phone");
    _inputField.textEditingController.text = "+1 000-000-0000";
    _inputField.textEditingController.addListener(() => _inputTextListener());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double titleBarHeight = .25;
    double forwardButtonHeight = .15;

    bool keyboardActivated = (MediaQuery.of(context).viewInsets.bottom != 0.0);
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AccountAppBar(height: titleBarHeight * globals.size.height),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(
                  top: .01 * globals.size.height,
                ),
                height: (keyboardActivated)
                    ? (1 - titleBarHeight) * globals.size.height -
                        keyboardHeight
                    : (1 - titleBarHeight - forwardButtonHeight) *
                        globals.size.height,
                child: InputFieldWidget(inputField: _inputField)),
            if (keyboardActivated == false)
              Container(
                height: forwardButtonHeight * globals.size.height,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                    child: ForwardArrow(),
                    onTap: () async => await _verifyPhone(context)),
              )
          ],
        ),
      ),
    );
  }

  Future<void> _inputTextListener() async {
    if (!_didUserStartTyping) {
      _updateInputText("+1 ");
      _didUserStartTyping = true;

      return;
    }
    String inputText = _inputField.textEditingController.value.text;

    if (inputText.length == 11 || inputText.length == 7) {
      if (_prevString.length < inputText.length)
        inputText = inputText.substring(0, inputText.length - 1) +
            "-" +
            inputText.substring(inputText.length - 1);
      else
        inputText = inputText.substring(0, inputText.length - 1);
      _updateInputText(inputText);
    }
    _prevString = inputText;
  }

  void _updateInputText(String inputText) {
    _inputField.textEditingController.value = TextEditingValue(
        text: inputText,
        selection:
            TextSelection.fromPosition(TextPosition(offset: inputText.length)));
  }

  Future<void> _verifyPhone(BuildContext context) async {
    String phoneNumber = _inputField.textEditingController.text;
    RegExp regExp = RegExp(
        r"^(\+\d{1,2}\s?)?1?\-?\.?\s?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$");
    if (!regExp.hasMatch(phoneNumber)) {
      _inputField.errorText = "this phone number is not valid";
      return false;
    }

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (firebase_auth.PhoneAuthCredential credential) {},
      verificationFailed: (firebase_auth.FirebaseAuthException e) {
        setState(() {
          _inputField.errorText = "an error has occurred";
        });
        return false;
      },
      codeSent: (String verificationId, int resendToken) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SignUpPhoneVerifyPage(verificationId: verificationId)));
        return true;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _inputField.errorText = "a timeout has been reached";
        });
        return false;
      },
    );
  }
}

class SignUpPhoneVerifyPage extends StatefulWidget {
  /*
    Allows the user to input their verification code to confirm their phone
    number. If the phone number is associated with an existing account, then 
    this is "signing in", and the user is sent to the home page. If not, then 
    sends the user to set their account info. 
   */
  final String verificationId;

  SignUpPhoneVerifyPage({@required this.verificationId});

  @override
  _SignUpPhoneVerifyPageState createState() => _SignUpPhoneVerifyPageState();
}

class _SignUpPhoneVerifyPageState extends State<SignUpPhoneVerifyPage> {
  InputField _inputField;

  @override
  void initState() {
    _inputField = new InputField(hintText: "code");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double titleBarHeight = .25;
    double forwardButtonHeight = .15;

    bool keyboardActivated = (MediaQuery.of(context).viewInsets.bottom != 0.0);
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AccountAppBar(height: titleBarHeight * globals.size.height),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(
                  top: .01 * globals.size.height,
                ),
                height: (keyboardActivated)
                    ? (1 - titleBarHeight) * globals.size.height -
                        keyboardHeight
                    : (1 - titleBarHeight - forwardButtonHeight) *
                        globals.size.height,
                child: InputFieldWidget(inputField: _inputField)),
            if (keyboardActivated == false)
              Container(
                height: forwardButtonHeight * globals.size.height,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                    child: ForwardArrow(),
                    onTap: () async => await _verifySmsCode(context)),
              )
          ],
        ),
      ),
    );
  }

  Future<void> _verifySmsCode(BuildContext context) async {
    String smsCode = _inputField.textEditingController.text;

    firebase_auth.PhoneAuthCredential credential =
        firebase_auth.PhoneAuthProvider.credential(
            verificationId: widget.verificationId, smsCode: smsCode);

    firebase_auth.UserCredential userCredential =
        await auth.signInWithCredential(credential);

    String uid = userCredential.user.uid;

    // Server fails when uid doesn't match user account.
    globals.isNewUser = true;
    try {
      if ((await getUserFromUID(uid)) != null) {
        globals.isNewUser = false;
      }
    } catch (e) {}

    if (globals.isNewUser) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SetAccountInfoPage(uid: userCredential.user.uid)));
    } else {
      globals.accountRepository.signIn(uid);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }
}
