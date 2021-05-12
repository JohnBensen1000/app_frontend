import 'package:flutter/material.dart';
import 'package:test_flutter/profile_page.dart';
import 'package:test_flutter/profile_pic.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';

import '../globals.dart' as globals;
import '../backend_connect.dart';
import '../comments_section.dart';
import 'post.dart';

final backendConnection = new ServerAPI();
FirebaseStorage storage = FirebaseStorage.instance;

// PostStage is used to keep track of what is wanted from PostView(). Each
// "stage" corresponds to some settings. Each successive "stage" include all of
// the of the settings from the previous "stage". The settings for each stage
// are described here:
//      onlyPost: returns the image or video container
//      fullWidget: also returns the post header and comments button
//      playOnInit: if the post is a video, play the video instantly
//      userFeedback: return like/dislike buttons
//      postPage: return an entire page (PostPage())
enum PostStage { onlyPost, fullWidget, playOnInit, userFeedback, postPage }

class PostViewProvider extends ChangeNotifier {
  // Contains all state variables used in the app. Every widget under this is
  // rebuild when the boolean _showComments is changed.
  PostViewProvider({
    @required this.post,
    @required this.height,
    @required this.aspectRatio,
    @required this.videoController,
    @required this.postStage,
  }) {
    this.cornerRadius = height / 19;
  }

  final Post post;
  final double height;
  final double aspectRatio;
  final VideoPlayerController videoController;
  final PostStage postStage;

  double cornerRadius;
  bool isPlaying = true;
  bool _showComments = false;

  bool get showComments {
    return _showComments;
  }

  set showCommentButton(bool newShowComments) {
    _showComments = newShowComments;
    notifyListeners();
  }
}

class PostView extends StatelessWidget {
  // Contains layout and functionality of the post widget. Initializes
  // PostViewProvider Determines what to return based on the given postStage.
  // All user gestures (tapping, holding, etc) are handled here.

  PostView({
    @required this.post,
    @required this.height,
    @required this.aspectRatio,
    @required this.postStage,
    this.videoController,
  });

  final Post post;
  final double height;
  final double aspectRatio;
  final VideoPlayerController videoController;
  final PostStage postStage;

  @override
  Widget build(BuildContext context) {
    double postViewHeight = (postStage.index <= PostStage.onlyPost.index)
        ? height
        : height * 1.3333333;

    return GestureDetector(
        child: ChangeNotifierProvider(
            create: (context) => PostViewProvider(
                post: post,
                height: height,
                aspectRatio: aspectRatio,
                videoController: videoController,
                postStage: postStage),
            child: Consumer<PostViewProvider>(
              builder: (context, provider, child) => Container(
                height: postViewHeight,
                width: provider.height / aspectRatio,
                child: Column(
                  children: <Widget>[
                    if (provider.postStage.index >= PostStage.fullWidget.index)
                      GestureDetector(
                        child: PostViewHeader(),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfilePage(user: provider.post.user))),
                      ),
                    GestureDetector(
                      child: PostViewBody(),
                      onLongPress: () {
                        if (provider.postStage.index < PostStage.postPage.index)
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PostPage(
                                        post: provider.post,
                                      )));
                      },
                      onTap: () {
                        if (provider.postStage.index >=
                                PostStage.playOnInit.index &&
                            provider.videoController != null) {
                          if (provider.isPlaying)
                            provider.videoController.pause();
                          else
                            provider.videoController.play();

                          provider.isPlaying = !provider.isPlaying;
                        }
                      },
                    )
                  ],
                ),
              ),
            )));
  }
}

class PostViewHeader extends StatelessWidget {
  const PostViewHeader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PostViewProvider provider =
        Provider.of<PostViewProvider>(context, listen: false);

    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          ProfilePic(
              diameter: provider.height / 7.60,
              profileUserID: provider.post.userID),
          Container(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              provider.post.userID,
              style: TextStyle(
                fontFamily: 'Helvetica Neue',
                fontSize: 25,
                color: const Color(0xff000000),
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

class PostViewBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PostViewProvider provider =
        Provider.of<PostViewProvider>(context, listen: false);

    return Stack(alignment: Alignment.center, children: <Widget>[
      Container(
        height: provider.height,
        width: provider.height / provider.aspectRatio,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(provider.height / 19),
          border: Border.all(width: 1.0, color: const Color(0xff707070)),
        ),
      ),
      if (provider.post.isImage)
        FutureBuilder(
          future: getImage(provider.post),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return ImageContainer(image: snapshot.data);
            } else {
              return Container();
            }
          },
        )
      else if (provider.postStage.index >= PostStage.playOnInit.index)
        VideoContainer()
      else
        FutureBuilder(
            future: getThumbnail(provider.post, provider.height,
                provider.height / provider.aspectRatio),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return ImageContainer(
                  image: snapshot.data,
                  isThumbnail: true,
                );
              } else {
                return Container();
              }
            }),
    ]);
  }

  Future<ImageProvider> getImage(Post post) async {
    return Image.network(await post.postURL).image;
  }

  Future<ImageProvider> getThumbnail(
      Post post, double height, double width) async {
    String thumbnailFile = await VideoThumbnail.thumbnailFile(
      video: (await post.postURL).toString(),
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeight: height.toInt(),
      maxWidth: width.toInt(),
      quality: 10,
    );

    return Image.asset(thumbnailFile).image;
  }
}

class ImageContainer extends StatelessWidget {
  ImageContainer({@required this.image, this.isThumbnail = false});

  final ImageProvider image;
  final bool isThumbnail;

  @override
  Widget build(BuildContext context) {
    PostViewProvider provider =
        Provider.of<PostViewProvider>(context, listen: false);

    double height = provider.height;
    double width = provider.height / provider.aspectRatio;

    return Container(
        height: height - 2,
        width: width - 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(provider.cornerRadius - 1),
          image: DecorationImage(
            image: image,
            fit: BoxFit.cover,
          ),
        ),
        child: (isThumbnail)
            ? Container(
                padding: EdgeInsets.all(height * .03),
                alignment: Alignment.topRight,
                child: Text(
                  "Video",
                  style: TextStyle(color: Colors.grey),
                ))
            : Container());
  }
}

class VideoContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PostViewProvider provider =
        Provider.of<PostViewProvider>(context, listen: false);

    return FutureBuilder(
      future: provider.videoController.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          provider.videoController.play();
          return Container(
              width: provider.height / provider.aspectRatio - 2,
              height: provider.height - 2,
              child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(provider.cornerRadius - 1),
                  child: VideoPlayer(
                    provider.videoController,
                  )));
        } else {
          return Container();
        }
      },
    );
  }
}

const String _svg_ffj51b =
    '<svg viewBox="23.0 3.7 1.3 4.0" ><path transform="translate(23.0, 3.67)" d="M 0 0 L 0 4 C 0.8047311305999756 3.661223411560059 1.328037977218628 2.873133182525635 1.328037977218628 2 C 1.328037977218628 1.126866698265076 0.8047311305999756 0.3387765288352966 0 0" fill="#000000" fill-opacity="0.4" stroke="none" stroke-width="1" stroke-opacity="0.4" stroke-miterlimit="10" stroke-linecap="butt" /></svg>';
const String _svg_tds172 =
    '<svg viewBox="359.9 3.3 15.3 11.0" ><path transform="translate(359.87, 3.33)" d="M 7.667118072509766 10.99980068206787 C 7.583868026733398 10.99980068206787 7.502848148345947 10.96601009368896 7.444818019866943 10.90710067749023 L 5.438717842102051 8.884799957275391 C 5.37655782699585 8.824450492858887 5.342437744140625 8.740139961242676 5.345118045806885 8.653500556945801 C 5.346918106079102 8.567130088806152 5.384637832641602 8.48445987701416 5.448617935180664 8.426700592041016 C 6.068027973175049 7.903049945831299 6.855897903442383 7.61467981338501 7.667118072509766 7.61467981338501 C 8.478347778320312 7.61467981338501 9.266218185424805 7.903059959411621 9.885618209838867 8.426700592041016 C 9.949607849121094 8.48445987701416 9.98731803894043 8.567120552062988 9.989117622375488 8.653500556945801 C 9.990918159484863 8.740429878234863 9.956467628479004 8.824740409851074 9.894618034362793 8.884799957275391 L 7.889418125152588 10.90710067749023 C 7.831387996673584 10.96601009368896 7.750368118286133 10.99980068206787 7.667118072509766 10.99980068206787 Z M 11.18971824645996 7.451099872589111 C 11.10976791381836 7.451099872589111 11.03336811065674 7.420739650726318 10.97461795806885 7.365599632263184 C 10.06604766845703 6.544379711151123 8.891417503356934 6.092099666595459 7.667118072509766 6.092099666595459 C 6.443657875061035 6.092999935150146 5.269988059997559 6.545269966125488 4.36231803894043 7.365599632263184 C 4.303567886352539 7.420729637145996 4.227168083190918 7.451099872589111 4.147217750549316 7.451099872589111 C 4.064228057861328 7.451099872589111 3.986237764358521 7.418819904327393 3.927617788314819 7.360199928283691 L 2.768417596817017 6.189300060272217 C 2.706577777862549 6.127449989318848 2.673017740249634 6.045629978179932 2.673917770385742 5.958899974822998 C 2.674807786941528 5.871150016784668 2.709967613220215 5.789649963378906 2.772917747497559 5.729399681091309 C 4.106788158416748 4.489140033721924 5.845237731933594 3.806100130081177 7.668017864227295 3.806100130081177 C 9.490477561950684 3.806100130081177 11.229248046875 4.489140033721924 12.56401824951172 5.729399681091309 C 12.62696838378906 5.790549755096436 12.66212749481201 5.872049808502197 12.66301822662354 5.958899974822998 C 12.66391754150391 6.045629978179932 12.63035774230957 6.127449989318848 12.56851768493652 6.189300060272217 L 11.40931797027588 7.360199928283691 C 11.35068798065186 7.418819904327393 11.27270793914795 7.451099872589111 11.18971824645996 7.451099872589111 Z M 13.85911750793457 4.758299827575684 C 13.77818775177002 4.758299827575684 13.70179748535156 4.726979732513428 13.64401817321777 4.67009973526001 C 12.02446746826172 3.131530046463013 9.901827812194824 2.284200191497803 7.667118072509766 2.284200191497803 C 5.431828022003174 2.284200191497803 3.308867692947388 3.131530046463013 1.68931782245636 4.670109748840332 C 1.631547808647156 4.726969718933105 1.555147767066956 4.758299827575684 1.474217772483826 4.758299827575684 C 1.390907764434814 4.758299827575684 1.312917828559875 4.725699901580811 1.254617810249329 4.666500091552734 L 0.09361779689788818 3.496500015258789 C 0.03235779702663422 3.434340000152588 -0.0008822033414617181 3.352830171585083 1.779667218215764e-05 3.267000198364258 C 0.0009177966858260334 3.180460214614868 0.03511779755353928 3.099590063095093 0.09631779789924622 3.039300203323364 C 2.143527746200562 1.079370021820068 4.832218170166016 0 7.667118072509766 0 C 10.50233840942383 0 13.19070816040039 1.079380035400391 15.23701763153076 3.039300203323364 C 15.2982177734375 3.099590063095093 15.33241748809814 3.180460214614868 15.33331775665283 3.267000198364258 C 15.33421802520752 3.352830171585083 15.30097770690918 3.434340000152588 15.23971748352051 3.496500015258789 L 14.0787181854248 4.666500091552734 C 14.02041816711426 4.725699901580811 13.94242763519287 4.758299827575684 13.85911750793457 4.758299827575684 Z" fill="#000000" stroke="none" stroke-width="1" stroke-miterlimit="10" stroke-linecap="butt" /></svg>';
const String _svg_suin66 =
    '<svg viewBox="337.9 3.7 17.0 10.7" ><path transform="translate(337.87, 3.67)" d="M 16.00020027160645 10.6668004989624 L 15.00029945373535 10.6668004989624 C 14.44894981384277 10.6668004989624 14.00039958953857 10.2182502746582 14.00039958953857 9.666900634765625 L 14.00039958953857 0.9998999834060669 C 14.00039958953857 0.4485500156879425 14.44894981384277 0 15.00029945373535 0 L 16.00020027160645 0 C 16.55154991149902 0 17.00010108947754 0.4485500156879425 17.00010108947754 0.9998999834060669 L 17.00010108947754 9.666900634765625 C 17.00010108947754 10.2182502746582 16.55154991149902 10.6668004989624 16.00020027160645 10.6668004989624 Z M 11.33369922637939 10.6668004989624 L 10.33290004730225 10.6668004989624 C 9.781549453735352 10.6668004989624 9.332999229431152 10.2182502746582 9.332999229431152 9.666900634765625 L 9.332999229431152 3.333600044250488 C 9.332999229431152 2.782249927520752 9.781549453735352 2.333699941635132 10.33290004730225 2.333699941635132 L 11.33369922637939 2.333699941635132 C 11.88504981994629 2.333699941635132 12.33360004425049 2.782249927520752 12.33360004425049 3.333600044250488 L 12.33360004425049 9.666900634765625 C 12.33360004425049 10.2182502746582 11.88504981994629 10.6668004989624 11.33369922637939 10.6668004989624 Z M 6.666300296783447 10.6668004989624 L 5.666399955749512 10.6668004989624 C 5.115049839019775 10.6668004989624 4.666500091552734 10.2182502746582 4.666500091552734 9.666900634765625 L 4.666500091552734 5.66640043258667 C 4.666500091552734 5.115050315856934 5.115049839019775 4.666500091552734 5.666399955749512 4.666500091552734 L 6.666300296783447 4.666500091552734 C 7.218140125274658 4.666500091552734 7.667099952697754 5.115050315856934 7.667099952697754 5.66640043258667 L 7.667099952697754 9.666900634765625 C 7.667099952697754 10.2182502746582 7.218140125274658 10.6668004989624 6.666300296783447 10.6668004989624 Z M 1.999799966812134 10.6668004989624 L 0.9998999834060669 10.6668004989624 C 0.4485500156879425 10.6668004989624 0 10.2182502746582 0 9.666900634765625 L 0 7.667100429534912 C 0 7.115260124206543 0.4485500156879425 6.666300296783447 0.9998999834060669 6.666300296783447 L 1.999799966812134 6.666300296783447 C 2.55115008354187 6.666300296783447 2.99970006942749 7.115260124206543 2.99970006942749 7.667100429534912 L 2.99970006942749 9.666900634765625 C 2.99970006942749 10.2182502746582 2.55115008354187 10.6668004989624 1.999799966812134 10.6668004989624 Z" fill="#000000" stroke="none" stroke-width="1" stroke-miterlimit="10" stroke-linecap="butt" /></svg>';
const String _svg_u0lq3x =
    '<svg viewBox="16.5 51.5 22.0 15.0" ><path transform="translate(16.5, 58.5)" d="M 0 0 L 22 0" fill="none" stroke="#707070" stroke-width="2" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(16.5, 51.5)" d="M 7 0 L 0 7" fill="none" stroke="#707070" stroke-width="2" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(16.5, 59.5)" d="M 0 0 L 7 7" fill="none" stroke="#707070" stroke-width="2" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_n49k6t =
    '<svg viewBox="0.0 0.0 36.0 33.0" ><path transform="translate(-19.96, -19.9)" d="M 54.85551452636719 19.89999961853027 C 54.73547744750977 19.89999961853027 54.61544418334961 19.89999961853027 54.49540710449219 19.95500183105469 L 20.76573944091797 34.86000061035156 C 19.80546379089355 35.1349983215332 19.6854305267334 36.28999710083008 20.52567100524902 36.78499984741211 L 30.24845886230469 40.85499954223633 L 26.70744132995605 46.68499755859375 L 33.1292839050293 43.4949951171875 L 37.63057708740234 52.40499877929688 C 37.87064361572266 52.7349967956543 38.23074722290039 52.89999771118164 38.59085083007812 52.89999771118164 C 39.07098770141602 52.89999771118164 39.49111175537109 52.625 39.67115783691406 52.18499755859375 L 55.93581771850586 21.21999931335449 C 56.1758918762207 20.55999946594238 55.57572174072266 19.89999961853027 54.85551452636719 19.89999961853027 Z M 38.6508674621582 49.48999786376953 L 34.92980194091797 42.0099983215332 L 50.4742546081543 25.06999778747559 L 31.86892318725586 39.31499862670898 L 23.70658111572266 35.85000228881836 L 52.39480972290039 23.14500045776367 L 38.6508674621582 49.48999786376953 Z" fill="#707070" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_lr91qk =
    '<svg viewBox="52.0 774.0 28.0 10.0" ><path transform="translate(52.0, 774.0)" d="M 0 0 L 28 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(52.0, 779.0)" d="M 0 0 L 28 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(52.0, 784.0)" d="M 0 0 L 28 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
