import 'package:flutter/material.dart';
import 'dart:math';
import '../globals.dart' as globals;
import 'package:provider/provider.dart';

class PopUpOption {
  PopUpOption(
      {@required this.name,
      @required this.onTap,
      this.fontColor = Colors.black});

  final String name;
  final Function onTap;
  final Color fontColor;
}

class PopUpOptionsProvider extends ChangeNotifier {
  final double totalOffset;

  PopUpOptionsProvider({@required this.totalOffset}) {
    currentOffset = totalOffset;
    slideUp();
  }

  double currentOffset;

  Future<void> slideUp() async {
    while (currentOffset > 0) {
      currentOffset -= 6;
      notifyListeners();
      await Future.delayed(Duration(milliseconds: 1));
    }
  }

  Future<void> slideDown() async {
    while (currentOffset < totalOffset) {
      currentOffset += 6;
      notifyListeners();
      await Future.delayed(Duration(milliseconds: 1));
    }
  }
}

class PopUpOptionsPage extends StatefulWidget {
  const PopUpOptionsPage({@required this.popUpOptions});

  final List<PopUpOption> popUpOptions;

  @override
  State<PopUpOptionsPage> createState() => _PopUpOptionsPageState();
}

class _PopUpOptionsPageState extends State<PopUpOptionsPage> {
  double listHeight;
  double padding;
  double maxOffset;

  @override
  void initState() {
    super.initState();
    padding = .06 * globals.size.width;
    listHeight = .28 * globals.size.height;
    maxOffset = listHeight + padding;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => PopUpOptionsProvider(totalOffset: maxOffset),
        child:
            Consumer<PopUpOptionsProvider>(builder: (context, provider, child) {
          return Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  GestureDetector(
                      child: Container(
                        // opacity is function of offset, get's darker when sliding up,
                        // less dark when sliding down
                        color: Colors.black.withOpacity(max(
                            .8 - .8 * (provider.currentOffset / maxOffset), 0)),
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      onTap: () async {
                        await provider.slideDown();
                        Navigator.pop(context);
                      }),
                  Transform.translate(
                    offset: Offset(0, provider.currentOffset),
                    child: Container(
                      padding: EdgeInsets.all(
                        padding,
                      ),
                      child: PopUpOptionsList(
                          popUpOptions: widget.popUpOptions,
                          height: listHeight),
                    ),
                  )
                ],
              ));
        }));
  }
}

class PopUpOptionsList extends StatelessWidget {
  const PopUpOptionsList({
    Key key,
    @required this.popUpOptions,
    @required this.height,
  }) : super(key: key);

  final List<PopUpOption> popUpOptions;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PopUpOptionsContainer(
              child: Container(
            height: .08 * globals.size.height * popUpOptions.length,
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(0),
                itemCount: popUpOptions.length,
                itemBuilder: (context, index) => GestureDetector(
                    child: GestureDetector(
                        child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: .025 * globals.size.width),
                            decoration: BoxDecoration(
                                border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[700],
                                width:
                                    index != popUpOptions.length - 1 ? .8 : 0,
                              ),
                            )),
                            width: double.infinity,
                            height: .08 * globals.size.height,
                            child: Center(
                                child: Text(popUpOptions[index].name,
                                    style: TextStyle(
                                        fontSize: .022 * globals.size.height,
                                        color:
                                            popUpOptions[index].fontColor)))),
                        onTap: () async {
                          Provider.of<PopUpOptionsProvider>(context,
                                  listen: false)
                              .slideDown();
                          await popUpOptions[index].onTap();

                          Navigator.pop(context);
                        }))),
          )),
          PopUpOptionsContainer(
              child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: .08 * globals.size.height,
              child: Center(
                child: Text("Cancel",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: .022 * globals.size.height)),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class PopUpOptionsContainer extends StatelessWidget {
  const PopUpOptionsContainer({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.all(Radius.circular(.025 * globals.size.height))),
      width: double.infinity,
      child: child,
    );
  }
}
