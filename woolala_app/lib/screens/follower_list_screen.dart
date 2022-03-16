import 'package:flutter/material.dart';
import 'package:woolala_app/screens/login_screen.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
import 'package:woolala_app/models/user.dart';
import 'package:woolala_app/screens/profile_screen.dart';
import 'package:woolala_app/widgets/bottom_nav.dart';
//import 'package:woolala_app/main.dart';
import 'package:woolala_app/screens/following_list_screen.dart';

//Create Stateful Widget
class FollowerListScreen extends StatefulWidget {
  final String userEmail;
  FollowerListScreen(this.userEmail);
  @override
  _FollowerListScreenState createState() => _FollowerListScreenState();
}

class _FollowerListScreenState extends State<FollowerListScreen> {
  //Lists to build the ListView
  List followerNameList = [];
  User currentProfile;
  List followerList = [];
  List followerEmailList = [];
  List followerUserNameList = [];

  //Build the list Asynchronously
  listbuilder() async {
    //Make sure the user Exists
    currentProfile = await getDoesUserExists(widget.userEmail);

    //Follower list of the user
    List tempFollowerList = [];
    tempFollowerList = currentProfile.followers;

    //Go through the Follower List of userIDs and grab their profileName, email, and userName
    for (int i = 0; i < tempFollowerList.length; i++) {
      String tempProfileName = await getProfileName(tempFollowerList[i]);
      String tempUserEmail = await getUserEmail(tempFollowerList[i]);
      String tempUserName = await getUserName(tempFollowerList[i]);
      //Add each to their respective Lists
      followerList.add(tempProfileName);
      followerEmailList.add(tempUserEmail);
      followerUserNameList.add(tempUserName);
    }
    return followerList;
  }

  //Build the list using a Futurebuilder for Async
  Widget _buildList() {
    return FutureBuilder(
      future: listbuilder(),
      builder: (context, snapshot) {
        //Make sure the snapshot is valid without errors
        if (snapshot.hasData) {
          return ListView.builder(
            key: ValueKey("ListView"),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: followerList.length,
            itemBuilder: (BuildContext context, int index) {
              return new ListTile(
                //Create the circular avatar for the user
                leading: CircleAvatar(
                  child: Text(
                    followerList[index][0],
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.grey,
                ),
                title: Text(followerList[index]),
                subtitle: Text(followerUserNameList[index]),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ProfilePage(followerEmailList[index])));
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
              // color: Colors.white,
              onPressed: () =>
                  //(Navigator.pushReplacementNamed(context, '/profile'))
                  (Navigator.pop(context))),
          title: Text("Followers"),
          actions: <Widget>[]),
      body: ListView(padding: const EdgeInsets.all(8), children: <Widget>[
        _buildList(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          bottomBar.switchPage(index, context);
        },
        items: bottomBar.bottomItems,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
