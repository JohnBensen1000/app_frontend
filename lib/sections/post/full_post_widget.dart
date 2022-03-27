import 'package:flutter/material.dart';
import 'package:Entropy/widgets/loading_icon.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../globals.dart' as globals;
import '../../widgets/profile_pic.dart';
import '../../models/post.dart';
import '../../widgets/pop_op_options.dart';
import '../../widgets/generic_alert_dialog.dart';
import '../../widgets/alert_dialog_container.dart';
import 'package:gallery_saver/gallery_saver.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../profile_page/profile_page.dart';

import 'post_widget.dart';
import 'post_page.dart';

class FullPostWidget extends StatefulWidget {
  // Returns a column of the creator's profile, the post, and the comments
  // button. When the profile is pressed, takes user to that creator's profile
  // page. When the post is pressed and the post is not it's own page, then
  // takes the user to the page that only shows the post. When the comments
  // button is pressed, opens up the comments section.

  FullPostWidget(
      {@required this.post,
      @required this.height,
      @required this.width,
      this.playVideo = true,
      this.isFullPage = false,
      this.showComments = false,
      this.verticalOffset = 0,
      this.commentsHeightFraction = .65,
      this.showCaption = false});

  final Post post;
  final bool playVideo;
  final bool isFullPage;
  final bool showComments;
  final bool showCaption;
  final double verticalOffset;
  final double commentsHeightFraction;
  final double height;
  final double width;

  @override
  State<FullPostWidget> createState() => _FullPostWidgetState();
}

class _FullPostWidgetState extends State<FullPostWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomCenter, children: [
      Container(
        width: widget.width,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                  key: UniqueKey(),
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: .015 * widget.width),
                      child: Profile(
                          diameter: .1 * widget.width,
                          user: widget.post.creator)),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProfilePage(user: widget.post.creator)))),
              GestureDetector(
                  child: _threeDots(),
                  onTap: () {
                    if (widget.post.creator.uid == globals.uid) {
                      Navigator.of(context).push(PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (_, __, ___) =>
                              PopUpOptionsPage(popUpOptions: [
                                PopUpOption(
                                    name: "Save to camera roll",
                                    onTap: () async =>
                                        await _saveToCameraRoll()),
                                PopUpOption(
                                    name: "Delete post",
                                    onTap: () async => await _deletePost(),
                                    fontColor: Colors.red)
                              ])));
                    }
                  })
            ]),
            GestureDetector(
                key: UniqueKey(),
                child: PostWidget(
                  post: widget.post,
                  height: widget.height,
                  aspectRatio: widget.height / widget.width,
                  showCaption: widget.showCaption,
                  showComments: widget.showComments,
                  playVideo: widget.playVideo,
                  commentsHeightFraction: widget.commentsHeightFraction,
                ),
                onTap: () {
                  if (!widget.isFullPage) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PostPage(isFullPost: true, post: widget.post)));
                  }
                }),
          ],
        ),
      ),
    ]);
  }

  Widget _threeDots() {
    return Container(
        color: Colors.transparent,
        height: .1 * widget.width,
        padding: EdgeInsets.symmetric(horizontal: .025 * globals.size.width),
        child: Row(
            children: List<Widget>.generate(
                3,
                (i) => Container(
                      height: .0115 * globals.size.height,
                      width: .0115 * globals.size.height,
                      padding: EdgeInsets.all(.003 * globals.size.height),
                      child: SvgPicture.asset("assets/images/ellipse.svg",
                          color: Colors.grey[800]),
                    ))));
  }

  Future<void> _deletePost() async {
    await showDialog(
            context: context,
            builder: (BuildContext _) => AlertDialogContainer(
                dialogText:
                    "Are you sure you want to delete this post? It will be permanently removed from the app."))
        .then((willDelete) async {
      if (willDelete) {
        await globals.usersPostsRepository
            .deletePostFromRepository(widget.post);
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _saveToCameraRoll() async {
    PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
        settings: RouteSettings(name: "loading_screen"),
        opaque: false,
        pageBuilder: (_, __, ___) => Scaffold(
            backgroundColor: Colors.grey[100].withOpacity(.5),
            body: Center(child: ProgressCircle(color: Colors.grey[300]))));

    Navigator.of(context).push(pageRouteBuilder);

    bool isSuccess;

    var photoData = await http.get(Uri.parse(widget.post.downloadURL));
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + "/images";
    var filePathAndName = documentDirectory.path +
        '/images/pic' +
        (widget.post.isImage ? ".jpg" : ".mp4");
    await Directory(firstPath).create(recursive: true);
    File file2 = new File(filePathAndName);
    file2.writeAsBytesSync(photoData.bodyBytes);
    if (widget.post.isImage) {
      await GallerySaver.saveImage(file2.path)
          .then((success) => isSuccess = success);
    } else {
      await GallerySaver.saveVideo(file2.path)
          .then((success) => isSuccess = success);
    }

    Navigator.removeRoute(context, pageRouteBuilder);

    if (isSuccess) {
      await showDialog(
          context: context,
          builder: (BuildContext context) => GenericAlertDialog(
              text:
                  "You have successfully saved this post to your camera roll!"));
    }
  }
}
