import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'dart:io';
import 'package:image_picker/image_picker.dart';
//import 'dart:math';
import 'package:woolala_app/main.dart';
//import 'package:woolala_app/screens/login_screen.dart';

class User {
  final String userID;
  final picker = ImagePicker();
  //File _image;
  String profileName;
  String url;
  final String googleID;
  final String facebookID;
  String bio;
  String userName;
  String profilePic;
  final String email;
  int numRated;
  List followers;
  List postIDs;
  List following;
  bool private;
  List ratedPosts;
  List blockedUsers;
  bool brand;

  User({
    this.userID,
    this.profileName,
    this.url,
    this.googleID,
    this.facebookID,
    this.bio,
    this.userName,
    this.profilePic,
    this.email,
    this.numRated,
    this.postIDs,
    this.following,
    this.private,
    this.followers,
    this.ratedPosts,
    this.blockedUsers,
    this.brand,
  });

  User.fromJSON(Map<String, dynamic> json)
      : userID = json['userID'],
        profileName = json['profileName'],
        url = json['url'],
        googleID = json['googleID'],
        facebookID = json['facebookID'],
        bio = json['bio'],
        userName = json['userName'],
        profilePic = json['profilePic'],
        email = json['email'],
        followers = json['followers'],
        numRated = json['numRated'],
        following = json['following'],
        postIDs = json['postIDs'],
        private = json['private'],
        ratedPosts = json['ratedPosts'],
        blockedUsers = json['blockedUsers'],
        brand = json['brand'];

  Map<String, dynamic> toJSON() => {
        'userID': userID,
        'profileName': profileName,
        'url': url,
        'googleID': googleID,
        'facebookID': facebookID,
        'bio': bio,
        'userName': userName,
        'profilePic': profilePic,
        'email': email,
        'followers': followers,
        'numRated': numRated,
        'following': following,
        'postIDs': postIDs,
        'private': private,
        'ratedPosts': ratedPosts,
        'blockedUsers': blockedUsers,
        'brand': brand,
      };

  Future<double> getAvgScore() async {
    double average = 0.0;
    for (int i = 0; i < postIDs.length; i++) {
      if (postIDs[i] != '') {
        String req = domain + '/getPostInfo/' + postIDs[i];
        http.Response res = await http.get(Uri.parse(req));
        Map postDetails = jsonDecode(res.body.toString());
        if (postDetails['numRatings'].toDouble() < 1) {
          average += 0;
        } else {
          average = average +
              (postDetails['cumulativeRating'].toDouble() /
                  postDetails['numRatings'].toDouble());
        }
      }
    }
    if (postIDs.length > 0) {
      average = average / postIDs.length;
    }
    return average;
  }

  Future<http.Response> setProfileName(String p) {
    profileName = p;
    String request =
        domain + '/updateUserProfileName/' + userID + '/' + profileName;
    return http.post(Uri.parse(request), headers: <String, String>{
      'Content-Type': 'application/json',
    });
  }

  Future<http.Response> setURL(String p) {
    url = p;
    String request = domain + '/updateURL/' + userID + '/' + url;
    return http.post(Uri.parse(request), headers: <String, String>{
      'Content-Type': 'application/json',
    });
  }

  Future<http.Response> setPrivacy(bool p) {
    private = p;
    String request =
        domain + '/updateUserPrivacy/' + userID + '/' + private.toString();
    return http.post(Uri.parse(request), headers: <String, String>{
      'Content-Type': 'application/json',
    });
  }

  Future<http.Response> setUserBio(String b) {
    bio = b;
    String request = domain + '/updateUserBio/' + userID + '/' + bio;
    return http.post(Uri.parse(request), headers: <String, String>{
      'Content-Type': 'application/json',
    });
  }

  Future<http.Response> setUserName(String u) async {
    String uName = u;
    if (u[0] != '@') {
      uName = '@' + u;
    }
    userName = uName;
    String request = domain + '/updateUserName/' + userID + '/' + userName;
    return http.post(Uri.parse(request), headers: <String, String>{
      'Content-Type': 'application/json',
    });
  }

  Future<http.Response> isUserNameTaken(String n) {
    String uName = n;
    if (uName.isNotEmpty && uName[0] != '@') {
      uName = '@' + n;
    }
    String request = domain + '/getUserByUserName/' + uName;
    return http.get(Uri.parse(request), headers: <String, String>{
      'Content-Type': 'application/json',
    });
  }

  Future<http.Response> setProfilePic(String pic) {
    profilePic = pic;
    //print("HERE");
    String request = domain + '/updateUserProfilePic/' + userID;
    //print(request);
    return http.post(
      Uri.parse(request),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'profilePic': profilePic,
      }),
    );
  }

  CircleAvatar createProfileAvatar({double radius = 60.0, double font = 64.0}) {
    //print("CREATE: "  + profilePic);
    if (profilePic == "default") {
      return CircleAvatar(
        radius: radius,
        // backgroundColor: Colors.red.shade800,
        backgroundColor: Colors.grey,
        child: (profileName.length > 1)
            ? Text(
                profileName[0],
                style: TextStyle(fontSize: font, color: Colors.white),
              )
            : Text(
                "",
                style: TextStyle(fontSize: font, color: Colors.white),
              ),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(base64Decode(profilePic)),
      );
    }
  }

  Future<http.Response> setBrand(bool ut) {
    private = ut;
    String request =
        domain + '/updateUserType/' + userID + '/' + private.toString();
    return http.post(Uri.parse(request), headers: <String, String>{
      'Content-Type': 'application/json',
    });
  }
}
