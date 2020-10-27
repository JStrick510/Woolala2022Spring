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
import 'package:convert/convert.dart';

final GoogleSignIn gSignIn = GoogleSignIn();
final DateTime timestamp = DateTime.now();
User currentUser;

void googleLoginUser(){
  //gSignIn.signOut();
  print("signing in!");
  gSignIn.signIn();
}

void googleLogoutUser(){
  print("signed out!");
  gSignIn.signOut();
}

Future<User> getDoesUserExists(String email) async{
  print("Finding USER!");
  http.Response res = await http.get('http://10.0.2.2:5000/doesUserExist/'+email);
  if(res.body.isNotEmpty)
  {
      Map userMap = jsonDecode(res.body.toString());
      return User.fromJSON(userMap);
  }
  else
  {
    return null;
  }
}

Future<http.Response> insertUser(User u) {
  return http.post(
    'http://10.0.2.2:5000/insertUser',
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(u.toJSON()),
  );
}
//make this trending posts
List<String> images = [
  'https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/index2-1583967114.png',
  'https://cdn.cliqueinc.com/posts/286587/best-summer-fashion-trends-2020-286587-1585948878056-main.700x0c.jpg',
  'https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/80s-outfits-2019-1548781035.jpg',
  'https://i.guim.co.uk/img/media/ea97c6f1ed87aaabac383a013375c6e670a24e30/0_125_2666_1598/master/2666.jpg?width=700&quality=85&auto=format&fit=max&s=0852b6f5847cf5331f4957f459dcb621'
];

class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isSignedInWithGoogle = false;
  bool isSignedInWithFacebook = false;
  bool _disposed = false;


  void initState(){
    super.initState();
    gSignIn.onCurrentUserChanged.listen((gSignInAccount){
      controlGoogleSignIn(gSignInAccount);
    }, onError: (gError){
      print("Error Message: " + gError);
    });
    gSignIn.signInSilently(suppressErrors: true).then((gSignInAccount){
      controlGoogleSignIn(gSignInAccount);
    }).catchError((gError){
      print("Error Message: " + gError);
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void controlGoogleSignIn(GoogleSignInAccount signInAccount) async{
    if(signInAccount != null)
    {
      print("account exists");
      await saveUserInfoToServer();
      if(!_disposed) {
        setState(() {
          isSignedInWithGoogle = true;
        });
      }
    }
    else{
      print("No google account found");
      if(!_disposed) {
        setState(() {
          isSignedInWithGoogle = false;
        });
      }
    }
  }

  saveUserInfoToServer() async{
    final GoogleSignInAccount gAccount = gSignIn.currentUser;
    User tempUser = await getDoesUserExists(gAccount.email);
    if(tempUser!=null && tempUser.userID!="")//account exists
      {
       print("You have an account!");
       currentUser = tempUser;
       //set current user
      }
    else{
      print("You must make an account!");
      User u = User(
        googleID: gAccount.id,
        email: gAccount.email,
        profileName: gAccount.displayName,
        profilePicURL: gAccount.photoUrl,
        bio: "This is my new Woolala Account!",
        userID: base64.encode(latin1.encode(gAccount.email)).toString(),
        numFollowers: 0,
        numPosts: 0,
        numRated: 0
      );
      await insertUser(u);
      currentUser = u;
    }

  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (isSignedInWithGoogle || isSignedInWithFacebook) {
      return HomepageScreen(isSignedInWithGoogle);
    }
    else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(

          title: Text('Login'),
          key: ValueKey("logs"),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              onPressed: () => googleLogoutUser(),
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
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: [
                    Colors.purple[900],
                    Colors.purple[800],
                    Colors.purple[600]
                  ]
              ),
            ),


            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('./assets/logos/w_logo_test.png', width: 300,
                    height: 150,
                    fit: BoxFit.contain,
                    semanticLabel: 'WooLaLa logo'),
                Text("Powered by: ",
                  style: TextStyle(color: Colors.white, fontSize: 16),),
                Image.asset('assets/logos/fashionNXT_logo.png', width: 150,
                    height: 30,
                    fit: BoxFit.contain,
                    semanticLabel: 'FashioNXT logo'),
                SizedBox(height: 25,),
                CarouselSlider(options: CarouselOptions(
                  height: 160.0,
                  initialPage: 0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  reverse: false,
                  enableInfiniteScroll: true,
                  autoPlayInterval: Duration(seconds: 4),
                  autoPlayAnimationDuration: Duration(milliseconds: 2000),
                  scrollDirection: Axis.horizontal,),
                  items: images.map((imgUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
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
                SizedBox(height: 25,),
                Text("Login With:",
                  style: TextStyle(color: Colors.white, fontSize: 24),),
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
          height: 60.0, width: 60.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26, offset: Offset(0, 2), blurRadius: 20.0,),
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
            _buildSocialBtn(startFacebookSignIn,
              AssetImage('assets/logos/facebook_logo.png',), "Facebook",),
            _buildSocialBtn(
              googleLoginUser, AssetImage('assets/logos/google_logo.png',),
              "Google",),
          ],
        ),
      );
    }

/*
    void startGoogleSignIn() async {
      GoogleSignInAccount user = await gSignIn.signIn();
      if (user == null) {
        print("Sign in failed.");
        SnackBar googleSnackBar = SnackBar(content: Text("Sign in failed."));
        _scaffoldKey.currentState.showSnackBar(googleSnackBar);
      }
      else {
        print(user);
        SnackBar googleSnackBar = SnackBar(
            content: Text("Welcome ${user.displayName}!"));
        _scaffoldKey.currentState.showSnackBar(googleSnackBar);
        Navigator.pushReplacementNamed(_scaffoldKey.currentContext, '/home');
        //Navigator.pushReplacementNamed(_scaffoldKey.currentContext, '/home');
      }
    }
*/
    void startFacebookSignIn() async {

      FacebookLogin facebookLogin = FacebookLogin();
      var value = await facebookLogin.isLoggedIn;
      var currentAccessToken = facebookLogin.currentAccessToken;
      if (!value) {
        final result = await facebookLogin.logIn(['email']);
        switch (result.status) {
          case FacebookLoginStatus.loggedIn:
            final token = result.accessToken.token;

            final graphResponse = await http.get(
                'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
            final profile = json.decode(graphResponse.body);
            print(profile);
            SnackBar googleSnackBar = SnackBar(
                content: Text("Welcome ${profile["name"]}!"));
            _scaffoldKey.currentState.showSnackBar(googleSnackBar);

            Navigator.pushReplacementNamed(context, '/');
            // final credential = FacebookAuthProvider.getCredential(accessToken: token);
            // final graphResponse = away http:get()
            // _showLoggedInUI();
            break;
          case FacebookLoginStatus.cancelledByUser:
          // _showCancelledMessage();
            print("Sign in failed.");
            SnackBar googleSnackBar = SnackBar(
                content: Text("Sign in failed."));
            _scaffoldKey.currentState.showSnackBar(googleSnackBar);
            break;
          case FacebookLoginStatus.error:
          // _showErrorOnUI(result.errorMessage);
            print("Sign in failed.");
            SnackBar googleSnackBar = SnackBar(
                content: Text("Sign in failed."));
            _scaffoldKey.currentState.showSnackBar(googleSnackBar);
            break;
        }
      }
      else {
        print("Successfully logged in!");
        if(!_disposed) {
          setState(() {
            isSignedInWithFacebook = true;
          });
        }
        Navigator.pushReplacementNamed(_scaffoldKey.currentContext, '/home');
      }

    }

}
