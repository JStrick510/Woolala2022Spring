import 'package:flutter/material.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/screens/profile_screen.dart';

class BottomNav {
  BottomNav(context);
  BuildContext context;

  int currentIndex = 1;

   List bottom_items = <BottomNavigationBarItem>[
     BottomNavigationBarItem(
       icon: Icon(
         Icons.add_circle,
         key: ValueKey("Make Post"),
         color: Colors.white),
       title: Text(
         "New",
         style: TextStyle(color: Colors.white),
       ),
     ),
     BottomNavigationBarItem(
        icon: Icon(Icons.home, color: Colors.white),
        activeIcon: Icon(Icons.home, color: Colors.white),
        title: Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.person,
          key: ValueKey("Profile"),
          color: Colors.white,
        ),
        activeIcon: Icon(
          Icons.person,
          color: Colors.white,
        ),
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
    ];

  void switchPage(int index, BuildContext context) {
    switch (index) {
      case 0:
        {
          if (!(ModalRoute.of(context).settings.name == '/imgup')) {
            Navigator.pushNamed(context, '/imgup');

          }
        }
        break;
      case 1:
        {
          if (currentIndex != 1) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
        break;
      case 2:
        {
          if (currentIndex != 2) {
            Navigator.push(context, MaterialPageRoute(
                builder: (BuildContext context) =>
                    ProfilePage(currentUser.email)));
          }
        }
        break;
    }
  }

}