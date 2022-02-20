import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/widgets/profile_pic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../globals.dart' as globals;
import '../../API/methods/users.dart';
import '../../widgets/wide_button.dart';
import '../account/widgets/account_input_page.dart';

import '../personalization/choose_color.dart';
import '../personalization/preferences.dart';
import '../home/home_page.dart';
import '../camera/camera.dart';

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

class TermsAndServicesPage extends StatefulWidget {
  // A page that allows the user to see their terms and services.

  @override
  State<TermsAndServicesPage> createState() => _TermsAndServicesPageState();
}

class _TermsAndServicesPageState extends State<TermsAndServicesPage> {
  List<PolicyAgreement> _policyAgreements;

  @override
  void initState() {
    _policyAgreements = [
      PolicyAgreement(
          policyName: "Privacy",
          policyUrl:
              "https://www.freeprivacypolicy.com/live/352d97f4-51ce-44a1-9364-93a39be1f31a"),
      PolicyAgreement(
          policyName: "EULA",
          policyUrl:
              'https://www.termsfeed.com/live/f1bf5631-dbd3-4245-92fd-a63f45d16db7')
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AccountInputPageWrapper(
        height: .3,
        child: Container(
            child: Column(
          children: _policyAgreements
              .map((policyAgreement) =>
                  AgreementLink(policyAgreement: policyAgreement))
              .toList(),
        )),
        onTap: null,
        headerText: "Terms &\nServices");
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
