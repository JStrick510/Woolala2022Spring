import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'homepage_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:woolala_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:woolala_app/screens/homepage_screen.dart';
import 'dart:convert';
import 'dart:math';
import 'package:convert/convert.dart';

final GoogleSignIn gSignIn = GoogleSignIn();
final facebookLogin = FacebookLogin();
final DateTime timestamp = DateTime.now();
User currentUser;

void googleLoginUser() {
  print("Google signing in!");
  gSignIn.signIn();
}

void googleLogoutUser() {
  print("Google signed out!");
  gSignIn.signOut();
}

void facebookLoginUser() {
  print("Facebook signing in!");
  facebookLogin.logIn(['email']);
}

void facebookLogoutUser() {
  print("Facebook signed out!");
  facebookLogin.logOut();
}

// called by saveUserInfoToServer
Future<User> getDoesUserExists(String email) async {
  print("Finding user!");
  print(email);
  http.Response res = await http.get(domain + "/doesUserExist/" + email);
  if (res.body.isNotEmpty) {
    Map userMap = jsonDecode(res.body.toString());
    return User.fromJSON(userMap);
  } else {
    return null;
  }
}

// called by saveUserInfoToServer
Future<http.Response> insertUser(User u) {
  print("INSERTING A USER");
  return http.post(
    'http://10.0.2.2:5000/insertUser',
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(u.toJSON()),
  );
}

// images for CarouselSlider -> make this image list from trending posts
List<String> images = [
  'https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/index2-1583967114.png',
  'https://cdn.cliqueinc.com/posts/286587/best-summer-fashion-trends-2020-286587-1585948878056-main.700x0c.jpg',
  'https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/80s-outfits-2019-1548781035.jpg',
  'https://i.guim.co.uk/img/media/ea97c6f1ed87aaabac383a013375c6e670a24e30/0_125_2666_1598/master/2666.jpg?width=700&quality=85&auto=format&fit=max&s=0852b6f5847cf5331f4957f459dcb621'
];

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isSignedInWithGoogle = false;
  bool isSignedInWithFacebook = false;
  bool _disposed = false;

  // called automatically on app launch
  void initState() {
    print("Init State");
    super.initState();
    var keepGoing = true;
    // Random rand = new Random();
    // int fuck = rand.nextInt(10);
    // if (fuck % 2 == 0 && fuck < 5)
    //   loadMusic("woolala");
    // else if (fuck % 2 != 0 && fuck < 5) loadMusic("fuck");

    gSignIn.onCurrentUserChanged.listen((gSignInAccount) {
      controlGoogleSignIn(gSignInAccount);
      keepGoing = false;
    }, onError: (gError) {
      print("Error Message: " + gError);
    });
    if (keepGoing) {
      gSignIn.signInSilently(suppressErrors: true).then((gSignInAccount) {
        controlGoogleSignIn(gSignInAccount);
        keepGoing = false;
      }).catchError((gError) {
        print("Error Message: " + gError);
      });
    }
    if (keepGoing) {
      print("FACEBOOK");
      controlFacebookSignIn();
    }
  }

  // provides an error when trying to set state
  @override
  void dispose() {
    _disposed = true;
    advancedPlayer = null;
    super.dispose();
  }

  // called during initState
  void controlGoogleSignIn(GoogleSignInAccount signInAccount) async {
    if (signInAccount != null) {
      print("account exists");
      await saveGoogleUserInfoToServer();
      if (!_disposed) {
        setState(() {
          isSignedInWithGoogle = true;
        });
      }
    } else {
      print("No google account found");
      if (!_disposed) {
        setState(() {
          isSignedInWithGoogle = false;
        });
      }
    }
  }

  void controlFacebookSignIn() async {
    var tempToken = (await facebookLogin.currentAccessToken);
    if (tempToken == null) {
      print("NULL");
      if (!_disposed) {
        setState(() {
          isSignedInWithFacebook = false;
        });
      }
    } else {
      print("NOT NULL");
      await saveFacebookUserInfoToServer();
      if (!_disposed) {
        setState(() {
          isSignedInWithFacebook = true;
        });
      }
    }
  }

// called in controlGoogleSignIn
  saveGoogleUserInfoToServer() async {
    final GoogleSignInAccount gAccount = gSignIn.currentUser;
    User tempUser = await getDoesUserExists(gAccount.email);
    if (tempUser != null && tempUser.userID != "") //account exists
    {
      print("You have an account!");
      currentUser = tempUser;
      //set current user
    } else {
      print("You must make an account!");
      User u = User(
          googleID: gAccount.id,
          email: gAccount.email,
          userName:
              '@' + gAccount.displayName.replaceAll(new RegExp(r"\s+"), ""),
          profileName: gAccount.displayName,
          profilePic: 'default',
          bio: "This is my new Woolala Account!",
          userID: base64.encode(latin1.encode(gAccount.email)).toString(),
          numFollowers: 0,
          numPosts: 0,
          numRated: 0,
          postIDs: [],
          following: [],
          private: false);
      print("about to call insert user");
      await insertUser(u);
      currentUser = u;
    }
  }

// called in controlGoogleSignIn
  saveFacebookUserInfoToServer() async {
    var tempToken = (await facebookLogin.currentAccessToken);
    var token = tempToken.token;
    print(token);
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture.type(large),email&access_token=${token}');
    final profile = json.decode(graphResponse.body);
    print(profile);
    String id = profile['id'];
    print("facebook profile test: ");
    print(profile);
    User tempUser = await getDoesUserExists(profile['email']);
    if (tempUser != null && tempUser.userID != "") //account exists
    {
      print("You have an account!");
      currentUser = tempUser;
    } else {
      print("You must make an account!");
      User u = User(
          facebookID: profile['id'],
          email: profile['email'],
          profileName: profile['name'],
          profilePic: profile['picture']['data']['url'],
          bio: "This is my new Woolala Account. Me so !",
          userID: base64.encode(latin1.encode(profile['email'])).toString());
      await insertUser(u);
    }
  }

// used in the CarouselSlider
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    print("Build!");
    if (isSignedInWithGoogle || isSignedInWithFacebook) {
      //playLocalAsset();
      return HomepageScreen(isSignedInWithGoogle);
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Login'),
          key: ValueKey("logs"),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              onPressed: () => {googleLogoutUser(), facebookLogoutUser()},
              child: Text("Sign Out"),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            )
          ],
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 25),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                Colors.purple[900],
                Colors.purple[800],
                Colors.purple[600]
              ]),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new IconButton(
                  key: ValueKey("GoToHome"),
                  icon: Image.asset('./assets/logos/w_logo_test.png',
                      width: 300,
                      height: 150,
                      fit: BoxFit.contain,
                      semanticLabel: 'WooLaLa logo'),
                  iconSize: 150,
                ),
                Text(
                  "Powered by: ",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Image.asset('assets/logos/fashionNXT_logo.png',
                    width: 150,
                    height: 30,
                    fit: BoxFit.contain,
                    semanticLabel: 'FashioNXT logo'),
                SizedBox(
                  height: 25,
                ),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 160.0,
                    initialPage: 0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    reverse: false,
                    enableInfiniteScroll: true,
                    autoPlayInterval: Duration(seconds: 4),
                    autoPlayAnimationDuration: Duration(milliseconds: 2000),
                    scrollDirection: Axis.horizontal,
                  ),
                  items: images.map((imgUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.black,
                          ),
                          child: Image.network(
                            imgUrl,
                            fit: BoxFit.fill,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  "Login With:",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                _buildSocialButtonRow()
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo, String keyText) {
    return GestureDetector(
      onTap: onTap,
      key: ValueKey(keyText),
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 20.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtonRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
            facebookLoginUser,
            AssetImage(
              'assets/logos/facebook_logo.png',
            ),
            "Facebook",
          ),
          _buildSocialBtn(
            googleLoginUser,
            AssetImage(
              'assets/logos/google_logo.png',
            ),
            "Google",
          ),
        ],
      ),
    );
  }
}
