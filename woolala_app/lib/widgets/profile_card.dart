//import 'dart:ui';

import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:flutter_rating_bar/flutter_rating_bar.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:path_provider/path_provider.dart';
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

import 'dart:io';
//import 'dart:typed_data';
//import 'package:woolala_app/screens/login_screen.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:woolala_app/screens/post_screen.dart';
import 'package:woolala_app/screens/profile_screen.dart';
import 'package:woolala_app/screens/homepage_screen.dart';
//import 'package:woolala_app/screens/search_screen.dart';
import 'package:woolala_app/screens/wouldbuy_list_screen.dart';
//import 'package:woolala_app/widgets/bottom_nav.dart';
import 'package:woolala_app/main.dart';
import 'package:screenshot/screenshot.dart';
import 'package:social_share/social_share.dart';

import 'package:carousel_slider/carousel_slider.dart';

Future<http.Response> deletePost(String postID, String userID) {
  return http.post(
    Uri.parse(domain + '/deleteOnePost/' + postID + '/' + userID),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({}),
  );
}

class OwnFeedCard extends StatefulWidget {
  OwnFeedCard(String postID) {
    this.postID = postID;
    //this.ratedPosts = rated;
  }

  var postID;
  var ratedPosts;

  @override
  _OwnFeedCardState createState() => _OwnFeedCardState();
}

class _OwnFeedCardState extends State<OwnFeedCard> {
//(String postID)

  final CarouselController _controller = CarouselController();

  void initState() {
    super.initState();
    checkWouldBuy(currentUser.userID, widget.postID);
  }

  bool rated = false;
  void showReportSuccess(bool value, BuildContext context) {
    if (value) {
      setState(() {
        SnackBar successSB = SnackBar(
          content: Text("Post Deleted Successfully"),
        );
        Scaffold.of(context).showSnackBar(successSB);
      });
    } else {
      setState(() {
        SnackBar failSB = SnackBar(
          content: Text("Failed to Delete Post"),
        );
        Scaffold.of(context).showSnackBar(failSB);
      });
    }
  }

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

  var startPos;
  var distance = 0.0;
  var stars = 2.5;
  var tempWouldBuyList = [];
  var wouldBuyNameList = [];
  var wouldBuyEmailList = [];
  //Uint8List _originalImage;

  void checkWouldBuy(String userID, String postID) async {
    print("Post ID:" + postID);
    http.Response res = await http
        .get(Uri.parse(domain + '/checkWouldBuy/' + postID.toString()));
    tempWouldBuyList = json.decode(res.body.toString());

    if (tempWouldBuyList.length > 0) {
      for (int i = 0; i < tempWouldBuyList.length; i++) {
        http.Response res = await http.get(
            Uri.parse(domain + '/getUser/' + tempWouldBuyList[i].toString()));
        var user = json.decode(res.body.toString());
        wouldBuyNameList.add(user['profileName']);
        wouldBuyEmailList.add(user['email']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.postID);
    ScreenshotController sc = new ScreenshotController();
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
                                    case 'Delete Post':
                                      http.Response res = await deletePost(
                                          widget.postID, currentUser.userID);
                                      showReportSuccess(
                                          res.body.isNotEmpty, context);
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return {'Delete Post'}.map((String choice) {
                                    return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(choice),
                                    );
                                  }).toList();
                                },
                              )
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
                              startPos = dragStartDetails.globalPosition.dx;
                            },
                            onHorizontalDragUpdate:
                                (DragUpdateDetails dragUpdateDetails) {
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
                            },
                            onHorizontalDragEnd:
                                (DragEndDetails dragEndDetails) {
                              ratePost(stars, widget.postID);
                            }),
                        Container(
                          alignment: Alignment(-1.0, 0.0),
                          child: Column(
                            children: <Widget>[
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                        });
                                      },
                                    ),
                                    Text(
                                      "Scores: " + postInfo.data[4].toString(),
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "Avg: " +
                                          postInfo.data[3].toStringAsFixed(2),
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    new IconButton(
                                        icon: Icon(Icons.supervisor_account),
                                        iconSize: 28,
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WouldBuyListScreen(
                                                          widget.postID,
                                                          wouldBuyNameList,
                                                          wouldBuyEmailList)));
                                        }),
                                  ],
                                ),
                              ),
                              Align(
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
                                    postInfo.data[0], //was 1
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
        } else {
          return Container();
        }
      },
    );
  }
}
