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
import 'package:woolala_app/widgets/bottom_nav.dart';

class FollowingListScreen extends StatefulWidget {
  final String userEmail;

  FollowingListScreen(this.userEmail);

  @override
  _FollowingListScreenState createState() => _FollowingListScreenState();
}

class _FollowingListScreenState extends State<FollowingListScreen> {
  User currentProfile;
  List followingList = new List();
  List followingEmailList = new List();
  List followingUserNameList = new List();

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

  Future<String> getUserName(String userID) async {
    http.Response res = await http.get(domain + "/getUser/" + userID);
    Map userMap = jsonDecode(res.body.toString());
    return User.fromJSON(userMap).userName;
  }

  listbuilder() async {
    currentProfile = await getDoesUserExists(widget.userEmail);
    print(currentProfile.profileName);
    List tempFollowingList = new List();
    tempFollowingList = currentProfile.following;
    print(tempFollowingList);

    for (int i = 0; i < tempFollowingList.length; i++) {
      String tempProfileName = await getProfileName(tempFollowingList[i]);
      String tempUserEmail = await getUserEmail(tempFollowingList[i]);
      String tempUserName = await getUserName(tempFollowingList[i]);
      followingList.add(tempProfileName);
      followingEmailList.add(tempUserEmail);
      followingUserNameList.add(tempUserName);
    }
    return followingList;
    //print(followerList);
  }

  Widget _buildList() {
    return FutureBuilder(
      future: listbuilder(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            key: ValueKey("ListView"),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: followingList.length,
            itemBuilder: (BuildContext context, int index) {
              return new ListTile(
                leading: CircleAvatar(
                  child: Text(followingList[index][0]),
                ),
                title: Text(followingList[index]),
                subtitle: Text(followingUserNameList[index]),
                trailing: Wrap(
                  spacing: 12,
                  children: <Widget>[
                    new Container(
                      child: new IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ProfilePage(followingEmailList[index])));
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("No Results"));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    BottomNav bottomBar = BottomNav(context);
    return Scaffold(
      appBar: AppBar(
          leading: BackButton(
              color: Colors.white,
              onPressed: () {
                //(Navigator.pushReplacementNamed(context, '/profile'))
                Navigator.pop(context);
              }),
          title: Text("Following"),
          actions: <Widget>[]),
      body: ListView(padding: const EdgeInsets.all(8), children: <Widget>[
        _buildList(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) {
            bottomBar.switchPage(index, context);
          },
          items: bottomBar.bottom_items),
    );
  }
}
