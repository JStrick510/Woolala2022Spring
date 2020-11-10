import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:woolala_app/screens/homepage_screen.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:woolala_app/models/user.dart';
import 'package:woolala_app/screens/profile_screen.dart';
import 'package:woolala_app/models/user.dart';

class FollowerListScreen extends StatefulWidget {
  final String userEmail;
  FollowerListScreen(this.userEmail);
  @override
  _FollowerListScreenState createState() => _FollowerListScreenState();
}


class _FollowerListScreenState extends State<FollowerListScreen> {

  List followerNameList = new List();
  User currentProfile;
  List followerList = new List();
  List followerEmailList = new List();
  List followerUserNameList = new List();

  Future<String> getProfileName(String userID) async {
    http.Response res = await http.get(domain + "/getUser/" + userID);
    Map userMap = jsonDecode(res.body.toString());
    return User.fromJSON(userMap).profileName;
  }

  Future<String> getUserEmail(String userID) async {
    http.Response res = await http.get(domain + "/getUser/" + userID);
    Map userMap = jsonDecode(res.body.toString());
    return User.fromJSON(userMap).email;
  }

  Future<String>getUserName(String userID) async {
    http.Response res = await http.get(domain + "/getUser/" + userID);
    Map userMap = jsonDecode(res.body.toString());
    return User.fromJSON(userMap).userName;
  }

  listbuilder() async {
    currentProfile = await getDoesUserExists(widget.userEmail);
    print(currentProfile.profileName);
    List tempFollowerList = new List();
    tempFollowerList = currentProfile.followers;
    print(tempFollowerList);

    for(int i = 0; i < tempFollowerList.length; i++){
      String tempProfileName = await getProfileName(tempFollowerList[i]);
      String tempUserEmail = await getUserEmail(tempFollowerList[i]);
      String tempUserName = await getUserName(tempFollowerList[i]);
      followerList.add(tempProfileName);
      followerEmailList.add(tempUserEmail);
      followerUserNameList.add(tempUserName);
    }
    return followerList;
    //print(followerList);
  }

    Widget _buildList() {
    return FutureBuilder(
      future: listbuilder(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return ListView.builder(
            key: ValueKey("ListView"),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: followerList.length,
            itemBuilder: (BuildContext context, int index) {
              return new ListTile(
                leading: CircleAvatar(
                  child: Text(followerList[index][0]),
                ),
                title: Text(followerList[index]),
                subtitle: Text(followerUserNameList[index]),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProfilePage(followerEmailList[index])));
                },

              );
            },
          );
        }
        else if(snapshot.hasError){
          return Center(child: Text("No Results"));
        }
        else {
          return Center(child: CircularProgressIndicator());
        }

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: BackButton(
                color: Colors.white,
                onPressed: () =>
                //(Navigator.pushReplacementNamed(context, '/profile'))
                (Navigator.pop(context))
            ),
            title: Text("Followers"),
            actions: <Widget>[
            ]
        ),
        body: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              _buildList(),
            ]
        ),
        bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
      switchPage(index, context);
    },
    items: [
    BottomNavigationBarItem(
    icon: Icon(Icons.home, color: Colors.black),
    title: Text('Home', style: TextStyle(color: Colors.black)),
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.add_circle_outline, color: Colors.black),
    title: Text("New", style: TextStyle(color: Colors.black)),
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.person, color: Theme.of(context).primaryColor),
    title: Text("Profile", style: TextStyle(color: Theme.of(context).primaryColor)),
    ),
    ]
    ),
    );
  }
  void switchPage(int index, BuildContext context) {
    switch(index) {
      case 0: {
        Navigator.pushReplacementNamed(context, '/home');}
      break;
      case 1: {
        Navigator.pushReplacementNamed(context, '/imgup');}
      break;
    }
  }
  @override
  void initState() {
    super.initState();
  }
}