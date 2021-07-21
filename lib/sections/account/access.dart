import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:test_flutter/sections/account/agreements.dart';
import 'package:test_flutter/widgets/forward_arrow.dart';

import '../../API/methods/access.dart';
import '../../globals.dart' as globals;

import 'sign_up.dart';
import 'widgets/input_field.dart';
import 'widgets/account_app_bar.dart';

class AccessCodePage extends StatefulWidget {
  // Page that allows a user to enter an access code. This access code is
  // required to create an account for Entropy.

  @override
  _AccessCodePageState createState() => _AccessCodePageState();
}

class _AccessCodePageState extends State<AccessCodePage> {
  InputField accessCodeField;

  @override
  void initState() {
    super.initState();
    accessCodeField = new InputField(hintText: "Access Code");
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardActivated = (MediaQuery.of(context).viewInsets.bottom != 0.0);

    return Scaffold(
        appBar: AccountAppBar(height: .21 * globals.size.height),
        body: Container(
          padding: EdgeInsets.only(
              top: .05 * globals.size.height, bottom: .1 * globals.size.height),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  InputFieldWidget(inputField: accessCodeField),
                  Container(
                    width: .6 * globals.size.width,
                    child: Text(
                      "Enter the access code to create an account.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                ],
              ),
              if (keyboardActivated == false)
                GestureDetector(
                    child: ForwardArrow(),
                    onTap: () async {
                      Map response = await handleRequest(
                          context,
                          getAccess(
                              accessCodeField.textEditingController.text));

                      if (response["accessGranted"]) {
                        accessCodeField.errorText = "";
                        setState(() {});

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
                        );
                      } else {
                        accessCodeField.textEditingController.clear();
                        accessCodeField.errorText = "Access code is incorrect";
                        setState(() {});
                      }
                    })
            ],
          ),
        ));
  }
}
