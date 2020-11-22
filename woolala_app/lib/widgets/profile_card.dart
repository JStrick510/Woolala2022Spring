import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'dart:io' as Io;
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:collection';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'dart:io';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:woolala_app/screens/post_screen.dart';
import 'package:woolala_app/screens/profile_screen.dart';
import 'package:woolala_app/screens/homepage_screen.dart';
import 'package:woolala_app/screens/search_screen.dart';
import 'package:woolala_app/widgets/bottom_nav.dart';
import 'package:woolala_app/main.dart';

Future<http.Response> deletePost(String postID, String userID) {
  return http.post(
    domain + '/deleteOnePost/' + postID + '/' + userID,
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({}),
  );
}


class OwnFeedCard extends StatefulWidget {

  OwnFeedCard(String postID)
  {
    this.postID = postID;
  }

  var postID;

  @override
  _OwnFeedCardState createState() => _OwnFeedCardState();
}


class _OwnFeedCardState extends State<OwnFeedCard>{
//(String postID)

  void initState() {
    super.initState();

  }

  void showReportSuccess(bool value, BuildContext context) {
    if(value){
      setState(() {
        SnackBar successSB = SnackBar(content: Text("Post Deleted Successfully"),);
        Scaffold.of(context).showSnackBar(successSB);
      });
    }
    else{
      setState(() {
        SnackBar failSB = SnackBar(content: Text("Failed to Delete Post"),);
        Scaffold.of(context).showSnackBar(failSB);
      });
    }
  }

  var startPos;
  var distance = 0.0;
  var stars = 2.5;

  @override
  Widget build(BuildContext context) {
    print(widget.postID);
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
                                    padding: EdgeInsets.all(5)
                                ),
                                GestureDetector(
                                    onTap: () =>
                                    {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ProfilePage(userInfo.data.email)))
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(userInfo.data.profileName,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Colors.black, fontSize: 16
                                            )
                                        )
                                    )
                                ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              onSelected: (String result) async {
                                switch (result)  {
                                  case 'Delete Post':
                                    http.Response res = await deletePost(widget.postID, currentUser.userID);
                                    showReportSuccess(res.body.isNotEmpty, context);
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
                        )
                    ),
                    GestureDetector(child: postInfo.data[0],
                        onHorizontalDragStart: (
                            DragStartDetails dragStartDetails) {
                          startPos = dragStartDetails.globalPosition.dx;
                        },
                        onHorizontalDragUpdate: (
                            DragUpdateDetails dragUpdateDetails) {
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
                          else if (distance > 150)
                            stars = 5.0;
                          setState(() {});
                        },
                        onHorizontalDragEnd: (DragEndDetails dragEndDetails) {
                          ratePost(stars, widget.postID);
                        }),
                    Container(
                        alignment: Alignment(-1.0, 0.0),
                        child: Column(
                            children: <Widget>[
                              Center(
                                  child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        new IconButton(
                                          icon: Icon(Icons.share),
                                          iconSize: 28,
                                        ),
                                        starSlider(widget.postID, stars, true),
                                        new IconButton(
                                          icon: Icon(Icons.add_shopping_cart),
                                          iconSize: 28,
                                        ),
                                      ]
                                  )
                              ),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(10.0,4.0,10.0,2.0),
                                    child: Text(
                                      currentUser.userName,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15
                                      ),
                                    ),
                                  )
                              ),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                      padding: EdgeInsets.fromLTRB(10.0,1.0,10.0,2.0),
                                      child: Text(
                                        postInfo.data[1],
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 18,),
                                      )
                                  )
                              ),
                            ]
                        )
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:Padding(
                            padding: EdgeInsets.fromLTRB(10.0,1.0,10.0,2.0),
                            child:Text(
                              postInfo.data[3],
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                        )
                    ),
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
  }}