import 'package:flutter/material.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:test_flutter/API/methods/users.dart';

import '../../globals.dart' as globals;
import '../../widgets/back_arrow.dart';
import '../../widgets/profile_pic.dart';
import '../../models/user.dart';

class ChangeUsernamePage extends StatelessWidget {
  // This page is dedicated to letting the user change their username. It
  // returns a column of: back button, profil pic, username, userID, and a
  // "save" button. The username is a text field that lets the user change their
  // username.

  final TextEditingController _textController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    // _textController.text = globals.user.username;

    return Scaffold(
        body: FutureBuilder(
            future: globals.userRepository.get(globals.uid),
            builder: (context, snapshot) {
              _textController.text =
                  snapshot.hasData ? snapshot.data.username : "";
              if (snapshot.hasData)
                return Container(
                  padding: EdgeInsets.only(
                      top: .05 * globals.size.height,
                      left: .05 * globals.size.width,
                      right: .05 * globals.size.width,
                      bottom: .1 * globals.size.height),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                              child: BackArrow(),
                              onTap: () => Navigator.pop(context))
                        ],
                      ),
                      Container(
                        height: .35 * globals.size.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ProfilePic(
                                diameter: .2 * globals.size.height,
                                user: snapshot.data),
                            Container(
                                height: .06 * globals.size.height,
                                child: TextField(
                                  style: TextStyle(
                                    fontFamily: 'Helvetica Neue',
                                    fontSize: .045 * globals.size.height,
                                    color: const Color(0xff000000),
                                  ),
                                  decoration: InputDecoration(
                                    counterStyle: TextStyle(
                                      fontFamily: 'SF Pro Text',
                                      fontSize: .01 * globals.size.height,
                                      color: Colors.white,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  textAlign: TextAlign.center,
                                  autofocus: snapshot.hasData,
                                  controller: _textController,
                                )),
                            Container(
                                child: Text(
                              '@${snapshot.data.userID}',
                              style: TextStyle(
                                fontFamily: 'Helvetica Neue',
                                fontSize: .026 * globals.size.height,
                                color: Colors.grey[400],
                              ),
                              textAlign: TextAlign.left,
                            )),
                          ],
                        ),
                      ),
                      GestureDetector(
                          child: Container(
                              height: .03 * globals.size.height,
                              width: .2 * globals.size.width,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: snapshot.data.profileColor,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Center(
                                  child: Text(
                                "Save",
                                style: TextStyle(
                                  fontFamily: 'Helvetica Neue',
                                  fontSize: .02 * globals.size.height,
                                  color: const Color(0xff000000),
                                ),
                              ))),
                          onTap: () async {
                            await globals.userRepository
                                .changeUsername(_textController.text);

                            Navigator.pop(context);
                          })
                    ],
                  ),
                );
              else
                return Container();
            }));
  }
}
