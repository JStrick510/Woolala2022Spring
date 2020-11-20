import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/screens/profile_screen.dart';
import 'package:woolala_app/screens/homepage_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:woolala_app/main.dart';

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
  void initState() {
    super.initState();
  }

  Widget score(postID) {
    return rated
        ? FutureBuilder(
            future: getPost(widget.postID),
            builder: (context, postInfo) {
              if (postInfo.hasData) {
                return Stack(children: [
                  Container(
                      width: 60,
                      decoration: new BoxDecoration(
                          border: new Border.all(
                              width: 20, color: Colors.transparent),
                          borderRadius: const BorderRadius.all(
                              const Radius.circular(20.0)),
                          color: new Color.fromRGBO(100, 100, 100, 0.75))),
                  Positioned(
                      bottom: 25,
                      left: 21,
                      child: Text(
                        'Avg:',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      )),
                  Positioned(
                      bottom: 5,
                      left: 12,
                      child: Text(
                        postInfo.data[4].toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ))
                ]);
              } else {
                return CircularProgressIndicator();
              }
            })
        : Container();
  }

  var startPos;
  var distance = 0.0;
  var stars = 2.5;
  bool rated = false;

  @override
  Widget build(BuildContext context) {

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
              future: getUserFromDB(postInfo.data[2]),
              builder: (context, userInfo) {
                if (userInfo.hasData) {
                  return Column(children: <Widget>[
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
                                                  builder:
                                                      (BuildContext context) =>
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
                            Align(
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.more_vert))
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        )),
                    GestureDetector(
                        child: Stack(children: [
                          postInfo.data[0],
                          Positioned(
                              bottom: 10, left: 10, child: score(widget.postID))
                        ]),
                        onHorizontalDragStart:
                            (DragStartDetails dragStartDetails) {
                          if (!rated) {
                            startPos = dragStartDetails.globalPosition.dx;
                          }
                        },
                        onHorizontalDragUpdate:
                            (DragUpdateDetails dragUpdateDetails) {
                          if (!rated) {
                            distance =
                                dragUpdateDetails.globalPosition.dx - startPos;

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
                        onHorizontalDragEnd: (DragEndDetails dragEndDetails) {
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
                        child: Column(children: <Widget>[
                          Center(
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                new IconButton(
                                  icon: Icon(Icons.share),
                                  iconSize: 28,
                                ),
                                starSlider(widget.postID, stars, rated),
                                new IconButton(
                                  icon: Icon(Icons.add_shopping_cart),
                                  iconSize: 28,
                                ),
                              ])),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 2.0),
                                child: Text(
                                  currentUser.userName,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 2.0),
                                  child: Text(
                                    postInfo.data[1],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ))),
                        ])),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 2.0),
                            child: Text(
                              postInfo.data[3],
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ))),
                  ]);
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
