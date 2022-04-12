import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
//import 'package:woolala_app/screens/login_screen.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
import 'package:woolala_app/models/user.dart';
//import 'package:woolala_app/screens/profile_screen.dart';
import 'package:woolala_app/widgets/bottom_nav.dart';
//import 'package:woolala_app/main.dart';
//import 'package:woolala_app/screens/following_list_screen.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

//Create Stateful Widget
class WouldBuyListScreen extends StatefulWidget {
  final String postID;
  final List wouldBuyNameList;
  final List wouldBuyEmailList;
  WouldBuyListScreen(
      this.postID, this.wouldBuyNameList, this.wouldBuyEmailList);
  @override
  _WouldBuyListScreen createState() => _WouldBuyListScreen();
}

class _WouldBuyListScreen extends State<WouldBuyListScreen> {
  //Lists to build the ListView
  List followerNameList = [];
  User currentProfile;
  List followerList = [];
  List followerEmailList = [];
  List followerUserNameList = [];

  //Build the list using a Futurebuilder for Async
  // Widget _buildList() {
  //   return FutureBuilder(
  //     future: listbuilder(),
  //     builder: (context, snapshot) {
  //       //Make sure the snapshot is valid without errors
  //       if (snapshot.hasData) {
  //         return ListView.builder(
  //           key: ValueKey("ListView"),
  //           scrollDirection: Axis.vertical,
  //           shrinkWrap: true,
  //           itemCount: followerList.length,
  //           itemBuilder: (BuildContext context, int index) {
  //             return new ListTile(
  //               //Create the circular avatar for the user
  //               leading: CircleAvatar(
  //                 child: Text(followerList[index][0]),
  //               ),
  //               title: Text(followerList[index]),
  //               subtitle: Text(followerUserNameList[index]),
  //               onTap: () {
  //                 Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (BuildContext context) =>
  //                             ProfilePage(followerEmailList[index])));
  //               },
  //             );
  //           },
  //         );
  //       } else if (snapshot.hasError) {
  //         return Center(child: Text("No Results"));
  //       } else {
  //         return Center(child: CircularProgressIndicator());
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    BottomNav bottomBar = BottomNav(context);
    bottomBar.brand = currentProfile.brand;
    return Scaffold(
      appBar: AppBar(
          leading: BackButton(
              // color: Colors.white,
              onPressed: () =>
                  //(Navigator.pushReplacementNamed(context, '/profile'))
                  (Navigator.pop(context))),
          title: Text("Interested Buyers"),
          actions: <Widget>[]),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Colors.black,
        ),
        itemCount: widget.wouldBuyNameList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ListTile(
              title: Text(
                'Tap and hold a user to send an individual email or tap the mail button to send to all!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else {
            return ListTile(
              title: Text(
                  '${widget.wouldBuyNameList[index - 1]}  --  ${widget.wouldBuyEmailList[index - 1]}'),
              onLongPress: () {
                launchMailtoSingle(index);
              },
              onTap: () {
                // showToast("Hold on a item to send email");
                final snackBar =
                    SnackBar(content: Text('Hold on a user to send email!'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            );
          }
        },
      ),

      //show floating action button with mail icon
      floatingActionButton: FloatingActionButton(
          elevation: 20.0,
          child: Icon(Icons.email),
          onPressed: () {
            launchMailtoAll();
          }),

      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: Colors.blue,
        onTap: (int index) {
          bottomBar.switchPage(index, context);
        },
        items: bottomBar.getItems(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  //prompts to the default mailing app to email only individual.
  launchMailtoSingle(index) async {
    String greeting = "Hi " + '${widget.wouldBuyNameList[index - 1]}' + ",\n\n";
    final mailtoLink = Mailto(
      to: ['${widget.wouldBuyEmailList[index - 1]}'],
      cc: [],
      subject: 'Hello from ChooseNXT',
      body: greeting,
    );
    await launch('$mailtoLink');
  }

  //prompts to the default mailing app to email all
  launchMailtoAll() async {
    List<String> allMails = [];
    List<String> allNames = [];

    for (int i = 0; i < widget.wouldBuyEmailList.length; i++) {
      allMails.add('${widget.wouldBuyEmailList[i]}');
      allNames.add('${widget.wouldBuyNameList[i]}');
    }
    String greeting = "Hi there," + "\n\n";
    final mailtoLink = Mailto(
      to: allMails,
      cc: allMails,
      subject: 'Hello from ChooseNXT',
      body: greeting,
    );
    await launch('$mailtoLink');
  }

//   showToast(message) {
//     Fluttertoast.showToast(
//         msg: message,
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: Colors.white,
//         textColor: Colors.black,
//         fontSize: 16.0);
//   }
}
