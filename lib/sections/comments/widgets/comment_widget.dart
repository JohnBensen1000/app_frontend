import 'package:flutter/material.dart';

import '../../../widgets/profile_pic.dart';
import '../../../models/comment.dart';
import '../../../API/methods/users.dart';
import '../../../repository/user_repository.dart';
import '../../../globals.dart' as globals;

class CommentWidget extends StatelessWidget {
  CommentWidget({
    @required this.comment,
    @required this.leftPadding,
  });

  final Comment comment;
  final double leftPadding;

  @override
  Widget build(BuildContext context) {
    double profilePicSize = 40.0;
    double profilePicPadding = 5.0;
    double margin = 2.5;
    double width = MediaQuery.of(context).size.width;

    return Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.all(margin),
        padding: EdgeInsets.only(left: leftPadding),
        child: FutureBuilder(
          future: globals.userRepository.getUser(comment.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 0, horizontal: profilePicPadding),
                      child: Column(
                        children: [
                          ProfilePic(
                              diameter: profilePicSize, user: snapshot.data)
                        ],
                      ),
                    ),
                    Container(
                        width: width -
                            leftPadding -
                            (2 * profilePicPadding + profilePicSize) -
                            2 * margin -
                            10,
                        alignment: Alignment.topLeft,
                        child: RichText(
                            text: new TextSpan(
                                style: new TextStyle(
                                    fontSize: 13, color: Colors.black),
                                children: <TextSpan>[
                              TextSpan(
                                  text: "${snapshot.data.username} ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: comment.commentText)
                            ]))),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ));
  }
}
