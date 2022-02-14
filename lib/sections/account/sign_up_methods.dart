import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:test_flutter/sections/account/sign_up_email.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;
import '../../API/methods/users.dart';
import '../../API/baseAPI.dart';
import 'widgets/account_input_page.dart';
import '../home/home_page.dart';
import 'set_account_info.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../globals.dart' as globals;
import '../../widgets/wide_button.dart';

import "sign_up_phone.dart";

firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

class SignUpMethodsPage extends StatefulWidget {
  /*
    Gives users a list of options for signing into their accounts. 
   */
  @override
  State<SignUpMethodsPage> createState() => _SignUpMethodsPageState();
}

class _SignUpMethodsPageState extends State<SignUpMethodsPage> {
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
                          builder: (context) => SignUpPhonePage()))),
              // Android needs extra work to set up sign-in with Google, so only
              // showing this to ios for now
              if (Platform.operatingSystem == "ios")
                GestureDetector(
                    child: WideButton(buttonName: "Google"),
                    onTap: () => _signInWithGoogle()),
              if (Platform.operatingSystem == "ios")
                GestureDetector(
                    child: WideButton(buttonName: "Apple"),
                    onTap: () => _signInWithApple())
            ])),
        onTap: null,
        activateKeyboard: false);
  }

  Future<void> _signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleUser?.authentication;

    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    var firebaseUser = (await firebase_auth.FirebaseAuth.instance
            .signInWithCredential(credential))
        .user;

    _enterAccount(firebaseUser.uid);
  }

  Future<void> _signInWithApple() async {
    final rawNonce = _appleSignInGenerateNonce();
    final nonce = _appleSignInSha256ToString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = firebase_auth.OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    var firebaseUser = (await firebase_auth.FirebaseAuth.instance
            .signInWithCredential(oauthCredential))
        .user;

    _enterAccount(firebaseUser.uid);
  }

  String _appleSignInGenerateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _appleSignInSha256ToString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _enterAccount(String uid) async {
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
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SetAccountInfoPage(uid: uid)));
    }
  }
}
