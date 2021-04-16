import 'package:flutter/material.dart';
import 'package:woolala_app/screens/EditProfileScreen.dart';
import 'package:woolala_app/screens/createUserName.dart';
import 'package:woolala_app/screens/follower_list_screen.dart';
import 'package:woolala_app/screens/following_list_screen.dart';
import 'package:woolala_app/screens/homepage_screen.dart';
import 'package:woolala_app/screens/imageupload_screen.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/screens/profile_screen.dart';
import 'package:woolala_app/screens/search_screen.dart';
import 'package:woolala_app/screens/post_screen.dart';

// Set to true if running app.js locally and want to connect to it instead
bool localDev = false;
String domain;

void main() {
  if (localDev)
  {
    domain = "http://10.0.2.2:5000";
  }
  else
  {
    domain = "https://hidden-caverns-85596.herokuapp.com";
  }

  runApp(WooLaLa());
}

class WooLaLa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChooseNXT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run the app on. For desktop platforms, the controls will be smaller and closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: { // easier use for multiple page navigation
        '/' : (_) => LoginScreen(), //login screen
        '/home' : (_) => HomepageScreen(true), //home page
        '/profile': (_) => ProfilePage(currentUser.email),
        '/editProfile': (_) => EditProfilePage(),
        '/search': (_) => SearchPage(),
        '/makepost': (_) => PostScreen(),
        '/imgup': (_) => ImageUploadScreen(),
        '/followerlist' : (_) => FollowerListScreen(currentUser.email),
        '/followinglist' : (_) => FollowingListScreen(currentUser.email),
        '/createAccount' : (_) => CreateUserName(),
      },
    );
  }
}