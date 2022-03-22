import 'package:firebase_core/firebase_core.dart';
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
import 'package:woolala_app/screens/eulaScreen.dart';

// Set to true if running app.js locally and want to connect to it instead
bool localDev = false;
String domain;

void main() async {
  if (localDev) {
    // domain = "http://10.0.2.2:5000";
    domain = "http://0.0.0.0:5000"; //when running Mac
    // domain = "http://Bryants-MacBook-Pro.local:5000";
  } else {
    domain = "https://woolala-2022.herokuapp.com";
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(WooLaLa());
}

class WooLaLa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    return MaterialApp(
      title: 'ChooseNXT',
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: primaryWhite,).copyWith(secondary: Colors.black),
        // This makes the visual density adapt to the platform that you run the app on. For desktop platforms, the controls will be smaller and closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black),
      ),
      initialRoute: '/',
      routes: {
        // easier use for multiple page navigation
        '/': (_) => LoginScreen(), //login screen
        // '/home' : (_) => HomepageScreen(false, false, false), //home page
        '/profile': (_) => ProfilePage(currentUser.email),
        '/editProfile': (_) => EditProfilePage(),
        '/search': (_) => SearchPage(),
        '/makepost': (_) => PostScreen(),
        '/imgup': (_) => ImageUploadScreen(),
        '/followerlist': (_) => FollowerListScreen(currentUser.email),
        '/followinglist': (_) => FollowingListScreen(currentUser.email),
        '/createAccount': (_) => CreateUserName(),
        '/eula': (_) => EulaPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == "/home") {
          final List<bool> args = settings.arguments as List<bool>;

          if (args == null) {
            return MaterialPageRoute(
              builder: (context) {
                return HomepageScreen(false, false, false);
              },
            );
          }

          return MaterialPageRoute(builder: (context) {
            return HomepageScreen(args[0], args[1], args[2]);
          });
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}

const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_blackPrimaryValue),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);
const int _blackPrimaryValue = 0xFF000000;

const MaterialColor primaryWhite = MaterialColor(
  _whitePrimaryValue,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_whitePrimaryValue),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);
const int _whitePrimaryValue = 0xFFFFFFFF;
