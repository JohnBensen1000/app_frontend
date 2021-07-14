import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../API/methods/posts.dart';
import '../../API/handle_requests.dart';
import '../../API/methods/relations.dart';
import '../../models/post.dart';

import '../navigation/home_screen.dart';
import '../post/post_view.dart';

class PostListProvider extends ChangeNotifier {
  // Keeps track of the vertical offset of the posts in PostListScroller. Allows
  // for smooth sliding up and down of the posts. swipeUp(), swipeDown(), and
  // moveBack() all slowly change the vertical offsets to create a smooth
  // transition from one post to the next (or to the same post as with
  // moveBack()

  final double postVerticalOffset;

  List<double> offsets;

  PostListProvider({@required this.postVerticalOffset}) {
    offsets = [-postVerticalOffset, 0, postVerticalOffset];
  }

  double _verticalOffset = 0;
  int prevIndex, currIndex, nextIndex;

  void findIndexes() {
    prevIndex = offsets.indexOf(-postVerticalOffset);
    currIndex = offsets.indexOf(0);
    nextIndex = offsets.indexOf(postVerticalOffset);
  }

  double get verticalOffset {
    return _verticalOffset;
  }

  set verticalOffset(double newVerticalOffset) {
    _verticalOffset = newVerticalOffset;
    notifyListeners();
  }

  Future<void> swipeUp() async {
    for (int i = 0; i < 100 * (postVerticalOffset + _verticalOffset); i++) {
      _updateOffsets(0, -.01, -.01);
      await Future.delayed(Duration(microseconds: 10));
    }
    _setOffsets(postVerticalOffset, -postVerticalOffset, 0);
  }

  Future<void> swipeDown() async {
    for (int i = 0; i < 100 * (postVerticalOffset - _verticalOffset); i++) {
      _updateOffsets(.01, .01, 0);
      await Future.delayed(Duration(microseconds: 10));
    }
    _setOffsets(0, postVerticalOffset, -postVerticalOffset);
  }

  Future<void> moveBack() async {
    double direction = (_verticalOffset > 0) ? -.01 : .01;

    for (int i = 0; i < 100 * _verticalOffset.abs(); i++) {
      _updateOffsets(direction, direction, direction);
      await Future.delayed(Duration(microseconds: 10));
    }
    _setOffsets(-postVerticalOffset, 0, postVerticalOffset);
  }

  void _updateOffsets(double prevUpdate, double currUpdate, double nextUpdate) {
    offsets[prevIndex] += prevUpdate;
    offsets[currIndex] += currUpdate;
    offsets[nextIndex] += nextUpdate;
    notifyListeners();
  }

  void _setOffsets(double prevOffset, double currOffset, double nextOffset) {
    offsets[prevIndex] = prevOffset;
    offsets[currIndex] = currOffset;
    offsets[nextIndex] = nextOffset;

    _verticalOffset = 0;

    notifyListeners();
  }
}

class PostList extends StatefulWidget {
  // Responsible for displaying a scrollable list of post widgets. At any given
  // time, this widget holds the previous, current, and next post widget so that
  // transition between post widgets is smooth. The previous and next post widget
  // are both positioned off-screen. By using a PostListScrollerProvider() and a
  // GestureDetector(), this widget listens to the user's vertical drags to
  // continuously update the position of each widget. This widget is passed a
  // function that returns a list of Posts that are to be displayed.

  PostList({@required this.function, @required this.height});

  final Function function;
  final double height;

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  double postVerticalOffset;

  List<Future<Widget>> postViews;
  List<bool> alreadyWatched;

  int postListIndex = 0;
  List<Post> postList = [];

  @override
  Widget build(BuildContext context) {
    postVerticalOffset = widget.height;

    return FutureBuilder(
        future: handleRequest(context, widget.function()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData || postList.length > 0) {
              postListIndex = postList.length;

              if (snapshot.hasData)
                postList.addAll(snapshot.data);
              else
                postListIndex -= 1;

              alreadyWatched = List<bool>.filled(postList.length, false);

              postViews = [
                _buildPostView(postListIndex - 1),
                _buildPostView(postListIndex),
                _buildPostView(postListIndex + 1)
              ];

              return ChangeNotifierProvider(
                create: (context) =>
                    PostListProvider(postVerticalOffset: postVerticalOffset),
                child: Consumer<PostListProvider>(
                    builder: (context, provider, child) {
                  return Stack(children: [
                    Transform.translate(
                      offset: Offset(
                          0, provider.verticalOffset + provider.offsets[0]),
                      child: _buildGestureDetector(
                          provider, postListIndex, postViews[0]),
                    ),
                    Transform.translate(
                      offset: Offset(
                          0, provider.verticalOffset + provider.offsets[1]),
                      child: _buildGestureDetector(
                          provider, postListIndex, postViews[1]),
                    ),
                    Transform.translate(
                      offset: Offset(
                          0, provider.verticalOffset + provider.offsets[2]),
                      child: _buildGestureDetector(
                          provider, postListIndex, postViews[2]),
                    ),
                  ]);
                }),
              );
            } else {
              return Center(
                child: GestureDetector(
                  child: Container(
                      width: 80,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Center(child: Text("Refresh"))),
                  onTap: () {
                    setState(() {});
                  },
                ),
              );
            }
          } else {
            return Container();
          }
        });
  }

  Future<Widget> _buildPostView(int index) async {
    // Looks to see if index is a valid index of postList. If it is,
    // builds and returns a PostView() that corresponds to the correct
    // item of postList.

    if (index < 0 || index == postList.length) {
      return null;
    } else {
      PostView postView = PostView(
        post: postList[index],
        height: .75 * postVerticalOffset,
        aspectRatio: globals.goldenRatio,
        postStage: PostStage.fullWidget,
        playOnInit: true,
      );

      return postView;
    }
  }

  GestureDetector _buildGestureDetector(
      PostListProvider provider, int postListIndex, Future<Widget> postView) {
    // Returns a GestureDetector that contains a post widget and updates the
    // provider whenever it detects a vertical drag. A button is added that,
    // when pressed, gives the user the options to block the user or report the
    // post for inappropriate content. If either of these options are selected,
    // then removes either the post or all posts from the creator from the post
    // list.

    return GestureDetector(
      child: FutureBuilder(
          future: postView,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  snapshot.data,
                  Container(
                      alignment: Alignment.bottomRight,
                      padding: EdgeInsets.only(right: 65, bottom: 30),
                      child: GestureDetector(
                          child: ReportButton(width: 50),
                          onTap: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      ReportContentAlertDialog(
                                          post: postList[postListIndex]))
                              .then((actionTaken) => (actionTaken != null)
                                  ? actionTaken == ActionTaken.blocked
                                      ? removePostsFromCreator(provider)
                                      : removePost(provider)
                                  : print("No action has been taken"))))
                ],
              );

              // return Center(child: snapshot.data);
            } else {
              return Center();
            }
          }),
      onVerticalDragUpdate: (value) =>
          provider.verticalOffset += value.delta.dy,
      onVerticalDragEnd: (_) async {
        await _handleVerticalDragStop(provider);
      },
    );
  }

  Future<void> _handleVerticalDragStop(PostListProvider provider) async {
    // Responsible for determine what post widget to display whenever a vertical
    // drag is detected. If the user swipes down, then both the current and next
    // post widget are shifted up. The previous post widget is replaced with the
    // next un-built post widget, and is positioned to be below current widget.
    // The same logic applies for the user swiping up. Nothing happens if the
    // current post widget is either the first or last post in postList.

    await _recordedWatched();

    provider.findIndexes();

    if (postListIndex == postList.length - 1 &&
        provider.verticalOffset < -(postVerticalOffset / 4)) {
      await provider.swipeUp();
      setState(() {});
    } else if (postListIndex + 1 < postList.length &&
        provider.verticalOffset < -(postVerticalOffset / 4)) {
      postListIndex++;
      await provider.swipeUp();

      postViews[provider.prevIndex] = _buildPostView(postListIndex + 1);
    } else if (postListIndex - 1 >= 0 &&
        provider.verticalOffset > (postVerticalOffset / 4)) {
      postListIndex--;
      await provider.swipeDown();

      postViews[provider.nextIndex] = _buildPostView(postListIndex - 1);
    } else {
      await provider.moveBack();
      // TODO: When user runs out of posts to watch, request more posts from server

    }
  }

  Future<void> _recordedWatched() async {
    // Sends a post request to the server to tell it to record that the user
    // has watched the current post.
    if (!alreadyWatched[postListIndex]) {
      String postID = postList[postListIndex].postID;

      await handleRequest(context, postRecordWatched(postID, 5));

      alreadyWatched[postListIndex] = true;
    }
  }

  Future<void> removePostsFromCreator(PostListProvider provider) async {
    // Goes through the entire post list and removes every post that was created
    // by the recently blocked creator. Rebuilds the post views so that none of
    // them contain the removed posts. The home page is rebuilt so that if any
    // direct messages exist between the user and the blocked creator, that
    // direct message is removed from the friends page.

    provider.findIndexes();

    String blockedCreatorUID = postList[postListIndex].creator.uid;

    for (int i = postList.length - 1; i >= 0; i--) {
      if (postList[i].creator.uid == blockedCreatorUID) {
        postList.removeAt(i);
        if (i < postListIndex) postListIndex--;
      }
    }

    if (postListIndex != postList.length) {
      postViews[provider.nextIndex] = _buildPostView(postListIndex);
      await provider.swipeUp();
      postViews[provider.currIndex] = _buildPostView(postListIndex - 1);
      postViews[provider.prevIndex] = _buildPostView(postListIndex + 1);
    } else {
      postListIndex--;

      postViews[provider.prevIndex] = _buildPostView(postListIndex);
      await provider.swipeDown();
      postViews[provider.nextIndex] = _buildPostView(postListIndex - 1);
    }

    Provider.of<ResetStateProvider>(context, listen: false).resetState();
  }

  Future<void> removePost(PostListProvider provider) async {
    // Removes the reported post from the post list.

    provider.findIndexes();

    postList.removeAt(postListIndex);

    if (postListIndex != postList.length) {
      await provider.swipeUp();
      postViews[provider.currIndex] = postViews[provider.prevIndex];
      postViews[provider.prevIndex] = _buildPostView(postListIndex + 1);
    } else {
      postListIndex--;

      await provider.swipeDown();
      postViews[provider.currIndex] = null;
      postViews[provider.nextIndex] = _buildPostView(postListIndex - 1);
    }
  }
}

enum ActionTaken { blocked, reported }

class ReportContentAlertDialog extends StatelessWidget {
  // Allows the user to report the post or block the creator. When pressed,
  // makes the appropriate API call for both of these options. Additionally,
  // makes an API call to record that the user has watched the post if the user
  // reports the post.

  ReportContentAlertDialog({@required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        width: 200,
        height: 200,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.grey[300].withOpacity(.9),
            borderRadius: BorderRadius.all(Radius.circular(25))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.all(10),
                child: Text("Problem?", style: TextStyle(fontSize: 22))),
            GestureDetector(
                child: ReportContentButton(
                  buttonName: "Report this post",
                ),
                onTap: () async {
                  await handleRequest(
                      context, postRecordWatched(post.postID, 0));
                  await handleRequest(context, reportPost(post));

                  Navigator.pop(context, ActionTaken.reported);
                }),
            GestureDetector(
                child: ReportContentButton(
                  buttonName: "Block this user",
                ),
                onTap: () async {
                  await handleRequest(context, postBlockedUser(post.creator));
                  Navigator.pop(context, ActionTaken.blocked);
                }),
          ],
        ),
      ),
    );
  }
}

class ReportButton extends StatelessWidget {
  ReportButton({@required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
            width: width,
            height: 20.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13.0),
              color: const Color(0xffffffff),
              border: Border.all(width: 1.0, color: const Color(0xff707070)),
            ),
            child: Center(
              child: Text(
                "Report",
                style: TextStyle(color: const Color(0x67000000), fontSize: 10),
              ),
            )));
  }
}

class ReportContentButton extends StatelessWidget {
  // Stateless widget used for ReportContentAlertDialog buttons.

  const ReportContentButton({
    @required this.buttonName,
    Key key,
  }) : super(key: key);

  final String buttonName;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white.withOpacity(.8);
    return GestureDetector(
      child: Container(
          margin: EdgeInsets.all(5),
          width: 160,
          height: 40,
          decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: Colors.grey[700], width: 1),
              borderRadius: BorderRadius.all(Radius.circular(25))),
          child: Center(
            child: Text(buttonName),
          )),
    );
  }
}
