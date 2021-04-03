import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test_flutter/friends_page.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'backend_connect.dart';
import 'user_info.dart';
import 'chat_page.dart';
import 'friends_page.dart';

enum CameraUsage {
  post,
  chat,
  profile,
}

final serverAPI = new ServerAPI();

Future<void> sendPost(User friend, bool isImage, String filePath) async {
  // Sends a post as a direct message to a chat. Stores data about the post
  // in the chat document in google firestore (including download url to access
  // the file), and then  calls uploadFile() to store the actual post in google
  // storage.

  String chatName = getChatName(friend);
  CollectionReference chatsCollection = Firestore.instance.collection("Chats");

  await createChatIfDoesntExist(chatsCollection, chatName, friend);

  String postURL = await uploadFile(chatName, isImage, filePath);

  await chatsCollection
      .document(chatName)
      .collection('chats')
      .document('1')
      .updateData({
    'conversation': FieldValue.arrayUnion([
      {
        'sender': userID,
        'isPost': true,
        'post': {
          'postURL': postURL,
          'isImage': isImage,
        }
      }
    ])
  });
}

Future<String> uploadFile(
    String chatName, bool isImage, String filePath) async {
  // Uploads the post file to google storage. Determines the file name and
  // extension, and returns the download url that of the file.

  String fileExtension = (isImage) ? 'png' : 'mp4';
  String fileName =
      "$chatName/${DateTime.now().hashCode.toString()}.$fileExtension";

  StorageReference storageReference =
      FirebaseStorage.instance.ref().child(fileName);

  StorageUploadTask uploadTask = storageReference.putFile(File(filePath));
  await uploadTask.onComplete;
  return await storageReference.getDownloadURL();
}

Future<void> uploadProfilePic(bool isImage, String filePath) async {
  // Uploads a file that will be used as a user's profile pic

  String url = serverAPI.url + "users/" + userID + "/profile/";
  String profileType = (isImage) ? 'image' : 'video';
  var response = await http.post(url, body: {"profileType": profileType});

  if (response.statusCode == 201) {
    String fileExtension = (isImage) ? 'png' : 'mp4';
    String fileName = "$userID/profile.$fileExtension";

    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(fileName);

    StorageUploadTask uploadTask = storageReference.putFile(File(filePath));
    await uploadTask.onComplete;
  } else {
    print(" [SERVER ERROR] Was not able to save profile type");
  }
}

class VideoTimer {
  /* Stream that keeps track of how much time has elapsed since the beginning
     of the recording. This stream is used for the circular progress indicator.
  */
  VideoTimer() {
    Timer.periodic(Duration(milliseconds: 1), (_) {
      _progress >= 1 ? _progress = 0 : _progress += (1.0 / 6666.666666667);
      _controller.sink.add(_progress);
    });
  }

  double _progress = 0.0;
  StreamController<double> _controller = StreamController<double>();

  Stream<double> get stream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}

class PostPageProvider extends ChangeNotifier {
  /* Manages state for the entire post page. Keeps track of whether the user has
     captured a post, whether the post is an image or video, and whether or not
     the user is currently recording a video. When a change occurs, the widget 
     tree below this is rebuilt to reflect the change in state.  
  */
  PostPageProvider({@required this.cameraUsage, @required this.friend});

  final CameraUsage cameraUsage;
  final User friend;

  bool isImage = true;
  bool showCapturedPost = false;
  bool isRecording = false;
  String filePath;

  void takeImage() {
    isImage = true;
    showCapturedPost = true;
    notifyListeners();
  }

  void startRecording() {
    isRecording = true;
    notifyListeners();
  }

  void stopRecording() {
    showCapturedPost = true;
    isImage = false;
    isRecording = false;
    notifyListeners();
  }

  void deleteFile() async {
    showCapturedPost = false;
    imageCache.clear();
    if (File(filePath).existsSync()) {
      File(filePath).deleteSync();
    }
    notifyListeners();
  }
}

class NewPostScaffold extends StatelessWidget {
  NewPostScaffold({@required this.cameraUsage, this.friend});

  final CameraUsage cameraUsage;
  final User friend;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NewPostWidget(cameraUsage: cameraUsage, friend: friend));
  }
}

class NewPostWidget extends StatefulWidget {
  /* Allows users to use the camera to make a new post. This widget is divided
     into 3 main parts: connecting to the camera _initializeCamera(), seeing a 
     the input from the camera , _cameraView(), and after capturing an image, 
     seeing a preview of the image, _postPreview(). 
  */
  NewPostWidget({@required this.cameraUsage, this.friend});

  final CameraUsage cameraUsage;
  final User friend;

  @override
  _NewPostWidgetState createState() => _NewPostWidgetState();
}

class _NewPostWidgetState extends State<NewPostWidget> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  Size _size;
  double _deviceRatio;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _deviceRatio = _size.width / _size.height;

    return ChangeNotifierProvider(
        create: (_) => PostPageProvider(
            cameraUsage: widget.cameraUsage, friend: widget.friend),
        child: Consumer<PostPageProvider>(
            builder: (consumerContext, postPageState, child) =>
                Stack(children: <Widget>[
                  FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (postPageState.showCapturedPost == false) {
                            return CameraView(
                                controller: _controller,
                                deviceRatio: _deviceRatio);
                          } else {
                            return PostPreview(
                              controller: _controller,
                              deviceRatio: _deviceRatio,
                            );
                          }
                        } else {
                          return Center(child: Text("Loading camera view."));
                        }
                      }),
                  Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.only(top: 50, left: 5),
                      child: FlatButton(
                        child: NewPostFlatButton(
                            buttonName: "Exit Camera",
                            backgroundColor: Colors.white),
                        onPressed: () => _exitPage(consumerContext),
                      )),
                ])));
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _exitPage(BuildContext context) {
    Provider.of<PostPageProvider>(context, listen: false).deleteFile();
    Navigator.pop(context);
  }
}

class CameraView extends StatelessWidget {
  // Shows what the camera is seeing. Using a gesture detector, allows the user
  // to either capture an image or a video with the same button. If a video is
  // being recorded, displays a red circular progress bar around the post button
  // to show that a video is being recorded.

  CameraView({
    Key key,
    @required CameraController controller,
    @required double deviceRatio,
  })  : _controller = controller,
        _deviceRatio = deviceRatio,
        super(key: key);

  final CameraController _controller;
  final double _deviceRatio;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Transform.scale(
            scale: _controller.value.aspectRatio / _deviceRatio,
            child: Center(
                child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller)))),
        // if the camera is being used to take a profile picture/video, dim
        // everything that will not be the profile picture/video.
        if (Provider.of<PostPageProvider>(context).cameraUsage ==
            CameraUsage.profile)
          ProfilePicOutline(size: MediaQuery.of(context).size),
        Container(
          padding: EdgeInsets.all(60),
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                _recordingProgress(context),
                PostButtonSubCircle(diameter: 105, color: Colors.black),
                PostButtonSubCircle(diameter: 100, color: Colors.white),
                PostButtonSubCircle(diameter: 80, color: Colors.black),
                PostButtonSubCircle(diameter: 70, color: Colors.white),
              ],
            ),
            onTap: () => _takePhoto(context),
            onLongPress: () => _startVideo(context),
            onLongPressEnd: (_) => _endVideo(context),
          ),
        ),
      ],
    );
  }

  Widget _recordingProgress(BuildContext context) {
    var provider = Provider.of<PostPageProvider>(context, listen: false);

    if (provider.isRecording) {
      return StreamBuilder(
        stream: VideoTimer().stream,
        builder: (context, snapshot) {
          return SizedBox(
            child: CircularProgressIndicator(
              value: snapshot.data,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            height: 105.0,
            width: 105.0,
          );
        },
      );
    } else {
      return PostButtonSubCircle(
        color: Colors.transparent,
        diameter: 105,
      );
    }
  }

  void _takePhoto(BuildContext context) async {
    var provider = Provider.of<PostPageProvider>(context, listen: false);

    try {
      provider.filePath =
          join((await getTemporaryDirectory()).path, 'file.png');
      await _controller.takePicture(provider.filePath);

      provider.takeImage();
    } catch (e) {
      print(e);
    }
  }

  void _startVideo(BuildContext context) async {
    var provider = Provider.of<PostPageProvider>(context, listen: false);

    provider.filePath = join((await getTemporaryDirectory()).path, 'file.mp4');
    await _controller.startVideoRecording(provider.filePath);
    provider.startRecording();
  }

  void _endVideo(BuildContext context) async {
    var provider = Provider.of<PostPageProvider>(context, listen: false);

    _controller.stopVideoRecording();
    provider.stopRecording();
  }
}

class ProfilePicOutline extends StatelessWidget {
  // Returns a semitransparent rectangle that takes up the full screen with a
  // circle cut out from the center of it. This circle is completely
  // transparent.
  ProfilePicOutline({@required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ProfilePicOutlineClip(size: size),
      child: Container(
        color: Colors.black54,
      ),
    );
  }
}

class ProfilePicOutlineClip extends CustomClipper<Path> {
  // Provides the functionality for actually cutting out the circle from the
  // semitransparent rectangle.
  ProfilePicOutlineClip({@required this.size});

  final Size size;

  @override
  Path getClip(Size size) {
    return new Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: .45 * size.width))
      ..fillType = PathFillType.evenOdd;
    ;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class PostPreview extends StatelessWidget {
  // Container that shows a preview of the video/image that the user took. Gives
  // the user an option to take another video/image. Returns either
  // ChatPostOptions() (fromChatPost = true) or NewPostOptions() (fromChatPost
  // = false). Both of these widgets gives the user more options for what to
  // do with the post.

  PostPreview({
    Key key,
    @required CameraController controller,
    @required double deviceRatio,
  })  : _controller = controller,
        _deviceRatio = deviceRatio,
        super(key: key);

  final CameraController _controller;
  final double _deviceRatio;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PostPageProvider>(context);
    print(provider.cameraUsage);
    File postFile = File(provider.filePath);

    Widget previewWidget;
    provider.isImage
        ? previewWidget = Image(image: Image.file(postFile).image)
        : previewWidget = VideoPlayerScreen(videoFile: postFile);

    return Stack(children: <Widget>[
      Transform.scale(
          scale: _controller.value.aspectRatio / _deviceRatio,
          child: Center(
              child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: previewWidget))),
      if (provider.cameraUsage == CameraUsage.profile)
        ProfilePicOutline(size: MediaQuery.of(context).size),
      Container(
          padding: EdgeInsets.only(bottom: 20),
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    if (provider.cameraUsage == CameraUsage.chat)
                      ChatPostOptions(provider: provider)
                    else if (provider.cameraUsage == CameraUsage.profile)
                      ProfilePicOptions(
                        provider: provider,
                      )
                    else
                      NewPostOptions(provider: provider),
                  ],
                ),
              ),
              FlatButton(
                  child: NewPostFlatButton(
                      buttonName: "Redo", backgroundColor: Colors.white),
                  onPressed: () => provider.deleteFile()),
            ],
          ))
    ]);
  }
}

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen({Key key, this.videoFile}) : super(key: key);

  final File videoFile;

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.file(widget.videoFile);
    _controller.setLooping(true);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return FutureBuilder(
              future: _controller.play(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return VideoPlayer(_controller);
                } else {
                  return Center(child: Text("Loading..."));
                }
              });
        } else {
          return Center(child: Text("Loading..."));
        }
      },
    );
  }
}

class PostButtonSubCircle extends StatelessWidget {
  /* A stack of PostButtonSubCircle of alternating colors is used to compose
     the "capture image" button.
  */
  const PostButtonSubCircle({
    Key key,
    @required this.diameter,
    @required this.color,
  }) : super(key: key);

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: new BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class NewPostFlatButton extends StatelessWidget {
  /* Every button on the new_post.dart page is shaped/formatted the same way. */
  const NewPostFlatButton({
    Key key,
    @required String buttonName,
    @required Color backgroundColor,
  })  : _buttonName = buttonName,
        _backgroundColor = backgroundColor,
        super(key: key);

  final String _buttonName;
  final Color _backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100,
        height: 30,
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: _backgroundColor,
        ),
        child: Transform.translate(
          offset: Offset(0, 7),
          child: Text(_buttonName, textAlign: TextAlign.center),
        ));
  }
}

class NewPostOptions extends StatelessWidget {
  // lets the user either post the captured video/image publicly or share it in
  // a chat. If the user decides to share it in a chat, showDialog() is
  // called to let the user chose which chat to share the video/image in.

  NewPostOptions({@required this.provider});

  final provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FlatButton(
          child: NewPostFlatButton(
            buttonName: "Post",
            backgroundColor: Colors.white,
          ),
          onPressed: () async {
            await _uploadPost();
            provider.deleteFile();
          },
        ),
        FlatButton(
          child: NewPostFlatButton(
            buttonName: "Share",
            backgroundColor: Colors.white,
          ),
          onPressed: () async {
            await _shareWithFriends(context);
          },
        ),
      ],
    );
  }

  Future<int> _uploadPost() async {
    // Sends the an HTTP request containing the post file to the server for
    // further processing. Returns with the response status code.
    var request = http.MultipartRequest(
        'POST', Uri.parse(serverAPI.url + 'posts/$userID/posts/'));

    if (provider.isImage)
      request.fields["contentType"] = 'image';
    else
      request.fields["contentType"] = 'video';

    request.files
        .add(await http.MultipartFile.fromPath('media', provider.filePath));

    var response = await request.send();
    return response.statusCode;
  }

  Future<void> _shareWithFriends(BuildContext context) async {
    // Displays an alertDialog that lets the user choose which friends to send
    // the post to. Once the user selects a friend, calls _sendPost()
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return NewPostSendTo();
        }).then((friend) async {
      await sendPost(friend, provider.isImage, provider.filePath);
      provider.deleteFile();
    });
  }
}

class NewPostSendTo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 200,
        height: 400,
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(40)),
          color: Colors.white,
        ),
        child: FutureBuilder(
            future: getFriendsList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return NewPostFriendsList(friendsList: snapshot.data);
              } else {
                return Center(
                  child: Text("Loading"),
                );
              }
            }),
      ),
    ]);
  }
}

class NewPostFriendsList extends StatelessWidget {
  const NewPostFriendsList({
    @required this.friendsList,
    Key key,
  }) : super(key: key);

  final List<User> friendsList;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: ListView.builder(
          itemCount: friendsList.length,
          itemBuilder: (BuildContext context, int index) {
            return FlatButton(
              child: Text(
                friendsList[index].username,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              onPressed: () => Navigator.pop(context, friendsList[index]),
            );
          }),
    );
  }
}

class ChatPostOptions extends StatelessWidget {
  // This widget is called if the user is sending a post directly from the chat
  // page. Therefore, the user wants to send a post to that chat, so all we
  // have to do is give them the option to send/not send a post.
  ChatPostOptions({this.provider});

  final provider;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: NewPostFlatButton(
        buttonName: "Share",
        backgroundColor: Colors.white,
      ),
      onPressed: () async {
        await sendPost(provider.friend, provider.isImage, provider.filePath);
        provider.deleteFile();
      },
    );
  }
}

class ProfilePicOptions extends StatelessWidget {
  // This widget is called if the user is sending a post directly from the chat
  // page. Therefore, the user wants to send a post to that chat, so all we
  // have to do is give them the option to send/not send a post.
  ProfilePicOptions({this.provider});

  final provider;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: NewPostFlatButton(
        buttonName: "Save",
        backgroundColor: Colors.white,
      ),
      onPressed: () async {
        await uploadProfilePic(provider.isImage, provider.filePath);
        provider.deleteFile();
      },
    );
  }
}
