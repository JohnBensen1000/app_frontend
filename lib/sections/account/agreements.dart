import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:test_flutter/sections/camera/camera.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../globals.dart' as globals;
import '../../API/methods/users.dart';
import '../../API/methods/authentication.dart';
import '../../models/user.dart';
import '../../widgets/wide_button.dart';

import '../navigation/home_screen.dart';
import '../personalization/choose_color.dart';
import '../personalization/preferences.dart';

import 'widgets/account_submit_button.dart';
import 'widgets/account_app_bar.dart';

firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

class PolicyAgreement {
  // An object that keeps track of an individual policy agreement that has to
  // be accepted before the user can continue. The object contains the name of
  // the policy and a link to the actual policy document. Also contains variable
  // 'isAccepted' that is set to true when the user accepts the policy.

  PolicyAgreement({@required this.policyName, @required this.policyUrl});

  final String policyName;
  final String policyUrl;

  bool isAccepted = false;
}

class PolicyAgreementProvider extends ChangeNotifier {
  // Contains a list of PolicyAgreements that are used throughout the page.

  PolicyAgreementProvider({@required this.policyAgreements});

  final List<PolicyAgreement> policyAgreements;

  void resetState() {
    notifyListeners();
  }
}

class PolicyAgreementPage extends StatelessWidget {
  // A page that displays a list of policy agreements that the user has to
  // accept before they could create an account. The page is split into two main
  // sections: one section contains links to each policy document, the other
  // section contains a column of buttons for the user to accept each policy.
  // If the user accepts all the given policies, creates a new account for the
  // user.

  PolicyAgreementPage(
      {@required this.name,
      @required this.email,
      @required this.username,
      @required this.password});

  final String name;
  final String email;
  final String username;
  final String password;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (BuildContext context) =>
            PolicyAgreementProvider(policyAgreements: [
              PolicyAgreement(
                  policyName: "Privacy",
                  policyUrl:
                      "https://www.freeprivacypolicy.com/live/352d97f4-51ce-44a1-9364-93a39be1f31a"),
              PolicyAgreement(
                  policyName: "EULA",
                  policyUrl:
                      'https://www.termsfeed.com/live/f1bf5631-dbd3-4245-92fd-a63f45d16db7')
            ]),
        child: Consumer<PolicyAgreementProvider>(
            builder: (context, provider, child) => Scaffold(
                backgroundColor: const Color(0xffffffff),
                body: Container(
                  padding: EdgeInsets.only(
                      top: .04 * globals.size.height,
                      bottom: .11 * globals.size.height),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(width: double.infinity),
                      Text(
                        'Just one more thing…',
                        style: TextStyle(
                          fontFamily: 'Devanagari Sangam MN',
                          fontSize: .041 * globals.size.height,
                          color: const Color(0xff000000),
                          shadows: [
                            Shadow(
                              color: const Color(0x29000000),
                              blurRadius: 6,
                            )
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                          child: Column(
                        children: provider.policyAgreements
                            .map((policyAgreement) =>
                                AgreementLink(policyAgreement: policyAgreement))
                            .toList(),
                      )),
                      Container(
                          height: .1 * globals.size.height,
                          width: .6 * globals.size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: provider.policyAgreements
                                .map((policyAgreement) => AgreementButton(
                                    policyAgreement: policyAgreement,
                                    boxHeight: .04 * globals.size.height))
                                .toList(),
                          )),
                      Container(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  bottom: .0237 * globals.size.height),
                              child: Container(
                                width: .15 * globals.size.height,
                                height: .15 * globals.size.height,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: const AssetImage(
                                        'assets/images/Entropy.PNG'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: .7 * globals.size.width,
                              child: Text(
                                "Click the logo while in the app to get to your profile page",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                          child: AccountSubmitButton(
                            buttonName: "Sign Up",
                          ),
                          onTap: () async =>
                              await _createAccountIfAgreementsAreAccepted(
                                  context, provider))
                    ],
                  ),
                ))));
  }

  Future<void> _createAccountIfAgreementsAreAccepted(
      BuildContext context, PolicyAgreementProvider provider) async {
    // Goes through each policyAgreement and checks if the user has accepted. If
    // the user accepted all the policies, creates a new account for the user,
    // then, if no error occur in creating the new account, pushes the user to
    // the a list of pages that will customize their account. If the user has
    // not agreed to all the policies, shows an alert dialog telling the user
    // that they still have to agree to all the policies.

    bool areAgreementsAccepted = true;

    for (PolicyAgreement policyAgreement in provider.policyAgreements) {
      if (policyAgreement.isAccepted == false) {
        areAgreementsAccepted = false;
        break;
      }
    }
    if (areAgreementsAccepted) {
      if (await _createAccount(context)) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Home(
                      pageLabel: PageLabel.friends,
                    )));

        Navigator.push(context, SlideRightRoute(page: PreferencesPage()));
        Navigator.push(context, SlideRightRoute(page: ColorsPage()));
        Navigator.push(context, SlideRightRoute(page: TakeProfilePage()));
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => AgreementsAlertDialog());
    }
  }

  Future<bool> _createAccount(BuildContext context) async {
    // Creates a firebase account and an account in the database. Asks the user
    // for permission to send push notifications. Then sets globals.user to the
    // newly created account. If an error occurs in creating the account on the
    // backend, deletes the firebase account and returns false. Returns true
    // otherwise.

    firebase_auth.User firebaseUser =
        (await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ))
            .user;

    Map newAccount = {
      'uid': firebaseUser.uid,
      'userID': username,
      'username': name,
      'email': email,
    };

    var response = await handleRequest(context, postNewAccount(newAccount));
    if (response != null) {
      await FirebaseMessaging.instance.requestPermission();

      await handleRequest(context, postSignIn(firebaseUser.uid));
      globals.user = User.fromJson(response['user']);
      await globals.accountRepository.setUid(uid: firebaseUser.uid);
      return true;
    } else {
      await firebaseUser.delete();
      return false;
    }
  }
}

class AgreementLink extends StatelessWidget {
  // Stateless widget containing a link to the given policy agreement.

  const AgreementLink({@required this.policyAgreement});

  final PolicyAgreement policyAgreement;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(
        "Click here to read the ${policyAgreement.policyName} policy",
        style: TextStyle(
          fontFamily: 'Devanagari Sangam MN',
          fontSize: .026 * globals.size.height,
          color: const Color(0xff00b1ff),
        ),
        textAlign: TextAlign.center,
      ),
      onTap: () async {
        if (await canLaunch(policyAgreement.policyUrl))
          await launch(policyAgreement.policyUrl);
      },
    );
  }
}

class AgreementButton extends StatelessWidget {
  // Contains a button to accept the given policy agreement and a text telling
  // the user to agree to the given policy agreement. The button is grey if
  // the user accepted the agreement, white otherwise.

  const AgreementButton(
      {@required this.policyAgreement, @required this.boxHeight});

  final PolicyAgreement policyAgreement;
  final double boxHeight;

  @override
  Widget build(BuildContext context) {
    PolicyAgreementProvider provider =
        Provider.of<PolicyAgreementProvider>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
            child: Container(
              width: boxHeight,
              height: boxHeight,
              decoration: BoxDecoration(
                color: (policyAgreement.isAccepted)
                    ? Colors.grey[300]
                    : Colors.white,
                border: Border.all(width: 1.0, color: const Color(0xff707070)),
              ),
            ),
            onTap: () {
              policyAgreement.isAccepted = !policyAgreement.isAccepted;
              provider.resetState();
            }),
        Container(
          padding: EdgeInsets.only(left: .02 * globals.size.width),
          height: boxHeight,
          child: Center(
            child: Text(
              "Agree to ${policyAgreement.policyName} policy",
              style: TextStyle(
                fontFamily: 'Helvetica Neue',
                fontSize: .021 * globals.size.height,
                color: const Color(0xff000000),
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ],
    );
  }
}

class AgreementsAlertDialog extends StatelessWidget {
  // An alert dialog telling the user that they still have to accept all the
  // agreements.

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: Container(
        height: .2 * globals.size.height,
        width: .5 * globals.size.width,
        padding: EdgeInsets.all(.02 * globals.size.height),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.all(Radius.circular(.03 * globals.size.height))),
        child: Center(
            child: Text(
          "You must agree to all the policies before creating your account.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: .02 * globals.size.height),
        )),
      ),
    );
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

class TakeProfilePage extends StatelessWidget {
  // Returns a page that asks the user if they want to take a profile picture.
  // Then displays two options: take profile and skip.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AccountAppBar(height: .21 * globals.size.height),
        body: Container(
          padding: EdgeInsets.only(top: .03 * globals.size.height),
          height: .24 * globals.size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text("Would you like to take your profile picture?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: .03 * globals.size.height)),
              ),
              Container(
                width: double.infinity,
              ),
              Container(
                height: .11 * globals.size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      child: WideButton(
                        buttonName: "Take profile picture",
                      ),
                      onTap: () => Navigator.push(
                          context,
                          SlideRightRoute(
                              page: Camera(
                            cameraUsage: CameraUsage.profile,
                          ))).then((_) => Navigator.pop(context)),
                    ),
                    GestureDetector(
                        child: WideButton(
                          buttonName: "Skip",
                        ),
                        onTap: () => Navigator.pop(context)),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
