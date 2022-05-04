// Jialin Li CSCE 606 Spring 2022

// Messages: from, to, content
// So far only support text messages, may be expanded

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:woolala_app/main.dart';

class Message {
  final String msgID; // FromUser:::ToUser:::Timestamp
  final String FromUser;
  final String ToUser;
  final String Content;

  Message({
    this.msgID,
    this.FromUser,
    this.ToUser,
    this.Content,
  });

  Message.fromJSON(Map<String, dynamic> json)
    : msgID = json["msgID"],
      FromUser = json["FromUser"],
      ToUser = json["ToUser"],
      Content = json["Content"];

  Map<String, dynamic> toJSON() => {
    "msgID" : msgID,
    "FromUser" : FromUser,
    "ToUser" : ToUser,
    "Content" : Content,
  };
}

Future<http.Response> insertMessage(String fromUser, String toUser, String content) {
  print("Inserting new message to db");
  String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
  print(timeStamp);
  return http.post(
    Uri.parse(domain + '/insertMessage'), // the backend will also insert this msg to conversation
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "msgID" : fromUser + ":::" + toUser + ":::" + timeStamp,
      "FromUser" : fromUser,
      "ToUser" : toUser,
      "Content" : content,
    }),
  );
}

Future<Message> getMessageByID(String msgID) async {
  http.Response res =
      await http.get(Uri.parse(domain + "/getMessage/" + msgID));
  if (res.body.isNotEmpty) {
    Map msgMap = jsonDecode(res.body);
    return Message.fromJSON(msgMap);
  } else {
    return null;
  }
}