import 'package:flutter/material.dart';
import 'backend_connect.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_info.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'comments_section.dart';

final backendConnection = new ServerAPI();
FirebaseStorage storage = FirebaseStorage.instance;

class FollowingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return SizedBox(
                height: 700,
                width: double.infinity,
                child: new ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      Map<String, dynamic> postJson = snapshot.data[index];
                      return Post(
                          userID: postJson["userID"],
                          username: postJson["username"],
                          postID: postJson["postID"]);
                    }));
          } else {
            return Center(child: Text("Loading..."));
          }
        });
  }

  Future<List<dynamic>> _getPosts() async {
    String newUrl = backendConnection.url + "posts/$userID/following/new/";
    var response = await http.get(newUrl);
    return json.decode(response.body)["postsList"];
  }
}

class Post extends StatefulWidget {
  final String userID;
  final String username;
  final int postID;

  Post({this.userID, this.username, this.postID});

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getPostImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Container(
                padding: EdgeInsets.only(left: 40, right: 40, bottom: 20),
                child: Column(
                  children: <Widget>[
                    PostHeader(widget: widget),
                    PostBody(
                        context: context,
                        widget: widget,
                        postImage: snapshot.data),
                  ],
                ));
          } else {
            return Center(child: Text("Loading..."));
          }
        });
  }

  Future<Image> _getPostImage() async {
    return Image.network(await FirebaseStorage.instance
        .ref()
        .child("${widget.userID}")
        .child("${widget.postID.toString()}.png")
        .getDownloadURL());
  }
}

class PostHeader extends StatelessWidget {
  const PostHeader({
    Key key,
    @required this.widget,
  }) : super(key: key);

  final Post widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 45.0,
                height: 43.0,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                  // image: DecorationImage(
                  //   image: const AssetImage(''),
                  //   fit: BoxFit.cover,
                  // ),
                  border:
                      Border.all(width: 3.0, color: const Color(0xff707070)),
                ),
              ),
              SizedBox(
                width: 146.0,
                child: Container(
                  padding: EdgeInsets.only(left: 10, top: 5),
                  child: Text(
                    widget.username,
                    style: TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 22,
                      color: const Color(0xff000000),
                      letterSpacing: -0.009019999921321869,
                      height: 0.5454545454545454,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 73.0,
                child: Text(
                  'Tier 5 ',
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 12,
                    color: const Color(0xff000000),
                    letterSpacing: -0.004099999964237213,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, 5.5),
                child: Container(
                  width: 73.0,
                  height: 11.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: const Color(0xffffffff),
                    border:
                        Border.all(width: 1.0, color: const Color(0xff707070)),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -5.5),
                child: Container(
                  width: 49.0,
                  height: 11.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: const Color(0xff707070),
                    border:
                        Border.all(width: 1.0, color: const Color(0xff707070)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PostBody extends StatelessWidget {
  const PostBody({
    Key key,
    @required this.context,
    @required this.widget,
    @required this.postImage,
  }) : super(key: key);

  final BuildContext context;
  final Post widget;
  final Image postImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 475.0,
      child: Column(
        children: <Widget>[
          Container(
            height: 435.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              image: DecorationImage(
                image: postImage.image,
                fit: BoxFit.cover,
              ),
              border: Border.all(width: 1.0, color: const Color(0xff707070)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: EdgeInsets.only(top: 3),
              width: 146.0,
              height: 25.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13.0),
                color: const Color(0xffffffff),
                border: Border.all(width: 3.0, color: const Color(0xff707070)),
              ),
              child: Container(
                padding: EdgeInsets.only(bottom: 5),
                child: FlatButton(
                  onPressed: () => Scaffold.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.white,
                    duration: Duration(days: 365),
                    content: CommentSection(postID: widget.postID),
                  )),
                  child: Text(
                    'View Comments',
                    style: TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 10,
                      color: const Color(0x67000000),
                      letterSpacing: -0.004099999964237213,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
