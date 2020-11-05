class User{
  final String userID;
  final String profileName;
  final String url;
  final String googleID;
  final String facebookID;
  final String bio;
  final String username;
  final String profilePicURL;
  final String email;
  final int numPosts;
  final int numFollowers;
  final int numRated;

  User({
    this.userID,
    this.profileName,
    this.url,
    this.googleID,
    this.facebookID,
    this.bio,
    this.username,
    this.profilePicURL,
    this.email,
    this.numPosts,
    this.numFollowers,
    this.numRated
  });

  User.fromJSON(Map<String, dynamic> json)
      : userID = json['userID'],
        profileName = json['profileName'],
        url = json['url'],
        googleID = json['googleID'],
        facebookID = json['facebookID'],
        bio = json['bio'],
        username = json['username'],
        profilePicURL = json['profilePicURL'],
        email = json['email'],
        numPosts = json['numPosts'],
        numFollowers = json['numFollowers'],
        numRated = json['numRated'];

  Map<String, dynamic> toJSON() =>
      {
          'userID': userID,
          'profileName': profileName,
          'url': url,
          'googleID': googleID,
          'facebookID': facebookID,
          'bio': bio,
          'username': username,
          'profilePicURL': profilePicURL,
          'email': email,
          'numPosts' : numPosts,
          'numFollowers' : numFollowers,
          'numRated': numRated
      };


}



