import 'package:flutter/material.dart';
import 'friends.dart';
import 'following.dart';
import 'for_you.dart';

void main() {
  runApp(MyApp());
}

enum PageLabels {
  friends,
  following,
  forYou,
}

class UserInfo extends InheritedWidget {
  final String userID;
  final Widget child;

  UserInfo({this.userID, this.child});

  static UserInfo of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserInfo>();
  }

  @override
  bool updateShouldNotify(UserInfo old) => userID != old.userID;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScaffold(
          pageBody: Following(), pageLabel: PageLabels.following.index),
    );
  }
}

class MainScaffold extends StatelessWidget {
  final int pageLabel;
  final Widget pageBody;

  MainScaffold({Key key, this.pageBody, this.pageLabel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget navigationBar = NavigationBar(pageLabel: pageLabel);

    return Scaffold(
        appBar: AppBar(
          title: const Text("An app has no name"),
        ),
        body: UserInfo(
          userID: "John1000",
          child: Column(
            children: <Widget>[
              navigationBar,
              pageBody,
            ],
          ),
        ));
  }
}

class NavigationBar extends StatefulWidget {
  final int pageLabel;

  NavigationBar({this.pageLabel});

  @override
  _NavigationBarState createState() =>
      _NavigationBarState(pageLabel: pageLabel);
}

class _NavigationBarState extends State<NavigationBar> {
  final int pageLabel;

  _NavigationBarState({this.pageLabel});

  Widget getNavigationButton(var pageName, Widget pageBody, int pageLabel) {
    // Returns a navigation button that when pressed, rebuilds the page with the
    // same navigation buttons but with a new body
    return RaisedButton(
        child: Text(pageName),
        onPressed: () {
          Navigator.push(
              context,
              SlideRightRoute(
                page: MainScaffold(
                  pageBody: pageBody,
                  pageLabel: pageLabel,
                ),
                direction: findSwipeDirection(pageLabel),
              ));
        });
  }

  double findSwipeDirection(int nextPageLabel) {
    // Determines which swipe animation (swipe left or swipe right) to do based
    // on the current page and the next page
    if (pageLabel == nextPageLabel) return 0.0;

    if (pageLabel == PageLabels.following.index) {
      if (nextPageLabel == PageLabels.friends.index) return -1.0;
      if (nextPageLabel == PageLabels.forYou.index) return 1.0;
    }
    if (pageLabel == PageLabels.friends.index) return 1.0;
    if (pageLabel == PageLabels.forYou.index) return -1.0;

    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        getNavigationButton("Friends", Friends(), PageLabels.friends.index),
        getNavigationButton(
            "Following", Following(), PageLabels.following.index),
        getNavigationButton("ForYou", ForYou(), PageLabels.forYou.index),
      ],
    ));
  }
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  final double direction;

  SlideRightRoute({this.page, this.direction})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: Offset(direction, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}
