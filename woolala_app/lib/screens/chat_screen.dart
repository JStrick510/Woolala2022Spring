import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/screens/search_screen.dart';
import 'package:woolala_app/screens/conversation_list_screen.dart';
import 'package:woolala_app/main.dart';
import 'package:woolala_app/models/conversation.dart';
import 'package:woolala_app/models/user.dart';
import 'package:woolala_app/models/message.dart';
import 'package:woolala_app/widgets/bottom_nav.dart';

class ChatScreen extends StatefulWidget {
  final String thisUser;
  final String otherUser;
  ChatScreen(this.thisUser, this.otherUser);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  User currentProfile;
  User otherProfile;
  List messageList = [];

  @override 
  initState() {
    super.initState();
    // TODO
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
        // _buildList(),
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