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
