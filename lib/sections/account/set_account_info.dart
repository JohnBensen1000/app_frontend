import 'package:flutter/material.dart';
import 'package:test_flutter/sections/account/agreements.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../models/user.dart';
import '../../API/methods/users.dart';

import 'widgets/input_field.dart';
import 'widgets/account_input_page.dart';

import '../personalization/choose_color.dart';
import '../home/home_page.dart';
import '../personalization/preferences.dart';

class AccountInfoInput {
  final String pageName;
  final InputField inputField;
  final Function onSubmit;

  AccountInfoInput(
      {@required this.pageName,
      @required this.inputField,
      @required this.onSubmit});
}

class SetAccountInfoProvider extends ChangeNotifier {
  /// Used to gather and submit user information when the user wants to create
  /// an account.

  final BuildContext context;
  final String uid;

  String _userId;
  String _username;

  List<AccountInfoInput> _accountInfoInputs;
  int _accountInfoIndex;

  AccountInfoInput _submitUserId;
  AccountInfoInput _submitUsername;

  SetAccountInfoProvider({@required this.context, @required this.uid}) {
    globals.isNewUser = true;

    _accountInfoIndex = 0;
    _submitUserId = AccountInfoInput(
        pageName: "What's Your Username?",
        inputField: InputField(hintText: "Username"),
        onSubmit: _saveUserName);
    _submitUsername = AccountInfoInput(
        pageName: "What's Your Name?",
        inputField: InputField(hintText: "Name"),
        onSubmit: _saveName);

    _accountInfoInputs = [_submitUserId, _submitUsername];
  }

  AccountInfoInput get accountInfoInput =>
      _accountInfoInputs[_accountInfoIndex];

  Future<void> onTap() async {
    String input = accountInfoInput.inputField.textEditingController.text;
    await accountInfoInput.onSubmit(input);
  }

  Future<void> _saveUserName(String userId) async {
    List<User> users = await getUsersFromSearchString((userId));

    for (User user in users) {
      if (user.userID == userId) {
        _submitUserId.inputField.errorText = "Username already taken";

        // When the user taps on the input field, clears the error message.
        _submitUserId.inputField.textEditingController.addListener(() {
          _submitUserId.inputField.errorText = "";
          notifyListeners();
        });
        notifyListeners();
        return;
      }
    }

    _userId = userId;
    await _goToNextPage();
  }

  Future<void> _saveName(String username) async {
    _username = username;
    await _goToNextPage();
  }

  Future<void> _goToNextPage() async {
    // If the user is finished setting up their account, creates the user
    // account in the database and asks the user to personalize their account.
    if (_accountInfoIndex + 1 == _accountInfoInputs.length) {
      await globals.accountRepository.createAccount(uid, _userId, _username);
      await globals.accountRepository.signIn(uid);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));

      Navigator.push(context, SlideRightRoute(page: PreferencesPage()));
      Navigator.push(context, SlideRightRoute(page: ColorsPage()));
      Navigator.push(context, SlideRightRoute(page: TakeProfilePage()));
    } else {
      _accountInfoIndex++;
    }
    notifyListeners();
  }
}

class SetAccountInfoPage extends StatefulWidget {
  /// Allows user to submit account information. Only asks for one thing at a
  /// time. When the user submits an input for one field, refreshes the page
  /// so the user can submit another input.

  final String uid;

  SetAccountInfoPage({@required this.uid});

  @override
  _SetAccountInfoPageState createState() => _SetAccountInfoPageState();
}

class _SetAccountInfoPageState extends State<SetAccountInfoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) =>
            SetAccountInfoProvider(uid: widget.uid, context: context),
        child: Consumer<SetAccountInfoProvider>(
          builder: (context, provider, child) => AccountInputPage(
              child: Column(
                children: [
                  Container(
                      child: Text(provider.accountInfoInput.pageName,
                          style: TextStyle(fontSize: 24))),
                  InputFieldWidget(
                      inputField: provider.accountInfoInput.inputField),
                ],
              ),
              onTap: provider.onTap),
        ));
  }
}
