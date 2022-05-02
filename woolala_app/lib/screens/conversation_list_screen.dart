import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/screens/search_screen.dart';
import 'package:woolala_app/screens/chat_screen.dart';
import 'package:woolala_app/main.dart';
import 'package:woolala_app/models/conversation.dart';
import 'package:woolala_app/models/user.dart';
import 'package:woolala_app/models/message.dart';
import 'package:woolala_app/widgets/bottom_nav.dart';

class ConversationListScreen extends StatefulWidget {
  final String userEmail;
  ConversationListScreen(this.userEmail);
  @override
  _ConversationListScreenState createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  List conversationNameList = [];
  List conversationList = [];
  List conversationEmailList = [];
  List conversationUserNameList = [];

  @override
  initState() {
    super.initState();
  }

  //Build the list Asynchronously
  conversationlistbuilder() async {
    // currentUser

    //Follower list of the user
    List tempConversationList = [];
    tempConversationList = currentUser.conversations;

    //Go through the Follower List of userIDs and grab their profileName, email, and userName
    for (int i = 0; i < tempConversationList.length; i++) {
      String tempProfileName = await getProfileName(tempConversationList[i]);
      // String tempUserEmail = await getUserEmail(tempConversationList[i]);
      String tempUserName = await getUserName(tempConversationList[i]);

      //Add each to their respective Lists
      conversationList.add(tempProfileName);
      // conversationEmailList.add(tempUserEmail);
      conversationUserNameList.add(tempUserName);
    }
    return conversationList;
  }

  //Build the list using a Futurebuilder for Async
  Widget _buildConversationList() {
    return FutureBuilder(
      future: conversationlistbuilder(),
      builder: (context, snapshot) {
        //Make sure the snapshot is valid without errors
        if (snapshot.hasData) {
          return ListView.builder(
            key: ValueKey("ListView"),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: conversationList.length,
            itemBuilder: (BuildContext context, int index) {
              return new ListTile(
                //Create the circular avatar for the user
                leading: CircleAvatar(
                  child: Text(
                    conversationList[index][0],
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.grey,
                ),
                title: Text(conversationList[index]),
                subtitle: Text(conversationUserNameList[index]),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ProfilePage(conversationEmailList[index])));
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
    bottomBar.brand = currentUser.brand;
    return Scaffold(
      appBar: AppBar(
          leading: BackButton(
            // color: Colors.white,
              onPressed: () {
                //(Navigator.pushReplacementNamed(context, '/profile'))
                Navigator.pop(context);
                // Navigator.pushReplacement(
                //     context,
                //     PageRouteBuilder(
                //       pageBuilder: (context, animation1, animation2) =>
                //           HomepageScreen(false,false,false),
                //       transitionDuration: Duration(seconds: 0),
                //     ));
              }),
          title: Text("Messages"),
          actions: <Widget>[]),
      body: ListView(padding: const EdgeInsets.all(8), children: <Widget>[
        _buildConversationList(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          bottomBar.switchPage(index, context);
        },
        items: bottomBar.getItems(),
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.black,
      ),
    );
  }
}