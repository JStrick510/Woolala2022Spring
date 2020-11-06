import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' as Io;
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:collection';


import 'dart:io';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:woolala_app/screens/post_screen.dart';
import 'package:woolala_app/screens/profile_screen.dart';
AudioPlayer advancedPlayer;

Widget starSlider(int postID) => RatingBar(
      initialRating: 2.5,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      unratedColor: Colors.black,
      itemSize: 30,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.blue,
      ),
      onRatingUpdate: (rating) {
        print(rating);
        //Changing rating here
        ratePost(rating, postID);
        //getFeed("cmpoaW5ja0BnbWFpbC5jb20=", "2020-10-28");
      },
    );

Widget card(int postID)
{
  return FutureBuilder(
    future: getPost(postID),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return Column(
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.all(0),
                  color: Colors.white,
                  width: double.infinity,
                  height: 35.0,
                  child: Row(children: <Widget>[
                    Padding(padding: EdgeInsets.all(5), child: Text(snapshot.data[1], textAlign: TextAlign.left, style: TextStyle(color: Colors.black, fontSize: 16))),
                    Align(alignment: Alignment.centerRight, child: Icon(Icons.more_vert))
                  ])
              ),
              snapshot.data[0],
              Padding(padding: EdgeInsets.all(5),child: Text(snapshot.data[2])),
              Center(child: starSlider(postID)),
              Container(
                margin: const EdgeInsets.all(8),
                color: Colors.grey,
                width: double.infinity,
                height: 1,)
            ]
        );
      }
      else {
        return CircularProgressIndicator();
      }
    },);
}



Future loadMusic(String sound) async {
  if(sound=="fuck") {
    advancedPlayer = await AudioCache().play("Sounds/ashfuck.mp3");
  }
   if(sound=="woolala")
   {
       advancedPlayer = await AudioCache().play("Sounds/woolalaAudio.mp3");
   }
}
// Will be used anytime the post is rated
Future<http.Response> ratePost(double rating, int id) {
  return http.post(
    'http://10.0.2.2:5000/ratePost/' + id.toString() + '/' + rating.toString(),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({}),
  );
}

// Will be used to make the post for the first time.
Future<http.Response> createPost(String postID, String image, String date,
    String caption, String userID, String userName) {
  return http.post(
    'http://10.0.2.2:5000/insertPost',
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'postID': postID,
      'userID': userID,
      'userName': userName,
      'image': image,
      'date': date,
      'caption': caption,
      'cumulativeRating': 0,
      'numRatings': 0
    }),
  );
}

// Will be used to get info about the post
Future<List> getPost(int id) async{
  http.Response res = await http.get('http://10.0.2.2:5000/getPostInfo/' + id.toString());
  Map info = jsonDecode(res.body.toString());
  final decodedBytes = base64Decode(info["image"]);
  var ret = [Image.memory(decodedBytes), info["userName"], info["caption"]];
  return ret;

  //DO THIS TO GET IMAGE

  // FutureBuilder(
  //   future: getPost(POSTID),
  //   builder: (context, snapshot) {
  //     if (snapshot.hasData) {
  //       return snapshot.data;
  //     } else {
  //       return CircularProgressIndicator();
  //     }
  //   },
  // );
}

Future<List> getFeed(String userID, String date) async
{
  http.Response res = await http.get('http://10.0.2.2:5000/getFeed/' + userID + "/" + date);
  return jsonDecode(res.body.toString())["postIDs"];
}


//final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class HomepageScreen extends StatefulWidget {
  final bool signedInWithGoogle;

  HomepageScreen(this.signedInWithGoogle);

  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen>{
    var rating = 0.0;
    var postID = 0.0;
    final List<int> postIDs = <int>[1, 2, 3, 4, 5, 6, 7, 8];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WooLaLa', style: TextStyle(fontSize: 25 ), textAlign: TextAlign.center,),
        key: ValueKey("homepage"),
        actions: <Widget>[
          IconButton (
            icon: Icon(Icons.search),
            key: ValueKey("Search"),
            color: Colors.white,
            onPressed: () => Navigator.pushReplacementNamed(context, '/search'),
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => startSignOut(context),
          )
        ],
      ),
      body: Center(
        child: FutureBuilder(
            future: getFeed(currentUser.userID, "2020-10-28"),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
               return  ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return card(snapshot.data[index]);
                    });
              } else {
                return CircularProgressIndicator();
              }
              },)

      ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) {
            switchPage(index, context);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Theme.of(context).primaryColor,),
              title: Text('Home', style: TextStyle(color: Theme.of(context).primaryColor),),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, key: ValueKey("Make Post"), color: Colors.white,),
              title: Text("New", style: TextStyle(color: Colors.white),),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, key: ValueKey("Profile"), color: Colors.white,),
              title: Text("Profile", style: TextStyle(color: Colors.white),),

            ),
          ],
          backgroundColor: Colors.blueGrey[400],
      ),
    );
  }

   void switchPage(int index, BuildContext context) {
      switch(index) {
        case 1: {
          Navigator.pushReplacementNamed(context, '/imgup');}
        break;
        case 2: {
          Navigator.pushReplacementNamed(context, '/profile');}
        break;
      }
  }
  void startSignOut(BuildContext context) {
    print("Sign Out");
    if (widget.signedInWithGoogle) {
      googleLogoutUser();
      Navigator.pushReplacementNamed(context, '/');
    }
    else
    {

       // FacebookLogin facebookLogin = FacebookLogin();
        //facebookLogin.logOut();
        Navigator.pushReplacementNamed(context, '/');

    }
  }
}
