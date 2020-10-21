import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:woolala_app/screens/login_screen.dart';

Widget starSlider() => RatingBar(
  initialRating: 2.5,
  minRating: 0,
  direction: Axis.horizontal,
  allowHalfRating: true,
  itemCount: 5,
  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
  itemBuilder: (context, _) => Icon(
    Icons.star,
    color: Colors.amber,
  ),
  onRatingUpdate: (rating) {
    print(rating);
    //Changing rating here
  },
);



// Will be used anytime the post is rated
Future<http.Response> ratePost(double rating, int id) {
  return http.post(
    'http://10.0.2.2:5000/ratePost/'+id.toString()+'/'+rating.toString(),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
    }),
  );
}

// Will be used to make the post for the first time.
Future<http.Response> createPost(int id, String imageID, String date, String description, List comments, int userID) {
  return http.post(
    'http://10.0.2.2:5000/insertPost',
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'ID' : id,
      'UserID' : userID,
      'ImageID' : imageID,
      'Date' : date,
      'Description' : description,
      'Comments' : comments,
      'CumulativeRating' : 0,
      'NumRatings' : 0
    }),
  );
}

// Will be used to get info about the post
Future<http.Response> getPost(double id) {
  return http.get('http://10.0.2.2:5000/getPostInfo/'+id.toString());
}

class HomepageScreen extends StatelessWidget {
  GoogleSignIn googleSignIn = GoogleSignIn(clientId: "566232493002-qqkorq4nvfqu9o8es6relg6fe4mj01mm.apps.googleusercontent.com");

    var rating = 0.0;
    var postID = 0.0;




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Homepage'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () => startSignOut(context),
            child: Text("Sign Out"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          )
        ],
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 50),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.blue[900],
                  Colors.blue[700],
                  Colors.blue[400]
                ]
            ),
          ),
          child: Column(children: [starSlider()],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }

  void startSignOut(BuildContext context) {
    print("Sign Out");
    googleSignIn.signOut();

    //TODO:
    //Facebook here

    Navigator.pushReplacementNamed(context, '/');
  }

}
