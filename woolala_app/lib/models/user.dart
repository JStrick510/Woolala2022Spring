class User{
  final String userID;
  final String profileName;
  final String url;
  final String googleID;
  final String facebookID;
  final String bio;
  final String username;

  User({this.userID, this.profileName, this.url, this.googleID, this.facebookID, this.bio,this.username});

  User.fromJSON(Map<String, dynamic> json)
      : userID = json['userID'],
        profileName = json['profileName'],
        url = json['url'],
        googleID = json['googleID'],
        facebookID = json['facebookID'],
        bio = json['bio'],
        username = json['username'];

  Map<String, dynamic> toJSON() =>
      {
          'userID': userID,
          'profileName': profileName,
          'url': url,
          'googleID': googleID,
          'facebookID': facebookID,
          'bio': bio,
          'username': username,
      };

}