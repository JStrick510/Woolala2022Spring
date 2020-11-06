import 'package:http/http.dart' as http;
import 'dart:convert';

class User{
  final String userID;
  String profileName;
  final String url;
  final String googleID;
  final String facebookID;
  String bio;
  String userName;
  String profilePic;
  final String email;
  int numPosts;
  int numFollowers;
  int numRated;

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
    this.numPosts,
    this.numFollowers,
    this.numRated
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
        numPosts = json['numPosts'],
        numFollowers = json['numFollowers'],
        numRated = json['numRated'];

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
          'numPosts' : numPosts,
          'numFollowers' : numFollowers,
          'numRated': numRated
      };


    Future<http.Response> setUserBio(String b)
    {
      String request = 'http://10.0.2.2:5000/updateUserBio/' + userID + '/' + b ;
      return http.post(request, headers: <String, String>{'Content-Type': 'application/json',});
    }



}



