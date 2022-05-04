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

class ChatScreen extends StatefulWidget {
  // this user is just you, currentUser
  // the other user is supplied from the outside, in type User because why not
  final User otherUser;
  ChatScreen(this.otherUser);
  
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // final User otherUser = widget.otherUser;
  List messageList = [];

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: BackButton(
            // color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(widget.otherUser.profileName),
          actions: <Widget>[]),
      body: ListView(padding: const EdgeInsets.all(8), children: <Widget>[
        // _buildList(),
      ]),
    );
  }
}