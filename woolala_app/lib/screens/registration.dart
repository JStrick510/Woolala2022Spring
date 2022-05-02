import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/models/user.dart' as model;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:woolala_app/Provider/sign_in_provider.dart';

class Registration extends StatefulWidget {
  final String tier;

  Registration(String this.tier) {}

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _profileNameController = TextEditingController();
  final _userHandleController = TextEditingController();
  bool isPasswordVisble = false;
  final tiers = ['Business', 'Patron'];
  String tier; // Manages the URL text field's show up
  bool
      emailPasswordActivated; // Manages show up of the email and password registration fields
  SignInProvider signInProvider =
      SignInProvider(); // Required to call Facebook or Google log in method

  @override
  void initState() {
    _emailController.addListener(() => setState(() {}));
    _urlController.addListener(() => setState(() {}));
    _profileNameController.addListener(() => setState(() {}));
    _userHandleController.addListener(() => setState(() {}));
    this.tier = widget.tier;
    emailPasswordActivated = false;
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _profileNameController.dispose();
    _userHandleController.dispose();
    super.dispose();
  }

  Widget _emailField() {
    return _generalTextFieldBuilder(
      ctrl: _emailController,
      businessHint: 'business@myCompany.co',
      patronHint: 'name@example.com',
      businessLabel: 'email',
      patronLabel: 'email',
      prefixIcon: Icon(Icons.email),
    );
  }

  Widget _passwordField() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
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

  Widget _urlField() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Theme(
        data: ThemeData().copyWith(
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: Colors.black,
              ),
        ),
        child: TextField(
          controller: _urlController,
          // keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'https://example.co',
            label: const Text('Business Web Address'),
            prefixIcon: Icon(Icons.add_link),
            suffixIcon: _urlController.text.isEmpty
                ? Container(
                    width: 0,
                  )
                : IconButton(
                    onPressed: () => _urlController.clear(),
                    icon: Icon(Icons.close),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _profileNameField() {
    return _generalTextFieldBuilder(
      ctrl: _profileNameController,
      businessHint: 'ChooseNXT',
      patronHint: 'Tito Chowdhury',
      businessLabel: 'Business Name',
      patronLabel: 'Profile Name',
      prefixIcon: Icon(Icons.account_box_rounded),
    );
  }

  Widget _userHandleField() {
    return _generalTextFieldBuilder(
      ctrl: _userHandleController,
      businessHint: '@Choose_NXT123',
      patronHint: '@Tito_Chowdhury123',
      businessLabel: 'Unique Business Handle',
      patronLabel: 'Unique Profile Handle',
      prefixIcon: Icon(Icons.alternate_email_sharp),
    );
  }

  Widget _signUpButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.blueGrey.shade900,
          onPrimary: Colors.black,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'Sign Up',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          if (await _checkRequirements()) {
            final password = _passwordController.text;
            final email = _emailController.text;
            try {
              final userCredential = await fba.FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
              await _saveAccountToServer(
                email: _emailController.text,
                profileName: _profileNameController.text,
              );
              Navigator.pushReplacementNamed(context, '/editProfile');
              // print(userCredential);
            } on fba.FirebaseAuthException catch (e) {
              errorHandling(e);
            }
          }
        },
      ),
    );
  }

  Widget _googleSignUpButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: Colors.blueGrey[50],
          onPrimary: Colors.black,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () async {
          if (await _urlAndHandleCheck()) {
            GoogleSignInAccount googleUser = await signInProvider.googleLogIn();
            // If accepted EULA, create a new account
            _saveAccountToServer(
              email: googleUser.email,
              profileName: googleUser.displayName,
              // googleID: googleUser.id,
            );
          }
        },
        label: const Text('Sign up with Google'),
        icon: const FaIcon(
          FontAwesomeIcons.google,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _facebookSignUpButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: Colors.blueGrey[50],
          onPrimary: Colors.black,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () async {
          if (await _urlAndHandleCheck()) {
            // get the user information from Facebook signin
            Map<String, dynamic> userdata =
                await signInProvider.facebookLogIn();
            _saveAccountToServer(
              email: userdata['email'],
              profileName: userdata['name'],
            );
          }
        },
        label: const Text('Sign up with Facebook'),
        icon: const FaIcon(
          FontAwesomeIcons.facebook,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _signUpWithEmailButton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: Colors.blueGrey[50],
          onPrimary: Colors.black,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () async {
          if (await _urlAndHandleCheck()) {
            setState(() {
              emailPasswordActivated = !emailPasswordActivated;
            });
          }
        },
        label: const Text('Sign up with email and password'),
        icon: Icon(Icons.email_outlined),
      ),
    );
  }

  // called in controlGoogleSignIn
  _saveAccountToServer({@required String email, String profileName}) async {
    model.User tempUser = await getDoesUserExists(email);
    if (tempUser != null) {
      print("User already exist");
      final snackBar = SnackBar(
          content: const Text(
              'The user already exist!\nPlease sign in with your account.'));
      signInProvider.logout();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context);
      return;
    } else {
      // Use hase to accept the End User License Agreement (EULA) to continue to use the app
      var result = await Navigator.pushNamed(context, '/eula');
      if (result == null || result == false) {
        signInProvider.logout();
        Navigator.pop(context);
        return;
      }
      model.User u = model.User(
        // googleID: googleID,
        email: email,
        userName: '@' + _userHandleController.text,
        profileName: profileName,
        profilePic: 'default',
        bio: "This is my new ChooseNXT Account!",
        userID: base64.encode(latin1.encode(email)).toString(),
        followers: [],
        numRated: 0,
        postIDs: [],
        following: [base64.encode(latin1.encode(email)).toString()],
        private: false,
        ratedPosts: [],
        url: _urlController.text,
        blockedUsers: [],
        brand: tier == 'Business',
        conversations: [],
      );
      // print(u.brand);
      await insertUser(u);
      currentUser = u;
      Navigator.pushReplacementNamed(context, '/editProfile');
    }
  }

  Future<bool> _checkRequirements() async {
    http.Response res = await model.User.isUserNameTaken(
        _userHandleController.text); // User handle must be unique

    if (_emailController.text.isEmpty) {
      showAlertDialog(
        title: 'Email address Error!',
        content: 'Please enter your email address.',
        context: context,
      );
    } else if (_passwordController.text.isEmpty) {
      showAlertDialog(
        title: 'Password Error!',
        content: 'Please enter your password.',
        context: context,
      );
    } else if (!res.body.isEmpty) {
      // print(res.body);
      showAlertDialog(
        title: 'User handle Error!',
        content: 'This Username is already taken!',
        context: context,
      );
    } else if (_profileNameController.text.isEmpty) {
      showAlertDialog(
        title: 'Profile Name Error!',
        content: 'Please enter your profile name.',
        context: context,
      );
    } else {
      return true;
    }
    return false;
  }

  void errorHandling(err) {
    // print(err.code);
    if (err.code == 'email-already-in-use') {
      showAlertDialog(
        title: 'Username Error!',
        content: 'This email address is already in use!',
        context: context,
      );
      _emailController.clear();
    }
  }

  void showAlertDialog({String title, String content, BuildContext context}) =>
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(content),
        ),
      );

  // Encapsulate similar textfields: email, profile name, user handle
  Widget _generalTextFieldBuilder({
    TextEditingController ctrl,
    String businessHint,
    String patronHint,
    String businessLabel,
    String patronLabel,
    Icon prefixIcon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Theme(
        data: ThemeData().copyWith(
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: Colors.black,
              ),
        ),
        child: TextField(
          controller: ctrl,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: tier == 'Business' ? businessHint : patronHint,
            label: tier == 'Business' ? Text(businessLabel) : Text(patronLabel),
            prefixIcon: prefixIcon,
            suffixIcon: ctrl.text.isEmpty
                ? Container(
                    width: 0,
                  )
                : IconButton(
                    onPressed: () => ctrl.clear(),
                    icon: Icon(Icons.close),
                  ),
          ),
        ),
      ),
    );
  }

// User should have to move back to the login page if came here by mistake
  Widget _logIn() {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Already have an account?'),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text(
              'Log in here',
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

// Registration requires the "user handle" and "url" (for business tier) fields
// to creat a new account.
  Future<bool> _urlAndHandleCheck() async {
    if (tier == 'Business' && _urlController.text.isEmpty) {
      showAlertDialog(
        title: 'URL Error!',
        content: 'Please enter your URL.',
        context: context,
      );
      return false;
    }
    if (_userHandleController.text.isEmpty) {
      showAlertDialog(
        title: 'User Handle Error!',
        content: 'Please enter your username',
        context: context,
      );
      return false;
    } else {
      http.Response res =
          await model.User.isUserNameTaken(_userHandleController.text);
      print(_userHandleController.text);
      print(res);
      if (!res.body.isEmpty) {
        showAlertDialog(
          title: 'User handle Error!',
          content: 'This Username is already taken!',
          context: context,
        );
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
        children: [
          tier == 'Business' ? _urlField() : SizedBox(),
          _userHandleField(),
          _googleSignUpButton(context),
          // _facebookSignUpButton(context),
          _signUpWithEmailButton(),
          SizedBox(height: 20),
          if (emailPasswordActivated) _emailField(),
          if (emailPasswordActivated) _passwordField(),
          if (emailPasswordActivated) _profileNameField(),
          if (emailPasswordActivated) _signUpButton(),
          _logIn(),
        ],
      ),
    );
  }
}
