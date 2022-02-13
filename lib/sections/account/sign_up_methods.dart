import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:test_flutter/sections/account/sign_up_email.dart';

import '../../globals.dart' as globals;
import '../../widgets/wide_button.dart';

import 'widgets/account_app_bar.dart';
import 'widgets/account_input_page.dart';

import "sign_up_phone.dart";

firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

class SignUpMethodsPage extends StatelessWidget {
  /*
    Gives users a list of options for signing into their accounts. 
   */
  @override
  Widget build(BuildContext context) {
    return AccountInputPage(
        child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
              GestureDetector(
                  child: WideButton(buttonName: "Email"),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUpEmail()))),
              GestureDetector(
                  child: WideButton(buttonName: "Phone Number"),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignUpPhonePage())))
            ])),
        onTap: null,
        activateKeyboard: false);
  }
}
