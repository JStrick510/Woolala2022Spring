//import 'dart:typed_data';
//import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:flutter_rating_bar/flutter_rating_bar.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
//import 'package:share/share.dart';
import 'package:woolala_app/screens/login_screen.dart';
//import 'package:woolala_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:mongo_dart/mongo_dart.dart' as mongo;
//import 'dart:io' as Io;
//import 'package:audioplayers/src/audio_cache.dart';
//import 'package:audioplayers/audioplayers.dart';
//import 'dart:collection';
//import 'package:pull_to_refresh/pull_to_refresh.dart';
//import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

import 'dart:io';
//import 'package:woolala_app/screens/login_screen.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:woolala_app/screens/post_screen.dart';
import 'package:woolala_app/screens/profile_screen.dart';
import 'package:woolala_app/screens/homepage_screen.dart';
//import 'package:woolala_app/screens/search_screen.dart';
//import 'package:woolala_app/widgets/bottom_nav.dart';
import 'package:woolala_app/main.dart';
import 'package:screenshot/screenshot.dart';
import 'package:social_share/social_share.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
//import 'package:image/image.dart' as ui;
//import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';

// This entire class is the widget that will populate the feed on the homepage

class FeedCard extends StatefulWidget {
   FeedCard(String postID, List rated) {
    this.postID = postID;
    this.ratedPosts = rated;
  }

  var postID;
  var ratedPosts;

  @override
  _FeedCardState createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
//(String postID)
  //final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  var startPos;
  var distance = 0.0;
  var stars = 2.5;
  bool rated = false;
  Icon wouldBuy = Icon(Icons.add_shopping_cart);

  final CarouselController _controller = CarouselController();

  void initState() {
    checkWouldBuy(currentUser.userID, widget.postID);
    super.initState();
  }

  // This widget is what appears with the average score after a post is rated
  Widget score(postID) {
    return rated
        ? FutureBuilder(
            future: getPost(widget.postID),
            builder: (context, postInfo) {
              if (postInfo.hasData) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      // decoration: BoxDecoration(
                      //   //to debug container position
                      //   border: Border.all(color: Colors.black),
                      // ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        './assets/logos/NXT_logo.png',
                        height: 40,
                        width: 100,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    Container(
                      width: 75,
                      height: 25,
                      decoration: new BoxDecoration(
                          border: new Border.all(
                              width: 10, color: Colors.transparent),
                          borderRadius: const BorderRadius.all(
                              const Radius.circular(20.0)),
                          color: new Color.fromRGBO(100, 100, 100, 0.90)),
                    ),
                    Text(
                      postInfo.data[3].toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ],
                );
              } else {
                return CircularProgressIndicator();
              }
            })
        : Container();
  }

  //Uint8List _originalImage;

  Future<File> convertImageToFile(String imagePath) async {
    final byteData = await rootBundle.load('assets/$imagePath');

    final file = File('${(await getTemporaryDirectory()).path}/$imagePath');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<http.Response> addWouldBuy(String userID, String postID) {
    return http.post(
      Uri.parse(domain +
          '/wouldBuy/' +
          postID.toString() +
          '/' +
          userID.toString() +
          '/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({}),
    );
  }

  Future<http.Response> removeWouldBuy(String userID, String postID) {
    return http.post(
      Uri.parse(domain +
          '/removeWouldBuy/' +
          postID.toString() +
          '/' +
          userID.toString() +
          '/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({}),
    );
  }

  void checkWouldBuy(String userID, String postID) async {
    http.Response res = await http
        .get(Uri.parse(domain + '/checkWouldBuy/' + postID.toString()));
    String wouldBuyList = res.body.toString();
    if (wouldBuyList.contains(userID))
      wouldBuy = Icon(Icons.remove_shopping_cart);
    else
      wouldBuy = Icon(Icons.add_shopping_cart);
  }

//final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  void showReportSuccess(bool value, BuildContext context) {
    if (value) {
      setState(() {
        SnackBar successSB = SnackBar(
          content: Text("Post Reported Successfully"),
        );
        Scaffold.of(context).showSnackBar(successSB);
      });
    } else {
      setState(() {
        SnackBar failSB = SnackBar(
          content: Text("Failed to Report Post"),
        );
        Scaffold.of(context).showSnackBar(failSB);
      });
    }
  }

  void showDeletionSuccess(bool value, BuildContext context) {
    if (value) {
      setState(() {
        SnackBar successSB = SnackBar(
          content: Text("Post Deleted Successfully"),
        );
        Scaffold.of(context).showSnackBar(successSB);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenshotController sc = new ScreenshotController();
    for (int i = 0; i < widget.ratedPosts.length; i++) {
      if (widget.ratedPosts[i][0] == widget.postID) {
        rated = true;
        stars = double.parse(widget.ratedPosts[i][1]);
        break;
      }
    }
    return FutureBuilder(
      future: getPost(widget.postID),
      builder: (context, postInfo) {
        if (postInfo.hasData) {
          return FutureBuilder(
              future: getUserFromDB(postInfo.data[1]),
              builder: (context, userInfo) {
                if (userInfo.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(2),
                          color: Colors.white,
                          width: double.infinity,
                          height: 35.0,
                          child: Row(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Padding(
                                      child: userInfo.data.createProfileAvatar(
                                          radius: 15.0, font: 18.0),
                                      padding: EdgeInsets.all(5)),
                                  GestureDetector(
                                      onTap: () => {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        ProfilePage(userInfo
                                                            .data.email)))
                                          },
                                      child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(userInfo.data.profileName,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16)))),
                                ],
                              ),
                              PopupMenuButton<String>(
                                onSelected: (String result) async {
                                  switch (result) {
                                    case 'Report Post':
                                      http.Response res = await reportPost(
                                          widget.postID,
                                          currentUser.userID,
                                          postInfo.data[2],
                                          postInfo.data[1]);
                                      showReportSuccess(
                                          res.body.isNotEmpty, context);
                                      http.Response reportCheck =
                                          await getReports(
                                              widget.postID, postInfo.data[1]);
                                      showDeletionSuccess(
                                          (reportCheck.body.isNotEmpty &&
                                              reportCheck.statusCode != 400),
                                          context);
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return {'Report Post'}.map((String choice) {
                                    return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(choice),
                                    );
                                  }).toList();
                                },
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                        ),
                        GestureDetector(
                            child: Column(
                            children: <Widget>[
                              CarouselSlider(
                                items: postInfo.data[5],
                                options: CarouselOptions(enlargeCenterPage: true, height: 200),
                                carouselController: _controller,
                                ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  ...Iterable<int>.generate(postInfo.data[5].length).map(
                                        (int pageIndex) => Flexible(
                                      child: ElevatedButton(
                                          onPressed: () => _controller.animateToPage(pageIndex),
                                          child: postInfo.data[5][pageIndex],
                                          style: ElevatedButton.styleFrom(
                                              fixedSize: const Size(80, 80)),
                                      ),
                                    ),
                                  ),
                                ],
                              )]
                            ),
                            onHorizontalDragStart:
                                (DragStartDetails dragStartDetails) {
                              if (!rated) {
                                startPos = dragStartDetails.globalPosition.dx;
                              }
                            },
                            onHorizontalDragUpdate:
                                (DragUpdateDetails dragUpdateDetails) {
                              if (!rated) {
                                distance = dragUpdateDetails.globalPosition.dx -
                                    startPos;

                                if (distance < -150)
                                  stars = 0.0;
                                else if (distance > -150 && distance < -120)
                                  stars = 0.5;
                                else if (distance > -120 && distance < -90)
                                  stars = 1.0;
                                else if (distance > -90 && distance < -60)
                                  stars = 1.5;
                                else if (distance > -60 && distance < -30)
                                  stars = 2.0;
                                if (distance > -30 && distance < 30)
                                  stars = 2.5;
                                else if (distance > 30 && distance < 60)
                                  stars = 3.0;
                                else if (distance > 60 && distance < 90)
                                  stars = 3.5;
                                else if (distance > 90 && distance < 120)
                                  stars = 4.0;
                                else if (distance > 120 && distance < 150)
                                  stars = 4.5;
                                else if (distance > 150) stars = 5.0;
                                setState(() {});
                              }
                            },
                            onHorizontalDragEnd:
                                (DragEndDetails dragEndDetails) {
                              if (!rated) {
                                ratePost(stars, widget.postID);
                                widget.ratedPosts
                                    .add([widget.postID, stars.toString()]);
                                rated = true;
                                setState(() {});
                              }
                            }),

                        Container(
                          alignment: Alignment(-1.0, 0.0),
                          child: Column(
                            children: <Widget>[
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    new IconButton(
                                      icon: Icon(Icons.share),
                                      iconSize: 28,
                                      onPressed: () async {
                                        await sc.capture().then((image) async {
                                          Directory tempDir =
                                              await getTemporaryDirectory();
                                          String filePath =
                                              '${tempDir.path}/tmp_img.jpg';
                                          await File(filePath)
                                              .writeAsBytes(image);
                                          await SocialShare.shareOptions(
                                            "Shared from ChooseNXT App",
                                            imagePath: filePath,
                                          ).then((data) {
                                            print(data);
                                          });

                                          //facebook appId is mandatory for android or else share won't work
                                          // Platform.isAndroid
                                          //     ? SocialShare.shareFacebookStory(
                                          //             _originalImage.path,
                                          //             "#ffffff",
                                          //             "#000000",
                                          //     "https://deep-link-url",
                                          //     appId: "457421962253693")
                                          //         .then((data) {
                                          //         print(data);
                                          //       })
                                          //     : SocialShare.shareFacebookStory(
                                          //             _originalImage.path,
                                          //             "#ffffff",
                                          //             "#000000",
                                          //     "https://deep-link-url")
                                          //         .then((data) {
                                          //         print(data);
                                          //       });
                                        });
                                      },
                                      // child: Text("Share Options"),
                                    ),
                                    starSlider(widget.postID, stars, rated),
                                    new IconButton(
                                      icon: wouldBuy,
                                      iconSize: 28,
                                      onPressed: () {
                                        setState(() {
                                          if (wouldBuy.icon ==
                                              Icons.remove_shopping_cart) {
                                            wouldBuy =
                                                Icon(Icons.add_shopping_cart);
                                            removeWouldBuy(currentUser.userID,
                                                widget.postID);
                                          } else {
                                            wouldBuy = Icon(
                                                Icons.remove_shopping_cart);
                                            addWouldBuy(currentUser.userID,
                                                widget.postID);
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                //remove username from posts
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 2.0),
                                  child: Text(
                                    userInfo.data.profileName,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      10.0, 1.0, 10.0, 15.0),
                                  child: Text(
                                    postInfo.data[0],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          //remove date from posts
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 2.0),
                            child: Text(
                              postInfo.data[2],
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              });
        } else if (postInfo.hasError) {
          return Container();
        } else {
          return SizedBox(
            child: Center(child: CircularProgressIndicator()),
          );
          // return Container();
        }
      },
    );
  }
}
