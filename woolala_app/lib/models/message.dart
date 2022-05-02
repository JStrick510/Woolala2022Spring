// Jialin Li CSCE 606 Spring 2022

// Messages: from, to, content
// So far only support text messages, may be expanded

class Message {
  final String ID;
  final String FromUser;
  final String ToUser;
  final String Content;
  final String Timestamp;

  Message({
    this.ID,
    this.FromUser,
    this.ToUser,
    this.Content,
    this.Timestamp,
  });

  Message.fromJSON(Map<String, dynamic> json)
    : ID = json["ID"],
      FromUser = json["FromUser"],
      ToUser = json["ToUser"],
      Content = json["Content"],
      Timestamp = json["Timestamp"];

  Map<String, dynamic> toJSON() => {
    "ID" : ID,
    "FromUser" : FromUser,
    "ToUser" : ToUser,
    "Content" : Content,
    "Timestamp": Timestamp,
  };
}
