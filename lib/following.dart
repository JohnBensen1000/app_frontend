import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';

import 'user_info.dart';
import 'comments_section.dart';
import 'backend_connect.dart';

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
                        postID: postJson["postID"],
                        isImage: postJson["isImage"],
                        isVideo: postJson["isVideo"],
                      );
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
  Post(
      {@required this.userID,
      @required this.username,
      @required this.postID,
      @required this.isImage,
      @required this.isVideo});

  final String userID;
  final String username;
  final int postID;
  final bool isImage;
  final bool isVideo;

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    var getPostFunction;
    if (widget.isImage) getPostFunction = _getImage();
    if (widget.isVideo) getPostFunction = _getVideo();

    return FutureBuilder(
        future: getPostFunction,
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
                      post: snapshot.data,
                    ),
                  ],
                ));
          } else {
            return Center(child: Text("Loading..."));
          }
        });
  }

  Future<ImageProvider> _getImage() async {
    try {
      return Image.network(await FirebaseStorage.instance
              .ref()
              .child("${widget.userID}")
              .child("${widget.postID.toString()}.png")
              .getDownloadURL())
          .image;
    } catch (e) {
      print(" [ERROR] $e");
      return null;
    }
  }

  Future<String> _getVideo() async {
    try {
      return await FirebaseStorage.instance
          .ref()
          .child("${widget.userID}")
          .child("${widget.postID.toString()}.mp4")
          .getDownloadURL();
    } catch (e) {
      print(" [ERROR] $e");
      return null;
    }
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
    @required this.post,
  }) : super(key: key);

  final BuildContext context;
  final Post widget;
  final post;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 475.0,
      child: Column(
        children: <Widget>[
          _postContainer(),
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
                  onPressed: () => Scaffold.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.white,
                    duration: Duration(days: 365),
                    content: CommentSection(postID: widget.postID),
                  )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _postContainer() {
    if (widget.isImage) {
      return (ImageContainer(postImage: post));
    } else {
      return VideoContainer();
    }
  }
}

class ImageContainer extends StatelessWidget {
  const ImageContainer({
    Key key,
    @required this.postImage,
  }) : super(key: key);

  final ImageProvider<Object> postImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 435.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        image: DecorationImage(
          image: postImage,
          fit: BoxFit.cover,
        ),
        border: Border.all(width: 1.0, color: const Color(0xff707070)),
      ),
    );
  }
}

class VideoContainer extends StatefulWidget {
  VideoContainer({Key key, this.videoDownloadUrl}) : super(key: key);

  final String videoDownloadUrl;

  @override
  _VideoContainerState createState() => _VideoContainerState();
}

class _VideoContainerState extends State<VideoContainer> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  // @override
  // void initState() {
  //   _controller = VideoPlayerController.network(widget.videoDownloadUrl);
  //   _controller.setLooping(true);
  //   _initializeVideoPlayerFuture = _controller.initialize();

  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   _controller.dispose();

  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 435.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(width: 1.0, color: const Color(0xff707070)),
      ),
      child: Center(child: Text("Video")),
    );
    // return FutureBuilder(
    //   future: _initializeVideoPlayerFuture,
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       print(" [x] Returning future builder of video player.");
    //       return FutureBuilder(
    //           future: _controller.play(),
    //           builder: (context, snapshot) {
    //             if (snapshot.connectionState == ConnectionState.done) {
    //               return VideoPlayer(_controller);
    //             } else {
    //               return Center(child: Text("Loading..."));
    //             }
    //           });
    //     } else {
    //       return Center(child: Text("Loading..."));
    //     }
    //   },
    // );
  }
}
