import 'dart:math';
import 'dart:io';

// import 'package:apple_sign_in/apple_sign_in.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
//import 'homepage_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
//import 'package:carousel_slider/carousel_slider.dart';
import 'package:woolala_app/models/user.dart';
import 'package:http/http.dart' as http;
//import 'package:woolala_app/screens/homepage_screen.dart';
import 'dart:convert';
//import 'package:woolala_app/screens/createUserName.dart';
import 'package:woolala_app/main.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart' as fireB;
import 'package:crypto/crypto.dart';
import 'package:woolala_app/screens/registration.dart';
// import 'package:flutter/services.dart';

final GoogleSignIn gSignIn = GoogleSignIn();
final facebookLogin = FacebookLogin();
final DateTime timestamp = DateTime.now();
User currentUser;

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
  await gSignIn.signOut();
}

void facebookLogoutUser() async {
  print("Facebook signed out!");
  await facebookLogin.logOut();
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
    print("Calling initState");
    _emailController.addListener(() => setState(() {}));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      signInProcess();
    });
  }

  void googleLoginUser() {
    print("Google signing in!");
    try {
      gSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  void facebookLoginUser() async {
    var facebookLoginResult = await facebookLogin.logIn(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Facebook login error.");
        print("Error from Facebook '${facebookLoginResult.errorMessage}'");
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("Facebook login cancelled by user.");
        break;
      case FacebookLoginStatus.loggedIn:
        signInProcess();
        break;
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

  void signInProcess() {
    var keepGoing = true;
    if (keepGoing) {
      gSignIn.signInSilently(suppressErrors: true).then((gSignInAccount) {
        keepGoing = false;
        controlGoogleSignIn(gSignInAccount);
      }).catchError((gError) {
        print("Error Message: " + gError);
      });
    }
    if (keepGoing) {
      controlFacebookSignIn();
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

  // called during initState
  void controlGoogleSignIn(GoogleSignInAccount signInAccount) async {
    if (signInAccount != null) {
      print("Google - Account token remembered.");
      await saveGoogleUserInfoToServer();
      if (!_disposed) {
        setState(() {
          isSignedInWithGoogle = true;
        });
      }
    } else {
      print("Google - no account found.");
      if (!_disposed) {
        setState(() {
          isSignedInWithGoogle = false;
        });
      }
    }
  }

  void controlFacebookSignIn() async {
    showAlertDialog(context);
    var tempToken = (await facebookLogin.currentAccessToken);
    if (tempToken == null) {
      print("Facebook - no account found.");
      Navigator.pop(context);
      if (!_disposed) {
        setState(() {
          isSignedInWithFacebook = false;
        });
      }
    } else {
      print("Facebook - Account token remembered.");
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
    showAlertDialog(context);
    final GoogleSignInAccount gAccount = gSignIn.currentUser;
    User tempUser = await getDoesUserExists(gAccount.email);
    if (tempUser != null && tempUser.userID != "") //account exists
    {
      print("User account found with Google email.");
      currentUser = tempUser;
      Navigator.pop(context);
      isSignedInWithGoogle = true;
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
      print("Making an account with Google.");
      //insert eula here
      var result = await Navigator.pushNamed(context, '/eula');
      if (result == null || result == false) {
        googleLogoutUser();
        Navigator.pop(context);
        return;
      }
      User u = User(
        googleID: gAccount.id,
        email: gAccount.email,
        userName: '@' + base64.encode(latin1.encode(gAccount.email)).toString(),
        profileName: gAccount.displayName,
        profilePic: 'default',
        bio: "This is my new ChooseNXT Account!",
        userID: base64.encode(latin1.encode(gAccount.email)).toString(),
        followers: [],
        numRated: 0,
        postIDs: [],
        following: [base64.encode(latin1.encode(gAccount.email)).toString()],
        private: false,
        ratedPosts: [],
        url: "",
        blockedUsers: [],
        brand: false,
      );
      await insertUser(u);
      currentUser = u;
      _firstTimeLogin = true;
      Navigator.pop(context);
      isSignedInWithGoogle = true;
      Navigator.pushReplacementNamed(context, '/createAccount');
    }
  }

// called in controlGoogleSignIn
  saveFacebookUserInfoToServer() async {
    var tempToken = (await facebookLogin.currentAccessToken);
    var token = tempToken.token;
    final graphResponse = await http.get(Uri.parse(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture.type(large),email&access_token=$token'));
    final profile = json.decode(graphResponse.body);
    User tempUser = await getDoesUserExists(profile['email']);
    switch (tempUser) {
      case null:
        print("Making an account with Facebook.");
        //insert eula here
        var result = await Navigator.pushNamed(context, '/eula');
        if (result == null || result == false) {
          facebookLogoutUser();
          Navigator.pop(context);
          return;
        }
        User u = User(
          facebookID: profile['id'],
          email: profile['email'],
          profileName: profile['name'],
          profilePic: "default",
          bio: "This is my new ChooseNXT Account!",
          userID: base64.encode(latin1.encode(profile['email'])).toString(),
          userName:
              '@' + base64.encode(latin1.encode(profile['email'])).toString(),
          numRated: 0,
          postIDs: [],
          following: [
            base64.encode(latin1.encode(profile['email'])).toString()
          ],
          followers: [],
          ratedPosts: [],
          private: false,
          url: "",
          blockedUsers: [],
          brand: false,
        );
        await insertUser(u);
        currentUser = u;
        _firstTimeLogin = true;
        Navigator.pop(context);
        isSignedInWithFacebook = true;
        Navigator.pushReplacementNamed(context, '/createAccount');
        break;
      default:
        print("User account found with Facebook email.");
        currentUser = tempUser;
        Navigator.pop(context);
        isSignedInWithFacebook = true;
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: [
            isSignedInWithGoogle,
            isSignedInWithFacebook,
            isSignedInWithApple,
          ],
        );
        break;
    }
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
      );
      await insertUser(u);
      currentUser = u;
      _firstTimeLogin = true;
      Navigator.pop(context);
      isSignedInWithApple = true;
      Navigator.pushReplacementNamed(context, '/createAccount');
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
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
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
                      child: const Text('Yes'),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, '/patronRegistration');
                      },
                    ),
                    SimpleDialogOption(
                      child: const Text('No'),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget _emailField() {
    return Container(
      padding: EdgeInsets.fromLTRB(60, 20, 60, 10),
      child: Theme(
        data: ThemeData().copyWith(
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: Colors.black,
              ),
        ),
        child: TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'name@example.com',
            label: const Text('email'),
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
      padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
      child: Theme(
        data: ThemeData().copyWith(
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: Colors.black,
              ),
        ),
        child: TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter your password',
            label: const Text('password'),
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
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blueGrey.shade900,
            onPrimary: Colors.black,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text(
            'Log In',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
              print(userCredential);
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

  Widget _loginButton() {
    return Container(
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
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
            print(userCredential);
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
        },
        child: Text('Login'),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: Container(
          // padding: EdgeInsets.symmetric(vertical: 0),
          // width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset('./assets/logos/ChooseNXT wide logo WBG.png',
                  width: 300,
                  height: 80,
                  fit: BoxFit.contain,
                  semanticLabel: 'WooLaLa logo'),
              _emailField(),
              _passwordField(),
              _signInButton(),
              _forgotPassword(),
              // Devider
              Container(
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
                        ),
                      ),
                    ),
                    Text('  or  '),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    ),
                  ],
                ),
              ),
              _buildSocialButtonRow(),
              _noAccount(),
              Container(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Choose New Releases from Creatives',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // }

  Widget _buildSocialBtn(Function onTap, AssetImage logo, String keyText) {
    return GestureDetector(
      onTap: () {
        onTap();
        signInProcess();
      },
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
        children: Platform.isIOS
            ? <Widget>[
                _buildSocialBtn(
                  () {
                    facebookLogoutUser();
                    googleLogoutUser();
                    facebookLoginUser();
                  },
                  AssetImage(
                    'assets/logos/facebook_logo.png',
                  ),
                  "Facebook",
                ),
                _buildSocialBtn(
                  () {
                    googleLogoutUser();
                    facebookLogoutUser();
                    googleLoginUser();
                  },
                  AssetImage(
                    'assets/logos/google_logo.png',
                  ),
                  "Google",
                ),
                _buildSocialBtn(
                  () {
                    googleLogoutUser();
                    facebookLogoutUser();
                    signInWithApple();
                  },
                  AssetImage('assets/logos/logo_apple.png'),
                  'Apple',
                )
              ]
            : <Widget>[
                _buildSocialBtn(
                  () {
                    facebookLogoutUser();
                    googleLogoutUser();
                    facebookLoginUser();
                  },
                  AssetImage(
                    'assets/logos/facebook_logo.png',
                  ),
                  "Facebook",
                ),
                _buildSocialBtn(
                  () {
                    googleLogoutUser();
                    facebookLogoutUser();
                    googleLoginUser();
                  },
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
