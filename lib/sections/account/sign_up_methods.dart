import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../globals.dart' as globals;
import 'sign_up_email.dart';

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
    return AccountInputPageWrapper(
      pageNum: 0,
      showBackArrow: false,
      headerText: "Welcome to\nEntropy\nLet's get you\nStarted",
      child: Container(
        padding: EdgeInsets.only(top: .02 * globals.size.height),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                  // child: WideButton(buttonName: "Email"),
                  child: _signUpMethodButton(
                      "Sign in with Email", "assets/images/email.svg", .04),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUpEmail()))),
              if (kIsWeb == false)
                GestureDetector(
                    child: _signUpMethodButton(
                        "Sign in with Phone", "assets/images/phone.svg", .045),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUpPhonePage()))),
              // Android needs extra work to set up sign-in with Google, so only
              // showing this to ios for now
              GestureDetector(
                  child: _signUpMethodButton(
                      "Sign in with Google", "assets/images/google.svg", .028),
                  onTap: () => _signInWithGoogle()),
              if (kIsWeb == false && Platform.operatingSystem == "ios")
                GestureDetector(
                    child: _signUpMethodButton(
                        "Sign in with Apple", "assets/images/apple.svg", .03),
                    onTap: () => _signInWithApple())
            ]),
      ),
      onTap: null,
    );
  }

  Widget _signUpMethodButton(String buttonName, String assetPath, double size) {
    return Container(
      padding: EdgeInsets.only(
          left: .03 * globals.size.width, right: .03 * globals.size.width),
      width: .85 * globals.size.width,
      height: .05 * globals.size.height,
      margin: EdgeInsets.only(
          top: .01 * globals.size.height, bottom: .01 * globals.size.height),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21.0),
        color: const Color(0xffffffff),
        border: Border.all(width: 1.0, color: const Color(0xff707070)),
      ),
      child: Stack(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              child: Container(
                width: .05 * globals.size.height,
                child: Container(
                    width: size * globals.size.height,
                    height: size * globals.size.height,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(assetPath)),
              )),
          Container(
            alignment: Alignment.center,
            child: Text(
              buttonName,
              style: TextStyle(
                fontFamily: 'PingFang HK',
                fontSize: .028 * globals.size.height,
                color: const Color(0xff727272),
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      var firebaseUser = (await firebase_auth.FirebaseAuth.instance
              .signInWithCredential(credential))
          .user;

      _enterAccount(firebaseUser.uid);
    }
  }

  Future<void> _signInWithApple() async {
    final rawNonce = _appleSignInGenerateNonce();
    final nonce = _appleSignInSha256ToString(rawNonce);

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential =
          firebase_auth.OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      var firebaseUser = (await firebase_auth.FirebaseAuth.instance
              .signInWithCredential(oauthCredential))
          .user;

      _enterAccount(firebaseUser.uid);
    } on SignInWithAppleAuthorizationException catch (e) {
      print(e);
    }
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
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SignUpNamePage(uid: uid)));
    }
  }
}
