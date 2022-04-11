import 'package:flutter/material.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/screens/profile_screen.dart';

class BottomNav {
  BottomNav(context);
  BuildContext context;

  int currentIndex = 1;
  String currEmail;

  bool brand = false;

  List bottomItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.add_circle,
          key: ValueKey("Make Post"), color: Colors.black),
      label: "New",
      //title: Text(
      //"New",
      //style: TextStyle(color: Colors.black),
      //),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.home, color: Colors.black),
      activeIcon: Icon(Icons.home, color: Colors.black),
      label: "Home",
      //title: Text(
        //'Home',
        //style: TextStyle(color: Colors.black),
      //),
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.person,
        key: ValueKey("Profile"),
        color: Colors.black,
      ),
      activeIcon: Icon(
        Icons.person,
        color: Colors.black,
      ),
      label: "Profile",
      //title: Text(
        //"Profile",
        //style: TextStyle(color: Colors.black),
      //),
    ),
  ];

  void switchPage(int index, BuildContext context) {
    if(this.brand) {
      switch (index) {
        case 0:
          {
            if (currentIndex != 0) {
              if (currentIndex == 2) {
                Navigator.popAndPushNamed(context, '/imgup');
              } else {
                Navigator.pushNamed(context, '/imgup');
              }
            }
          }
          break;
        case 1:
          {
            if (currentIndex != 1) {
              if (currentIndex == 2 || currentIndex == 0) {
                do {
                  Navigator.pop(context);
                } while (Navigator.canPop(context));
                Navigator.pushReplacementNamed(context, '/home');
              }
            }
          }
          break;
        case 2:
          {
            if (currentIndex != 2) {
              if (currentIndex == 0) {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ProfilePage(currentUser.email)));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ProfilePage(currentUser.email)));
              }
            } else if (currEmail == currentUser.email) {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ProfilePage(currentUser.email)));
            }
          }
          break;
      }
    }
    else{
      switch (index) {
        case 0:
          {
            if (currentIndex != 1) {
              if (currentIndex == 2 || currentIndex == 0) {
                do {
                  Navigator.pop(context);
                } while (Navigator.canPop(context));
                Navigator.pushReplacementNamed(context, '/home');
              }
            }
          }
          break;
        case 1:
          {
            if (currentIndex != 2) {
              if (currentIndex == 0) {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ProfilePage(currentUser.email)));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ProfilePage(currentUser.email)));
              }
            } else if (currEmail == currentUser.email) {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ProfilePage(currentUser.email)));
            }
          }
          break;
      }
    }
  }

  List<BottomNavigationBarItem> getItems()
  {
    List<BottomNavigationBarItem> bottomItems = [];

    if(this.brand){
      bottomItems = [
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle,
              key: ValueKey("Make Post"), color: Colors.black),
          label: "New",
          //title: Text(
          //"New",
          //style: TextStyle(color: Colors.black),
          //),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.black),
          activeIcon: Icon(Icons.home, color: Colors.black),
          label: "Home",
          //title: Text(
          //'Home',
          //style: TextStyle(color: Colors.black),
          //),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            key: ValueKey("Profile"),
            color: Colors.black,
          ),
          activeIcon: Icon(
            Icons.person,
            color: Colors.black,
          ),
          label: "Profile",
          //title: Text(
          //"Profile",
          //style: TextStyle(color: Colors.black),
          //),
        ),
      ];
    }

    else{
      bottomItems = [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.black),
          activeIcon: Icon(Icons.home, color: Colors.black),
          label: "Home",
          //title: Text(
          //'Home',
          //style: TextStyle(color: Colors.black),
          //),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            key: ValueKey("Profile"),
            color: Colors.black,
          ),
          activeIcon: Icon(
            Icons.person,
            color: Colors.black,
          ),
          label: "Profile",
          //title: Text(
          //"Profile",
          //style: TextStyle(color: Colors.black),
          //),
        ),
      ];
    }

    return bottomItems;
  }
}
