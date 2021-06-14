import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../components/bottom_box_shadow.dart';

import '../feeds/following.dart';
import '../feeds/discover.dart';
import '../friends/friends_page.dart';
import '../camera/camera.dart';
import '../profile_page.dart';

import 'search_page.dart';

enum PageLabel {
  discover,
  friends,
  following,
}

class ResetStateProvider extends ChangeNotifier {
  // Provider used to tell other widgets to rebuild. This is called when the
  // user returns to the home page and the Discover, Friends, and Following
  // pages have to be rebuilt.

  void resetState() {
    notifyListeners();
  }
}

class HomeScreenProvider extends ChangeNotifier {
  // Responsible for keeping track of which page user is on. Also responsible
  // for smooth transitions between pages. As the user drags horizontally, this
  // provider continuously updates a variable, offset. When the user stops
  // sliding horizontally, this provider decides if the user swiped far enough
  // to display a new page.

  PageLabel pageLabel = PageLabel.friends;
  double _offset = 0;

  double get offset {
    return _offset;
  }

  set offset(double offsetVelocity) {
    _offset = offsetVelocity;

    if (_offset < -.33)
      this.pageLabel = PageLabel.following;
    else if (_offset > .33)
      this.pageLabel = PageLabel.discover;
    else
      this.pageLabel = PageLabel.friends;

    notifyListeners();
  }

  void handleHorizontalDragEnd() {
    if (_offset < -.33) {
      setMainPage(PageLabel.following);
    } else if (_offset > .33) {
      setMainPage(PageLabel.discover);
    } else {
      setMainPage(PageLabel.friends);
    }
  }

  void setMainPage(PageLabel newPageLabel) {
    if (newPageLabel == PageLabel.following) {
      _offset = -1.0;
      pageLabel = PageLabel.following;
    } else if (newPageLabel == PageLabel.discover) {
      _offset = 1.0;
      pageLabel = PageLabel.discover;
    } else {
      _offset = 0.0;
      pageLabel = PageLabel.friends;
    }
    notifyListeners();
  }
}

class Home extends StatefulWidget {
  // Main page of the app. Consists of two parts: HomeAppBar() and HomePage().
  // HomePage() consists of the discover, friends, and following pages. The
  // user could navigate through these pages by sliding left or right. The
  // HomeAppBar() allows the user to navigate to different parts of the app,
  // including the settings, search, and camera pages. HomeAppBar() also
  // displays which of the three pages from HomePage() that the user is on.

  final PageLabel pageLabel;

  Home({Key key, this.pageLabel}) : super(key: key);

  @override
  _HomeState createState() => _HomeState(pageLabel: pageLabel);
}

class _HomeState extends State<Home> {
  final PageLabel pageLabel;

  _HomeState({this.pageLabel});

  @override
  Widget build(BuildContext context) {
    double appBarHeight = 110;
    double bodyHeight = MediaQuery.of(context).size.height - appBarHeight;

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => ResetStateProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => HomeScreenProvider(),
          )
        ],
        child: Scaffold(
          backgroundColor: const Color(0xffffffff),
          appBar: HomeAppBar(
            height: appBarHeight,
          ),
          body: Container(child: HomePage(height: bodyHeight)),
        ));
  }
}

class HomeAppBar extends PreferredSize {
  // Divided into two parts: HomeAppBarButtons() and HomeAppBarNavigation().
  // both of these widgets allow the user to navigate to different parts of the
  // app.

  final double height;

  HomeAppBar({this.height});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        bottomBoxShadow,
      ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          HomeAppBarButtons(),
          HomeAppBarNavigation(),
        ],
      ),
    );
  }
}

class HomeAppBarButtons extends StatelessWidget {
  // Has buttons for nagivating to the profile search, and camera pages. When
  // the user returns from the search and camera pages, provider.resetState() is
  // called.

  const HomeAppBarButtons({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ResetStateProvider provider =
        Provider.of<ResetStateProvider>(context, listen: false);
    double buttonsWidth = 50;

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: buttonsWidth,
            ),
            GestureDetector(
                child: Container(
                    height: 58,
                    child: Image.asset('assets/images/Entropy.PNG')),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(user: globals.user)))),
            Container(
              height: 55,
              width: buttonsWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  GestureDetector(
                    child: IconContainer(
                      image: Image.asset('assets/images/search_icon.png'),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    ).then((value) => provider.resetState()),
                  ),
                  GestureDetector(
                    child: IconContainer(
                        image: Image.asset('assets/images/camera_icon.png')),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Camera(
                                cameraUsage: CameraUsage.post,
                              )),
                    ).then((value) => provider.resetState()),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class IconContainer extends StatelessWidget {
  const IconContainer({
    @required this.image,
    Key key,
  }) : super(key: key);

  final Image image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.0,
      height: 23.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: const Color(0xffffffff),
        border: Border.all(width: 1.0, color: const Color(0xff000000)),
      ),
      child: image,
    );
  }
}

class HomeAppBarNavigation extends StatelessWidget {
  // A row of three buttons that allow the user to navigate between the
  // discover, friends, and following pages. Also shows which page the user is
  // currently on. Has a bar that slides horizontally as the user swipes left
  // or right.

  const HomeAppBarNavigation({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeScreenProvider provider = Provider.of<HomeScreenProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 240,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              NavigationButton(
                pageName: "Discover",
                pageLabel: PageLabel.discover,
              ),
              NavigationButton(
                pageName: "Friends",
                pageLabel: PageLabel.friends,
              ),
              NavigationButton(
                pageName: "Following",
                pageLabel: PageLabel.following,
              ),
            ],
          ),
        ),
        Container(
          child: Transform.translate(
            offset: Offset(0, -10),
            child: Container(
              width: 212.0,
              height: 7.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: const Color(0xffffffff),
                border: Border.all(width: 1.0, color: const Color(0xff707070)),
              ),
              child: Transform.translate(
                offset: Offset(max(-1.0, min(-provider.offset, 1.0)) * 84.0, 0),
                child: SvgPicture.string(
                  _svg_cayeaa,
                  allowDrawingOutsideViewBox: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NavigationButton extends StatelessWidget {
  final String pageName;
  final PageLabel pageLabel;

  NavigationButton({this.pageName, this.pageLabel});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeScreenProvider>(builder: (context, provider, child) {
      Color textColor = (pageLabel == provider.pageLabel)
          ? Color(0xFF000000)
          : Color(0x73000000);

      return TextButton(
        child: Text(
          pageName,
          style: TextStyle(
            fontFamily: '.AppleSystemUIFont',
            fontSize: 15,
            color: textColor,
          ),
          textAlign: TextAlign.left,
        ),
        onPressed: () {
          provider.setMainPage(pageLabel);
        },
      );
    });
  }
}

class HomePage extends StatefulWidget {
  // Contains three widgets. These widgets are horizontally translated so that
  // only one widget is seen at a time. These translation offsets are updated
  // continuously as the user swipes horizontally. Each widget is wrapped with
  // a Container() that takes up the entire page. This is done so that
  // the GestureDetector() could respond to the user's swipes regardless of
  // where on the page they swipe. This widget is rebuilt any time the user
  // returns to the home page after leaving another page.

  HomePage({@required this.height});

  final double height;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Consumer<ResetStateProvider>(builder: (context, _, child) {
      Widget discoverPage = DiscoverPage(
        height: widget.height,
      );
      Widget friendsPage = FriendsPageState();
      Widget followingPage = FollowingPage(
        height: widget.height,
      );

      return Consumer<HomeScreenProvider>(builder: (context, provider, child) {
        return GestureDetector(
          child: Stack(children: [
            Transform.translate(
                offset: Offset(width * (provider.offset - 1), 0),
                child: Container(
                    width: width,
                    height: widget.height,
                    color: Colors.white,
                    child: discoverPage)),
            Transform.translate(
                offset: Offset(width * (provider.offset), 0),
                child: Container(
                    width: width,
                    height: widget.height,
                    color: Colors.white,
                    child: friendsPage)),
            Transform.translate(
                offset: Offset(width * (provider.offset + 1), 0),
                child: Container(
                    width: width,
                    height: widget.height,
                    color: Colors.white,
                    child: followingPage)),
          ]),
          onHorizontalDragUpdate: (value) =>
              Provider.of<HomeScreenProvider>(context, listen: false).offset +=
                  2.0 * (value.delta.dx / width),
          onHorizontalDragEnd: (_) =>
              Provider.of<HomeScreenProvider>(context, listen: false)
                  .handleHorizontalDragEnd(),
        );
      });
    });
  }
}

const String _svg_ffj51b =
    '<svg viewBox="23.0 3.7 1.3 4.0" ><path transform="translate(23.0, 3.67)" d="M 0 0 L 0 4 C 0.8047311305999756 3.661223411560059 1.328037977218628 2.873133182525635 1.328037977218628 2 C 1.328037977218628 1.126866698265076 0.8047311305999756 0.3387765288352966 0 0" fill="#000000" fill-opacity="0.4" stroke="none" stroke-width="1" stroke-opacity="0.4" stroke-miterlimit="10" stroke-linecap="butt" /></svg>';
const String _svg_32sc6 =
    '<svg viewBox="295.3 3.3 15.3 11.0" ><path transform="translate(295.34, 3.33)" d="M 7.667118072509766 10.99980068206787 C 7.583868026733398 10.99980068206787 7.502848148345947 10.96601009368896 7.444818019866943 10.90710067749023 L 5.438717842102051 8.884799957275391 C 5.37655782699585 8.824450492858887 5.342437744140625 8.740139961242676 5.345118045806885 8.653500556945801 C 5.346918106079102 8.567130088806152 5.384637832641602 8.48445987701416 5.448617935180664 8.426700592041016 C 6.068027973175049 7.903049945831299 6.855897903442383 7.61467981338501 7.667118072509766 7.61467981338501 C 8.478347778320312 7.61467981338501 9.266218185424805 7.903059959411621 9.885618209838867 8.426700592041016 C 9.949607849121094 8.48445987701416 9.98731803894043 8.567120552062988 9.989117622375488 8.653500556945801 C 9.990918159484863 8.740429878234863 9.956467628479004 8.824740409851074 9.894618034362793 8.884799957275391 L 7.889418125152588 10.90710067749023 C 7.831387996673584 10.96601009368896 7.750368118286133 10.99980068206787 7.667118072509766 10.99980068206787 Z M 11.18971824645996 7.451099872589111 C 11.10976791381836 7.451099872589111 11.03336811065674 7.420739650726318 10.97461795806885 7.365599632263184 C 10.06604766845703 6.544379711151123 8.891417503356934 6.092099666595459 7.667118072509766 6.092099666595459 C 6.443657875061035 6.092999935150146 5.269988059997559 6.545269966125488 4.36231803894043 7.365599632263184 C 4.303567886352539 7.420729637145996 4.227168083190918 7.451099872589111 4.147217750549316 7.451099872589111 C 4.064228057861328 7.451099872589111 3.986237764358521 7.418819904327393 3.927617788314819 7.360199928283691 L 2.768417596817017 6.189300060272217 C 2.706577777862549 6.127449989318848 2.673017740249634 6.045629978179932 2.673917770385742 5.958899974822998 C 2.674807786941528 5.871150016784668 2.709967613220215 5.789649963378906 2.772917747497559 5.729399681091309 C 4.106788158416748 4.489140033721924 5.845237731933594 3.806100130081177 7.668017864227295 3.806100130081177 C 9.490477561950684 3.806100130081177 11.229248046875 4.489140033721924 12.56401824951172 5.729399681091309 C 12.62696838378906 5.790549755096436 12.66212749481201 5.872049808502197 12.66301822662354 5.958899974822998 C 12.66391754150391 6.045629978179932 12.63035774230957 6.127449989318848 12.56851768493652 6.189300060272217 L 11.40931797027588 7.360199928283691 C 11.35068798065186 7.418819904327393 11.27270793914795 7.451099872589111 11.18971824645996 7.451099872589111 Z M 13.85911750793457 4.758299827575684 C 13.77818775177002 4.758299827575684 13.70179748535156 4.726979732513428 13.64401817321777 4.67009973526001 C 12.02446746826172 3.131530046463013 9.901827812194824 2.284200191497803 7.667118072509766 2.284200191497803 C 5.431828022003174 2.284200191497803 3.308867692947388 3.131530046463013 1.68931782245636 4.670109748840332 C 1.631547808647156 4.726969718933105 1.555147767066956 4.758299827575684 1.474217772483826 4.758299827575684 C 1.390907764434814 4.758299827575684 1.312917828559875 4.725699901580811 1.254617810249329 4.666500091552734 L 0.09361779689788818 3.496500015258789 C 0.03235779702663422 3.434340000152588 -0.0008822033414617181 3.352830171585083 1.779667218215764e-05 3.267000198364258 C 0.0009177966858260334 3.180460214614868 0.03511779755353928 3.099590063095093 0.09631779789924622 3.039300203323364 C 2.143527746200562 1.079370021820068 4.832218170166016 0 7.667118072509766 0 C 10.50233840942383 0 13.19070816040039 1.079380035400391 15.23701763153076 3.039300203323364 C 15.2982177734375 3.099590063095093 15.33241748809814 3.180460214614868 15.33331775665283 3.267000198364258 C 15.33421802520752 3.352830171585083 15.30097770690918 3.434340000152588 15.23971748352051 3.496500015258789 L 14.0787181854248 4.666500091552734 C 14.02041816711426 4.725699901580811 13.94242763519287 4.758299827575684 13.85911750793457 4.758299827575684 Z" fill="#000000" stroke="none" stroke-width="1" stroke-miterlimit="10" stroke-linecap="butt" /></svg>';
const String _svg_7e8xj2 =
    '<svg viewBox="273.3 3.7 17.0 10.7" ><path transform="translate(273.34, 3.67)" d="M 16.00020027160645 10.6668004989624 L 15.00029945373535 10.6668004989624 C 14.44894981384277 10.6668004989624 14.00039958953857 10.2182502746582 14.00039958953857 9.666900634765625 L 14.00039958953857 0.9999000430107117 C 14.00039958953857 0.4485500752925873 14.44894981384277 7.066725515869621e-08 15.00029945373535 7.066725515869621e-08 L 16.00020027160645 7.066725515869621e-08 C 16.55154991149902 7.066725515869621e-08 17.00010108947754 0.4485500752925873 17.00010108947754 0.9999000430107117 L 17.00010108947754 9.666900634765625 C 17.00010108947754 10.2182502746582 16.55154991149902 10.6668004989624 16.00020027160645 10.6668004989624 Z M 11.33369922637939 10.6668004989624 L 10.33290004730225 10.6668004989624 C 9.781549453735352 10.6668004989624 9.332999229431152 10.2182502746582 9.332999229431152 9.666900634765625 L 9.332999229431152 3.333600044250488 C 9.332999229431152 2.782249927520752 9.781549453735352 2.333699941635132 10.33290004730225 2.333699941635132 L 11.33369922637939 2.333699941635132 C 11.88504981994629 2.333699941635132 12.33360004425049 2.782249927520752 12.33360004425049 3.333600044250488 L 12.33360004425049 9.666900634765625 C 12.33360004425049 10.2182502746582 11.88504981994629 10.6668004989624 11.33369922637939 10.6668004989624 Z M 6.666300296783447 10.6668004989624 L 5.666399955749512 10.6668004989624 C 5.115049839019775 10.6668004989624 4.666500091552734 10.2182502746582 4.666500091552734 9.666900634765625 L 4.666500091552734 5.66640043258667 C 4.666500091552734 5.115050315856934 5.115049839019775 4.666500091552734 5.666399955749512 4.666500091552734 L 6.666300296783447 4.666500091552734 C 7.218140125274658 4.666500091552734 7.667099952697754 5.115050315856934 7.667099952697754 5.66640043258667 L 7.667099952697754 9.666900634765625 C 7.667099952697754 10.2182502746582 7.218140125274658 10.6668004989624 6.666300296783447 10.6668004989624 Z M 1.999799966812134 10.6668004989624 L 0.9998999834060669 10.6668004989624 C 0.4485500156879425 10.6668004989624 0 10.2182502746582 0 9.666900634765625 L 0 7.667100429534912 C 0 7.115260124206543 0.4485500156879425 6.666300296783447 0.9998999834060669 6.666300296783447 L 1.999799966812134 6.666300296783447 C 2.55115008354187 6.666300296783447 2.99970006942749 7.115260124206543 2.99970006942749 7.667100429534912 L 2.99970006942749 9.666900634765625 C 2.99970006942749 10.2182502746582 2.55115008354187 10.6668004989624 1.999799966812134 10.6668004989624 Z" fill="#000000" stroke="none" stroke-width="1" stroke-miterlimit="10" stroke-linecap="butt" /></svg>';
const String _svg_rfs5b5 =
    '<svg viewBox="0.5 44.5 375.0 1.0" ><path transform="translate(0.5, 44.5)" d="M 0 0 L 375 1" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_n49k6t =
    '<svg viewBox="0.0 0.0 36.0 33.0" ><path transform="translate(-19.96, -19.9)" d="M 54.85551452636719 19.89999961853027 C 54.73547744750977 19.89999961853027 54.61544418334961 19.89999961853027 54.49540710449219 19.95500183105469 L 20.76573944091797 34.86000061035156 C 19.80546379089355 35.1349983215332 19.6854305267334 36.28999710083008 20.52567100524902 36.78499984741211 L 30.24845886230469 40.85499954223633 L 26.70744132995605 46.68499755859375 L 33.1292839050293 43.4949951171875 L 37.63057708740234 52.40499877929688 C 37.87064361572266 52.7349967956543 38.23074722290039 52.89999771118164 38.59085083007812 52.89999771118164 C 39.07098770141602 52.89999771118164 39.49111175537109 52.625 39.67115783691406 52.18499755859375 L 55.93581771850586 21.21999931335449 C 56.1758918762207 20.55999946594238 55.57572174072266 19.89999961853027 54.85551452636719 19.89999961853027 Z M 38.6508674621582 49.48999786376953 L 34.92980194091797 42.0099983215332 L 50.4742546081543 25.06999778747559 L 31.86892318725586 39.31499862670898 L 23.70658111572266 35.85000228881836 L 52.39480972290039 23.14500045776367 L 38.6508674621582 49.48999786376953 Z" fill="#707070" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_cayeaa =
    '<svg viewBox="152.0 94.0 59.1 7.0" ><path transform="translate(152.0, 94.0)" d="M 3.691642761230469 0 L 55.37464141845703 0 C 57.41348266601562 0 59.0662841796875 1.56700325012207 59.0662841796875 3.5 C 59.0662841796875 5.43299674987793 57.41348266601562 7 55.37464141845703 7 L 3.691642761230469 7 C 1.652804613113403 7 0 5.43299674987793 0 3.5 C 0 1.56700325012207 1.652804613113403 0 3.691642761230469 0 Z" fill="#000000" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
