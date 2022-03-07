import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;

import '../../widgets/input_field.dart';
import 'set_account_info.dart';
import '../home/home_page.dart';
import 'widgets/account_input_page.dart';
import '../../API/methods/users.dart';
import '../../API/baseAPI.dart';

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
  bool _hasAttemptedToSubmit;

  @override
  void initState() {
    _hasAttemptedToSubmit = false;
    _prevString = "";
    _didUserStartTyping = false;
    _inputField = new InputField(hintText: "phone");
    _inputField.textEditingController.text = "+1 000-000-0000";
    _inputField.textEditingController.addListener(() => _inputTextListener());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AccountInputPageWrapper(
        pageNum: 1,
        key: UniqueKey(),
        headerText: "Enter Your\nPhone\nNumber",
        child: InputFieldWidget(inputField: _inputField),
        onTap: _verifyPhone);
  }

  Future<void> _inputTextListener() async {
    if (_hasAttemptedToSubmit) {
      _inputField.errorText = "";
      _hasAttemptedToSubmit = false;
      return;
    }
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

  Future<void> _verifyPhone() async {
    String phoneNumber = _inputField.textEditingController.text;
    RegExp regExp = RegExp(
        r"^(\+\d{1,2}\s?)?1?\-?\.?\s?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$");
    if (!regExp.hasMatch(phoneNumber)) {
      _inputField.errorText = "this phone number is not valid";
      _hasAttemptedToSubmit = true;
      setState(() {});
      return;
    }

    await _sendVerificationCode();
  }

  Future<void> _sendVerificationCode() async {
    String phoneNumber = _inputField.textEditingController.text;

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (firebase_auth.PhoneAuthCredential credential) {},
      verificationFailed: (firebase_auth.FirebaseAuthException e) {
        _displayError(e.code);
        return false;
      },
      codeSent: (String verificationId, int resendToken) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SignUpPhoneVerifyPage(
                    phoneNumber: phoneNumber,
                    verificationId: verificationId))).then((value) {
          setState(() {});
        });
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

  void _displayError(String errorMessage) {
    switch (errorMessage) {
      case "too-many-requests":
        _inputField.errorText = "too many attempts";
        break;
      default:
        _inputField.errorText = "an error has occured";
        break;
    }
    setState(() {});
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
  final String phoneNumber;

  SignUpPhoneVerifyPage(
      {@required this.verificationId, @required this.phoneNumber});

  @override
  _SignUpPhoneVerifyPageState createState() => _SignUpPhoneVerifyPageState();
}

class _SignUpPhoneVerifyPageState extends State<SignUpPhoneVerifyPage> {
  InputField _inputField;
  bool _didAttemptToSubmit;

  @override
  void initState() {
    _didAttemptToSubmit = false;
    _inputField = new InputField(hintText: "");
    // _inputField.textEditingController.text = "------";
    _inputField.textEditingController.addListener(() => _inputTextListener());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AccountInputPageWrapper(
        pageNum: 2,
        key: UniqueKey(),
        headerText: "Enter\nSix Digit\nVerification\nCode",
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          InputFieldWidget(inputField: _inputField, child: Container()),
          GestureDetector(
              child: Text(
                "resend code",
                style: TextStyle(
                  fontSize: .02 * globals.size.height,
                  color: Colors.grey,
                ),
              ),
              onTap: () => _resendCode())
        ]),
        onTap: _verifySmsCode);
  }

  Future<void> _inputTextListener() async {
    if (_didAttemptToSubmit) {
      _inputField.text = "";
      _inputField.errorText = "";
      _didAttemptToSubmit = false;
    } else {
      _updateVerificationCodeWidget();
    }
  }

  Future<bool> _resendCode() async {
    await auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (firebase_auth.PhoneAuthCredential credential) {},
      verificationFailed: (firebase_auth.FirebaseAuthException e) {
        print(e);
        return false;
      },
      codeSent: (String verificationId, int resendToken) {
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

  void _updateVerificationCodeWidget() {
    String text = _inputField.text;

    int offset = 0;
    for (int i = 0; i < text.length; i++) {
      if (text[i] != "-") {
        offset += 1;
      } else {
        break;
      }
    }
    if (text.length > 0) {
      for (int i = offset; i < 6; i++) {
        text += "-";
      }
      _inputField.textEditingController.value = TextEditingValue(
          text: text.substring(0, 6),
          selection: TextSelection.fromPosition(TextPosition(offset: offset)));
    }
  }

  Future<void> _verifySmsCode() async {
    // Checks if the verification code that the user has inputted is correct.
    // If it is, sends the user to the next page. If it's not, then displays
    // the appropriate error message.
    String smsCode = _inputField.textEditingController.text;

    firebase_auth.PhoneAuthCredential credential =
        firebase_auth.PhoneAuthProvider.credential(
            verificationId: widget.verificationId, smsCode: smsCode);

    firebase_auth.UserCredential userCredential;
    try {
      userCredential = await auth.signInWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      _didAttemptToSubmit = true;
      _displayVerificationError(e.code);
      return;
    }

    String uid = userCredential.user.uid;

    // THIS IS A HACK. To check if the user has an account set up in the
    // database, checks if an error occurs when looking for this account. If
    // ServerFailedException occurs, then the user's account doesn't exist and
    // the user is asked to set up their account.
    try {
      await getUserFromUID(uid);
      await globals.accountRepository.signIn(uid);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } on ServerFailedException catch (e) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SignUpNamePage(uid: uid)));
    }
  }

  void _displayVerificationError(String errorCode) {
    switch (errorCode) {
      case "invalid-verification-code":
        _inputField.errorText = "wrong verification code";
        break;
      default:
        _inputField.errorText = "an error has occured";
        break;
    }
    setState(() {});
  }
}
