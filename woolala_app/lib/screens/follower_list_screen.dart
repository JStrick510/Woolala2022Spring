import 'package:flutter/material.dart';
import 'package:woolala_app/screens/login_screen.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
import 'package:woolala_app/models/user.dart';
import 'package:woolala_app/screens/profile_screen.dart';
import 'package:woolala_app/widgets/bottom_nav.dart';
//import 'package:woolala_app/main.dart';
import 'package:woolala_app/screens/following_list_screen.dart';
import 'package:woolala_app/screens/homepage_screen.dart'; // getUserFromDB(userID)
import 'package:woolala_app/screens/conversation_list_screen.dart'; // getUpdatedConvClient(userID)

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
  List followerUserIDList = [];
  List myClients = [];

  ScrollController _controller = new ScrollController();

  //Build the list Asynchronously
  listbuilder() async {
    //Make sure the user Exists
    currentProfile = await getDoesUserExists(widget.userEmail);

    //Follower list of the user
    List tempFollowerList = [];
    tempFollowerList = currentProfile.followers;
    List tmpList = await getUpdatedConvClient(currentUser.userID);
    myClients = tmpList[1];

    //Go through the Follower List of userIDs and grab their profileName, email, and userName
    for (int i = 0; i < tempFollowerList.length; i++) {
      // String tempProfileName = await getProfileName(tempFollowerList[i]);
      // String tempUserEmail = await getUserEmail(tempFollowerList[i]);
      // String tempUserName = await getUserName(tempFollowerList[i]);

      // no need to query the DB so many times, 1 time is enough
      User tempUser = await getUserFromDB(tempFollowerList[i]);
      followerList.add(tempUser.profileName);
      followerEmailList.add(tempUser.email);
      followerUserNameList.add(tempUser.userName);
      followerUserIDList.add(tempUser.userID);
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
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _controller,
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
                tileColor: (myClients.contains(followerUserIDList[index]))? Colors.yellow[100] : null,
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
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.black, //color was not asked to change but just in case
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
