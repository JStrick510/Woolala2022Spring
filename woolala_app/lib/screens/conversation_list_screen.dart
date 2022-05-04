import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/screens/search_screen.dart';
import 'package:woolala_app/screens/homepage_screen.dart';
import 'package:woolala_app/screens/chat_screen.dart';
import 'package:woolala_app/screens/profile_screen.dart';
import 'package:woolala_app/screens/following_list_screen.dart';
import 'package:woolala_app/main.dart';
import 'package:woolala_app/models/conversation.dart';
import 'package:woolala_app/models/user.dart';
import 'package:woolala_app/models/message.dart';

class ConversationListScreen extends StatefulWidget {
  // no need to pass argument of a user because you always only see your own conv list screen
  // accessed with currentUser in login_screen.dart, just like in everywhere else
  ConversationListScreen();
  
  @override
  _ConversationListScreenState createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  // list of users you have a chat with, fetched at getCurrentConvList(), called at the beginning of build
  // in User type, so it's easy to access relevant info (name, userName, etc, to build a ListTile with)
  List<User> otherUserList = [];
  List<User> clientUserList = [];
  List<User> combinedList = [];
  int numOfClients;

  getCurrentConvList() async {
    // initialize List<User>s here
    String myID = currentUser.userID;
    // need to fetch the latest info because it may change and User currentUser isn't updated
    List tmpList = await getUpdatedConvClient(myID);
    List convIDs = tmpList[0];
    List currentClients = tmpList[1];
    // some clever dart syntax because it looks smarter than indexed for loops
    for (String convID in convIDs) {
      User tempUser = await getUserFromDB(conversationGetTheOther(convID, myID));
      if (tempUser != null) {
        if (currentClients.contains(tempUser.userID)) {
          clientUserList.add(tempUser);
        } else {
          otherUserList.add(tempUser);
        }
      }
    }
    numOfClients = clientUserList.length;
    combinedList = List.from(clientUserList)..addAll(otherUserList);
    print(clientUserList.length.toString() + " " + otherUserList.length.toString()+" "+combinedList.length.toString());
  }

  Widget _buildList() {
    return FutureBuilder(
      future: getCurrentConvList(),
      builder: (context, snapshot) {
        // if (snapshot.hasData) {
          return ListView.builder(
            key: ValueKey("ListView"),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: combinedList.length,
            itemBuilder: (BuildContext context, int index) {
              return new ListTile(
                leading: CircleAvatar(
                  child: Text(
                    combinedList[index].profileName[0],
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.grey,
                ),
                tileColor: (index<numOfClients)? Colors.yellow : null,
                title: Text(combinedList[index].profileName),
                subtitle: Text(combinedList[index].userName),
                onTap: () {
                  print("You clicked " + combinedList[index].profileName+", entering chat");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) =>
                      ChatScreen(combinedList[index])));
                },
              );
            }
          );
        // } else if (snapshot.hasError) {
        //   return Center(child: Text("No Results"));
        // } else {
        //   print("snapshot has no data or error. Something's wrong");
        //   return Center(child: CircularProgressIndicator());
        // }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // // CHANGE: not here anymore
    // int numOfConversations = combinedList.length;
    // if (numOfConversations == 0) {
    //   print ("No conversations found for " + currentUser.profileName);
    // } else {
    //   print ("Found " + numOfConversations.toString() + " conversations for " + currentUser.profileName);
    // }

    return Scaffold(
      appBar: AppBar(
          leading: BackButton(
            // color: who cares about color, default is good
              onPressed: () {
                Navigator.pop(context);
                // other classes have a bunch of stuff here, but it seems unnecessary for this class?
              }),
          title: Text("Messages"),
          actions: <Widget>[]),
      body: ListView(padding: const EdgeInsets.all(8), children: <Widget>[
        _buildList(),
      ]),
    );
  }
}

Future<List> getUpdatedConvClient(String userID) async {
  http.Response res = await http.get(Uri.parse(domain + "/getUser/" + userID));
  Map userMap = jsonDecode(res.body.toString());
  User tmpUsr = User.fromJSON(userMap);
  return [tmpUsr.conversations, tmpUsr.clients];
}
