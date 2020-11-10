import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:math';

class User{
  final String userID;
  final picker = ImagePicker();
  File _image;
  String profileName;
  final String url;
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
        private = json['private'];

  Map<String, dynamic> toJSON() =>
      {
          'userID': userID,
          'profileName': profileName,
          'url': url,
          'googleID': googleID,
          'facebookID': facebookID,
          'bio': bio,
          'userName': userName,
          'profilePic': profilePic,
          'email': email,
          'followers' : followers,
          'numRated': numRated,
          'following' : following,
          'postIDs' : postIDs,
          'private' : private
      };

  Future<double> getAvgScore() async{
    double average = 0.0;
    for(int i =0; i<postIDs.length;i++)
      {
        if(postIDs[i]!= '')
          {
            String req = 'http://10.0.2.2:5000/getPostInfo/' + postIDs[i];
            http.Response res = await http.get(req);
            Map postDetails = jsonDecode(res.body.toString());
            if(postDetails['numRatings'].toDouble() < 1)
              {
                average += 0;
              }
            else{
                  average = average + (postDetails['cumulativeRating'].toDouble() / postDetails['numRatings'].toDouble());
                }
          }
      }
    if(postIDs.length > 0) {
      average = average / postIDs.length;
      }
      return average;
  }

  Future<http.Response> setProfileName(String p)
  {
    profileName = p;
    String request = 'http://10.0.2.2:5000/updateUserProfileName/' + userID + '/' + profileName ;
    return http.post(request, headers: <String, String>{'Content-Type': 'application/json',});
  }

  Future<http.Response> setPrivacy(bool p)
  {
    private = p;
    String request = 'http://10.0.2.2:5000/updateUserPrivacy/' + userID + '/' + private.toString() ;
    return http.post(request, headers: <String, String>{'Content-Type': 'application/json',});
  }

    Future<http.Response> setUserBio(String b)
    {
      bio = b;
      String request = 'http://10.0.2.2:5000/updateUserBio/' + userID + '/' + bio ;
      return http.post(request, headers: <String, String>{'Content-Type': 'application/json',});
    }

  Future<http.Response> setUserName(String u) async
  {
    //http.Response res = await isUserNameTaken(u);
   // if(res.body.isNotEmpty) {
      //print(isUserNameTaken(u));
      String uName = u;
      if (u[0] != '@') {
        uName = '@' + u;
      }
      userName = uName;
      String request = 'http://10.0.2.2:5000/updateUserName/' + userID + '/' +
          userName;
      return http.post(request,
          headers: <String, String>{'Content-Type': 'application/json',});
    //}

  }

  Future<http.Response> isUserNameTaken(String n)
  {
    String uName = n;
    if (uName.isNotEmpty && uName[0] != '@') {
        uName = '@' + n;
      }
      String request = 'http://10.0.2.2:5000/getUserByUserName/' + uName;
      return http.get(request, headers: <String, String>{'Content-Type': 'application/json',});

  }

  Future<http.Response> setProfilePic(String pic)
  {
    profilePic = pic;
    String request = 'http://10.0.2.2:5000/updateUserProfilePic/' + userID + '/' + profilePic ;
    return http.post(request, headers: <String, String>{'Content-Type': 'application/json',});
  }

      CircleAvatar createProfileAvatar({double radius = 60.0, double font = 64.0})
      {
        if(profilePic=="default")
        {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.red.shade800,
            child: Text(profileName[0], style: TextStyle(fontSize: font, color: Colors.white),),
          );
        }
        else{
          return CircleAvatar(
              radius: radius,
              backgroundImage: MemoryImage(base64Decode(profilePic)),
          );
        }
      }

      /*
   setProfilePicFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        final bytes = _image.readAsBytesSync();
        profilePic = base64Encode(bytes);
      } else {
        profilePic = "default";
      }
    setProfilePic(profilePic);

  }
*/

}
