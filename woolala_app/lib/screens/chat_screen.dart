import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bubble/issue_clipper.dart';
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
  // can only access widget.otherUser in the return statement below, apparently
  // therefore, declare a few things here and update them below
  Conversation currentConv;
  List messageList = [];
  int numOfMsgs;
  
  ScrollController _controller = new ScrollController();
  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();

  // @override
  // void initState() async {
  //   super.initState();

  //   await getCurrentMsgList();
  // }

  getCurrentMsgList() async {
    currentConv = await getConversationBetween(widget.otherUser.userID, currentUser.userID);
    if (currentConv != null) {
      print("ChatScreen: conversation found");
      print(currentConv.User1 + " and " + currentConv.User2);
      List messagePointerList = currentConv.Messages;
      for (String msgPtr in messagePointerList) {
        Message msg = await getMessageByID(msgPtr);
        if (msg != null) {
          messageList.add(msg);
        }
      }
    }
    numOfMsgs = messageList.length;
    print("Number of messages found: " + numOfMsgs.toString());
    if (numOfMsgs > 0 ) {
      print(messageList[0].FromUser + " " + messageList[0].Content);
    }
  }

  // TODO: debug this
  
  Widget _buildList() {
    return FutureBuilder(
      future: getCurrentMsgList(),
      builder: (context, snapshot) {
        return ListView.builder(
          key: ValueKey("ListView"),
          scrollDirection: Axis.vertical,
          // physics: const AlwaysScrollableScrollPhysics(), // doesn't work?
          // controller: _controller,
          reverse: true,
          shrinkWrap: true,
          itemCount: messageList.length,
          itemBuilder: (BuildContext context, int index) {
            // some weird bug happened here when I click into chat page it crashes immediately
            // and then it disappeared like it has never existed. WTF?
            if (messageList[index].FromUser == currentUser.userID) { // sent by self
              print("Found msg send by me");
              return new Bubble(
                margin: BubbleEdges.only(top: 10),
                alignment: Alignment.topRight,
                nip: BubbleNip.rightTop,
                color: Color.fromRGBO(225, 255, 199, 1.0),
                child: Text(messageList[index].Content, textAlign: TextAlign.right),
              );
            } else {
              print("Found msg send by the other");
              return new Bubble(
                margin: BubbleEdges.only(top: 10),
                alignment: Alignment.topLeft,
                nip: BubbleNip.leftTop,
                child: Text(messageList[index].Content),
              );
            }
          }
        );
      }
    );
  }

  // _buildInputBox() {
  //   return SizedBox(
  //     width: double.infinity,
  //     height: 50,
  //     child: Row(
  //       children: [
  //         Flexible(
  //           child: TextField(
  //             focusNode: focusNode,
  //             textInputAction: TextInputAction.send,
  //             keyboardType: TextInputType.text,
  //             textCapitalization: TextCapitalization.sentences,
  //             controller: textEditingController,
  //             onSubmitted: (value) {
  //               sendMessage(textEditingController.text);
  //             },
  //           )
  //         ),
  //         Container(
  //           margin: const EdgeInsets.only(), //(left: Sizes.dimen_4),
  //           child: IconButton(
  //             onPressed: () async {
  //               await sendMessage(textEditingController.text);
  //             },
  //             icon: Icon(Icons.send),
  //           )
  //         )
  //       ]
  //     )
  //   );
  // }

  // sendMessage(String content) async {
  //   if (content.trim().isNotEmpty) {
  //     await insertMessage(currentUser.userID, widget.otherUser.userID, content);
  //     textEditingController.clear();
  //     Navigator.pushReplacement(
  //               context,
  //               PageRouteBuilder(
  //                 pageBuilder: (context, animation1, animation2) =>
  //                     ChatScreen(widget.otherUser),
  //               ));
  //   } else {
  //     Fluttertoast.showToast(msg: "You have entered nothing", backgroundColor: Colors.grey);
  //   }
  // }

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
      // body: ListView(padding: const EdgeInsets.all(4), children: <Widget>[
      //   _buildList(),
      // ]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(), //(horizontal: Sizes.dimen_8),
          child: Column(
            children: [
              ListView(padding: const EdgeInsets.all(4), children: <Widget>[
                _buildList(),
              ]),
              // _buildInputBox(),
            ],
          ),
        ),
      ),
    );
  }
}