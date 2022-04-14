// import 'dart:html';

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
  bool isPasswordVisble = false;
  final tiers = ['Business', 'Patron'];
  String tier = 'Patron';

  @override
  void initState() {
    _emailController.addListener(() => setState(() {}));
    _urlController.addListener(() => setState(() {}));
    tier = 'Patron';
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
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

  Widget _urlField() {
    return Container(
      padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
      child: TextField(
        controller: _urlController,
        // keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'https://example.co',
          label: const Text('URL'),
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
    );
  }

  Widget _signUpButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.shade200,
              offset: Offset(2, 4),
              blurRadius: 5,
              spreadRadius: 2)
        ],
      ),
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        ),
        onPressed: () async {
          final password = _passwordController.text;
          final email = _emailController.text;
          try {
            final userCredential =
                await fba.FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
            await saveAccountToServer();
            // Navigator.pushReplacementNamed(context, '/search');
            print(userCredential);
          } on fba.FirebaseAuthException catch (e) {
            errorHandling(e);
          }
        },
        child: Text('Sign Up'),
      ),
    );
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
        userName: '@' +
            base64.encode(latin1.encode(_emailController.text)).toString(),
        profileName: 'myName',
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
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: ListView(
        children: [
          _emailField(),
          _passwordField(),
          tier == 'Business' ? _urlField() : SizedBox(),
          _accountType(),
          _signUpButton(),
        ],
      ),
    );
  }
}
