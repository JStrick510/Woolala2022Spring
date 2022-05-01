import 'dart:math';
import 'dart:io';

// import 'package:apple_sign_in/apple_sign_in.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:simple_animations/simple_animations.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:woolala_app/Provider/sign_in_provider.dart';
import 'package:woolala_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:woolala_app/main.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart' as fireB;
import 'package:crypto/crypto.dart';

// final GoogleSignIn gSignIn = GoogleSignIn();
// final facebookLogin = FacebookLogin();
// final DateTime timestamp = DateTime.now();
User currentUser;
SignInProvider signInProvider =
    SignInProvider(); // Required to call Facebook or Google log in method

/// Generates a cryptographically secure random nonce, to be included in a
/// credential request.
String generateNonce([int length = 32]) {
  final charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

void googleLogoutUser() async {
  print("Google signed out!");
  await signInProvider.logout();
}

void facebookLogoutUser() async {
  print("Facebook signed out!");
  await signInProvider.logout();
}

// called by save user to server methods
Future<User> getDoesUserExists(String email) async {
  http.Response res =
      await http.get(Uri.parse(domain + "/doesUserExist/" + email));
  if (res.body.isNotEmpty) {
    Map userMap = jsonDecode(res.body.toString());
    return User.fromJSON(userMap);
  } else {
    return null;
  }
}

// called by save user to server methods
Future<http.Response> insertUser(User u) {
  print("Inserting new user to the db.");
  return http.post(
    Uri.parse(domain + '/insertUser'),
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
  bool isSignedInWithApple = false;
  bool _disposed = false;
  bool _firstTimeLogin = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isPasswordVisble = false;

  // called automatically on app launch
  void initState() {
    _userIsSignedIn();
    _emailController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    super.initState();
  }

  /* This function makes sure the app remembers the user's credentials.
  It will redirect to the Feed page if user is already signed in.
  */
  void _userIsSignedIn() async {
    try {
      fireB.User _oldUser = fireB.FirebaseAuth.instance.currentUser;
      currentUser = await getDoesUserExists(_oldUser.email);
      if (currentUser != null) {
        Navigator.pushNamed(context, '/home');
      }
      ;
    } catch (e) {
      // If user has not been signed in, Firebase throws an exception which will be fixed when user signs in.
    }
  }

  void signInWithApple() async {
    bool _appleNewUser;
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    AuthorizationCredentialAppleID appleCredential;

    showAlertDialog(context);
    // Request credential for the currently signed in Apple account.
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      //can only get full name once
      if (appleCredential.email == null) {
        _appleNewUser = false;
      } else {
        _appleNewUser = true;
      }
    } catch (SignInWithAppleAuthorizationException) {
      if (SignInWithAppleAuthorizationException.code ==
          AuthorizationErrorCode.canceled) {
        print('Apple Sign In Cancelled by User');
        Navigator.pop(context);
      } else {
        print('Apple Sign In error');
        Navigator.pop(context);
      }
      if (!_disposed) {
        setState(() {
          isSignedInWithGoogle = false;
          isSignedInWithFacebook = false;
        });
      }
      return;
    }

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = fireB.OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    // print(oauthCredential);

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    final result =
        await fireB.FirebaseAuth.instance.signInWithCredential(oauthCredential);
    // print(result);

    if (_appleNewUser) {
      await saveAppleUserInfoToServer(_appleNewUser, result.user.email,
          appleCredential.givenName + appleCredential.familyName);
    } else {
      await saveAppleUserInfoToServer(
          _appleNewUser, result.user.email, "Apple User");
    }

    if (!_disposed) {
      setState(() {
        isSignedInWithApple = true;
      });
    }
  }

  // provides an error when trying to set state
  @override
  void dispose() {
    _disposed = true;
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  saveAppleUserInfoToServer(firstTime, email, fullName) async {
    User tempUser = await getDoesUserExists(email);
    if (tempUser != null && tempUser.userID != "") //account exists
    {
      print("User account found with Apple ID email.");
      currentUser = tempUser;
      Navigator.pop(context);
      isSignedInWithApple = true;
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: [
          isSignedInWithGoogle,
          isSignedInWithFacebook,
          isSignedInWithApple,
        ],
      );
    } else {
      print("Making an account with Apple.");
      //insert eula here
      var result = await Navigator.pushNamed(context, '/eula');
      if (result == null || result == false) {
        Navigator.pop(context);
        return;
      }
      User u = User(
        email: email,
        userName: '@' + base64.encode(latin1.encode(email)).toString(),
        profileName: fullName,
        profilePic: 'default',
        bio: "This is my new ChooseNXT Account!",
        userID: base64.encode(latin1.encode(email)).toString(),
        followers: [],
        numRated: 0,
        postIDs: [],
        following: [base64.encode(latin1.encode(email)).toString()],
        private: false,
        ratedPosts: [],
        url: "",
        blockedUsers: [],
        brand: false,
        conversations: [],
      );
      await insertUser(u);
      currentUser = u;
      _firstTimeLogin = true;
      Navigator.pop(context);
      isSignedInWithApple = true;
      Navigator.pushReplacementNamed(context, '/createAccount');
    }
  }

  // Go to the Register page to create an account with email and password
  Widget _noAccount() {
    return Container(
      // margin: EdgeInsets.symmetric(vertical: 20),
      // padding: EdgeInsets.all(15),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Don\'t have an account ?',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => SimpleDialog(
                  title: Text(
                    'What account tier do you want to register for?',
                    style: TextStyle(fontSize: 16),
                  ),
                  children: [
                    SimpleDialogOption(
                      child: const Text('Patron'),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, '/patronRegistration');
                      },
                    ),
                    SimpleDialogOption(
                      child: const Text('Business'),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, '/businessRegistration');
                      },
                    ),
                  ],
                ),
              );
            },
            child: Text(
              'Register Here',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget _emailField() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 60),
      child: Theme(
        data: ThemeData().copyWith(
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: Colors.white70,
                onSurface: Colors.white70,
              ),
        ),
        child: TextField(
          style: TextStyle(color: Colors.white),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'name@example.com',
            hintStyle: TextStyle(color: Colors.white70),
            label: const Text(
              'email',
              style: TextStyle(color: Colors.white54, fontSize: 17),
            ),
            prefixIcon: Icon(Icons.email),
            suffixIcon: _emailController.text.isEmpty
                ? Container(
                    width: 0,
                  )
                : IconButton(
                    onPressed: () => _emailController.clear(),
                    icon: Icon(Icons.close),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 60),
      child: Theme(
        data: ThemeData().copyWith(
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: Colors.white70,
                onSurface: Colors.white70,
              ),
        ),
        child: TextField(
          style: TextStyle(color: Colors.white),
          controller: _passwordController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter your password',
            hintStyle: TextStyle(color: Colors.white70),
            label: const Text(
              'password',
              style: TextStyle(color: Colors.white54, fontSize: 17),
            ),
            suffixIcon: IconButton(
              icon: isPasswordVisble
                  ? Icon(Icons.visibility)
                  : Icon(Icons.visibility_off),
              onPressed: () =>
                  setState(() => isPasswordVisble = !isPasswordVisble),
            ),
          ),
          obscureText: !isPasswordVisble,
        ),
      ),
    );
  }

  Widget _signInButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 5),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.grey.shade400,
            onPrimary: Colors.black,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            'Log In',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () async {
            final password = _passwordController.text;
            final email = _emailController.text;
            try {
              final userCredential =
                  await fireB.FirebaseAuth.instance.signInWithEmailAndPassword(
                email: email,
                password: password,
              );
              // print(userCredential);
              User tempUser = await getDoesUserExists(email);
              if (tempUser != null && tempUser.userID != "") //account exists
              {
                print("User account found with email and password.");
                currentUser = tempUser;
                Navigator.pushReplacementNamed(context, '/home');
              }
            } on fireB.FirebaseAuthException catch (e) {
              // errorHandling(e);
            }
          }),
    );
  }

  // Users should get a password rest email when click on this button
  // It must be given the email address to send the email (_emailcontroller != null)
  // Firebase take cares of sending the email. So, the email context can be changed on
  // "Console.firebase.com"
  Widget _forgotPassword() {
    return Container(
      child: TextButton(
        style: TextButton.styleFrom(
          primary: Colors.black45,
        ),
        child: const Text(
          'Forgot your password?',
          style: TextStyle(color: Colors.white70),
        ),
        onPressed: () async {
          if (_emailController.text.isEmpty) {
            final snackBar = SnackBar(
                content: const Text('Please enter your email address first!'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            return;
          } else {
            showDialog(
              context: context,
              builder: (_) => SimpleDialog(
                title: Text(
                  'Do you want to reset your password?',
                  style: TextStyle(fontSize: 16),
                ),
                children: [
                  SimpleDialogOption(
                    child: const Text('Yes'),
                    onPressed: () async {
                      await fireB.FirebaseAuth.instance.sendPasswordResetEmail(
                        email: _emailController.text,
                      );
                      final snackBar = SnackBar(
                        content: Text(
                          'A reset pasword email was sent to ' +
                              _emailController.text,
                        ),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  ),
                  SimpleDialogOption(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.pop(context); // Close the pop-up
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _googleSignInButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 60),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: Colors.blueGrey[50],
          onPrimary: Colors.black,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () async {
          GoogleSignInAccount googleUser = await signInProvider.googleLogIn();
          _redirectUser(
            email: googleUser.email,
            onFailureMessage: 'Please register with your Google account first!',
          );
        },
        label: const Text('Sign in with Google'),
        icon: const FaIcon(
          FontAwesomeIcons.google,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _facebookSignInButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 60),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: Colors.blueGrey[50],
          onPrimary: Colors.black,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () async {
          Map<String, dynamic> faceBookUser =
              await signInProvider.facebookLogIn();
          _redirectUser(
            email: faceBookUser["email"],
            onFailureMessage:
                'Please register with your Facebook account first!',
          );
        },
        label: const Text('Sign in with Facebook'),
        icon: const FaIcon(
          FontAwesomeIcons.facebook,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 25,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
                color: Colors.white,
              ),
            ),
          ),
          const Text(
            '  or  ',
            style: TextStyle(color: Colors.white70),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 25,
          ),
        ],
      ),
    );
  }

  /* When users attempt to sign in, they should be redirected to the Feed page
   if the user already exist in the database.
   This function updates the currentUser global variable which is required in 
   other pages to access the current user information.
  */
  void _redirectUser(
      {@required String email, @required String onFailureMessage}) async {
    User tempUser = await getDoesUserExists(email);
    // User should be redirected to Feed page after a successful login
    if (tempUser != null && tempUser.userID != "") {
      currentUser = tempUser;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // User should create an account first in case the user has not been registered
      signInProvider.logout();
      final snackBar = SnackBar(content: Text(onFailureMessage));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          // Box decoration takes a gradient
          gradient: LinearGradient(
            // Where the linear gradient begins and ends
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            // Add one stop for each color. Stops should increase from 0 to 1
            stops: [0.2, 0.5, 0.7, 0.9],
            colors: [
              // Colors are easy thanks to Flutter's Colors class.
              Colors.black87,
              Colors.black54,
              Colors.black38,
              Colors.black26,
            ],
          ),
        ),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 60),
                new Image.asset('./assets/logos/ChooseNXT wide logo WBG.png',
                    width: 400,
                    height: 95,
                    // color: Colors.blueGrey[900],
                    fit: BoxFit.contain,
                    semanticLabel: 'WooLaLa logo'),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'Choose New Releases from Creatives',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.blueGrey[900]),
                  ),
                ),
                SizedBox(height: 30),
                _emailField(),
                _passwordField(),
                _signInButton(),
                _forgotPassword(),
                _divider(),
                _googleSignInButton(context),
                _facebookSignInButton(context),
                _noAccount(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // }

//progress indicator
  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        content: Container(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  strokeWidth: 8,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)));
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
