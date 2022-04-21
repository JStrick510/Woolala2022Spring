import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/models/user.dart' as model;
import 'package:http/http.dart' as http;
import 'dart:convert';

class Registration extends StatefulWidget {
  Registration({Key key}) : super(key: key);

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
  String tier = 'Patron';

  @override
  void initState() {
    _emailController.addListener(() => setState(() {}));
    _urlController.addListener(() => setState(() {}));
    _profileNameController.addListener(() => setState(() {}));
    _userHandleController.addListener(() => setState(() {}));
    tier = 'Patron';
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

  Widget _accountType() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          const Text('What account tier are you looking for?'),
          Container(
            width: 120,
            margin: EdgeInsets.only(top: 10.0),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black.withOpacity(0.25),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: tier,
                isExpanded: true,
                items: tiers.map(buildMenuItem).toList(),
                onChanged: (value) {
                  setState(() => (tier = value));
                  print(tier);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) {
    return DropdownMenuItem(
      value: item,
      child: Text(
        item,
        // style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
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
      padding: EdgeInsets.symmetric(vertical: 10),
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
      padding: EdgeInsets.symmetric(vertical: 10),
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
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10),
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
              await saveAccountToServer();
              // Navigator.pushReplacementNamed(context, '/search');
              print(userCredential);
            } on fba.FirebaseAuthException catch (e) {
              errorHandling(e);
            }
          }
        },
      ),
    );
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
      print(res.body);
      showAlertDialog(
        title: 'User handle Error!',
        content: 'This Username is already taken!',
        context: context,
      );
    } else {
      return true;
    }
    return false;
  }

  // called in controlGoogleSignIn
  saveAccountToServer() async {
    // showAlertDialog(context);
    // final GoogleSignInAccount gAccount = gSignIn.currentUser;
    model.User tempUser = await getDoesUserExists(_emailController.text);
    if (tempUser != null && tempUser.userID != "") //account exists
    {
      //
    } else {
      print("Making an account with email and password.");
      //insert eula here
      var result = await Navigator.pushNamed(context, '/eula');
      if (result == null || result == false) {
        // googleLogoutUser();
        // Add firebase logout here
        Navigator.pop(context);
        return;
      }
      model.User u = model.User(
        // googleID: gAccount.id,
        email: _emailController.text,
        userName: '@' + _userHandleController.text,
        profileName: _profileNameController.text,
        profilePic: 'default',
        bio: "This is my new ChooseNXT Account!",
        userID: base64.encode(latin1.encode(_emailController.text)).toString(),
        followers: [],
        numRated: 0,
        postIDs: [],
        following: [
          base64.encode(latin1.encode(_emailController.text)).toString()
        ],
        private: false,
        ratedPosts: [],
        url: _urlController.text,
        blockedUsers: [],
        brand: tier == 'Business',
      );
      print(u.brand);
      await insertUser(u);
      currentUser = u;
      Navigator.pushReplacementNamed(context, '/editProfile');
    }
  }

  void errorHandling(err) {
    print(err.code);
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
      padding: EdgeInsets.symmetric(vertical: 10),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
        children: [
          _emailField(),
          _passwordField(),
          _profileNameField(),
          _userHandleField(),
          tier == 'Business' ? _urlField() : SizedBox(),
          _accountType(),
          _signUpButton(),
        ],
      ),
    );
  }
}
