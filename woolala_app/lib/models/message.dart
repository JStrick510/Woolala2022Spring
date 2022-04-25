// Jialin Li CSCE 606 Spring 2022

// Messages: from, to, content
// So far only support text messages, may be expanded

class Message {
  final String FromUser;
  final String ToUser;
  final String Content;

  Message({
    required this.FromUser,
    required this.ToUser,
    required this.Content,
  });

  factory Message.fromJSON(Map<String, dynamic> json) {
    return Message(
      FromUser = json["FromUser"],
      ToUser = json["ToUser"],
      Content = json["Content"],
    );
  }

  Map<String, dynamic> toJSON() => {
    "FromUser" : FromUser,
    "ToUser" : ToUser,
    "Content" : Content,
  };
}
