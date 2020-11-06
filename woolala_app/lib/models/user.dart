import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  Future<http.Response> setProfileName(String p)
  {
    profileName = p;
    String request = 'http://10.0.2.2:5000/updateUserProfileName/' + userID + '/' + profileName ;
    return http.post(request, headers: <String, String>{'Content-Type': 'application/json',});
  }

    Future<http.Response> setUserBio(String b)
    {
      bio = b;
      String request = 'http://10.0.2.2:5000/updateUserBio/' + userID + '/' + bio ;
      return http.post(request, headers: <String, String>{'Content-Type': 'application/json',});
    }

  Future<http.Response> setProfilePic(String pic)
  {
    profilePic = pic;
    String request = 'http://10.0.2.2:5000/updateUserProfilePic/' + userID + '/' + profilePic ;
    return http.post(request, headers: <String, String>{'Content-Type': 'application/json',});
  }

      CircleAvatar createProfileAvatar()
      {
        if(profilePic=="default")
        {
          return CircleAvatar(
            radius: 60.0,
            backgroundColor: Colors.red.shade800,
            child: Text(profileName[0], style: TextStyle(fontSize: 64.0, color: Colors.white),),
          );
        }
        else{
          return CircleAvatar(
              radius: 60.0,
              backgroundImage: MemoryImage(base64Decode(profilePic)),
          );
        }
      }

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


}



