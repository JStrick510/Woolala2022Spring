import 'package:flutter/material.dart';
import 'package:woolala_app/screens/homepage_screen.dart';
import 'package:woolala_app/main.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/models/user.dart';
import 'package:woolala_app/screens/follower_list_screen.dart';
import 'package:woolala_app/screens/following_list_screen.dart';
import 'package:woolala_app/screens/search_screen.dart';
//import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget{
  //the id of this profile
  final String userProfileEmail;
  ProfilePage(this.userProfileEmail);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //the account we are currently logged into
  final String currentOnlineUserEmail = currentUser.email;
  User profilePageOwner;

  createProfileTop() {
    setState(() {});
    return FutureBuilder(
      future: getDoesUserExists(widget.userProfileEmail),
      builder: (context, dataSnapshot) {
        switch (dataSnapshot.connectionState) {
          case ConnectionState.waiting: return Text('Loading....');
          default:
            if (dataSnapshot.hasError)
              return Text('Error: ${dataSnapshot.error}');
            else
              print('Result: ${dataSnapshot.data}');
        }
       // print(dataSnapshot);
        //print(dataSnapshot.data);
        profilePageOwner = dataSnapshot.data;
        //eventually get this from the sign in
        //String profilePic = profilePageOwner.profilePic;

        return Padding(
            padding: EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  profilePageOwner.createProfileAvatar(),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      profilePageOwner.profileName, style: TextStyle(fontSize: 32.0, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 1.0),
                    child: Text(
                      profilePageOwner.userName, style: TextStyle(fontSize: 16.0, color: Colors.black38),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 3.0),
                    child: Text(
                      profilePageOwner.bio, style: TextStyle(fontSize: 20.0, color: Colors.black54, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  createColumns("Posts", profilePageOwner.numPosts),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => FollowerListScreen(widget.userProfileEmail)));
                                    },
                                    child: createColumns("Followers", profilePageOwner.numFollowers),
                                  ),

                                  createColumns("Ratings", profilePageOwner.numRated),

                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => FollowingListScreen(widget.userProfileEmail)));
                                    },
                                    child: createColumns("Following", profilePageOwner.following.length),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                createButton(),
                              ],
                            )
                          ],
                        ),
                      ),
                     ],
                  ),
                ],
            ),

        );
      },
    );
  }



  Column createColumns(String title, int count){
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Future<bool> checkIfFollowing() async{
    User currentUser = await getDoesUserExists(currentOnlineUserEmail);
    User viewingUser = await getDoesUserExists(widget.userProfileEmail);
    for(int i = 0; i < currentUser.following.length; i++) {
      if(currentUser.following[i] == viewingUser.userID){
        print("true!");
        return true;
      }
    }
    return false;
    }

  createButton() {
    bool ownProfile = currentOnlineUserEmail == widget.userProfileEmail;
    //bool checker =  await checkIfFollowing();

    if(ownProfile)
    {
      return createButtonTitleAndFunction(title: 'Edit Profile', performFunction: editUserProfile,);
    }
    //else if(checker){
    //  return createButtonTitleAndFunction(title: 'Following',);
    //}
    else{
      return createButtonTitleAndFunction(title: 'Follow',);
    }
  }

  Container createButtonTitleAndFunction({String title, Function performFunction}){
  return Container(
    padding: EdgeInsets.only(top: 3.0),
    child: FlatButton(
      onPressed: performFunction,
      key: ValueKey(title),
      child: Container(
        width: 280.0,
        height: 35.0,
        child: Text(title, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2.0),
            borderRadius: BorderRadius.circular(6.0),
        ),
      ),
    ),
  );
  }
  
  editUserProfile() {
    Navigator.pushReplacementNamed(context, '/editProfile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton (
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), //place holder
          color: Colors.white,
        ),
        title: Text('WooLaLa', style: TextStyle(fontSize: 25, fontFamily: 'Lucida'), textAlign: TextAlign.center,),
        key: ValueKey("homepage"),
        actions: <Widget>[
          IconButton (
            icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage())),
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => {},//callFromHomePage(context),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          createProfileTop(),
        ],

      ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) {
            switchPage(index, context);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.black),
              title: Text('Home', style: TextStyle(color: Colors.black)),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, color: Colors.black),
              title: Text("New", style: TextStyle(color: Colors.black)),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Theme.of(context).primaryColor),
              title: Text("Profile", style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
          ]
      ),
    );
  }

  void switchPage(int index, BuildContext context) {
    switch(index) {
      case 0: {
        Navigator.pushReplacementNamed(context, '/home');}
      break;
      case 1: {
        Navigator.pushReplacementNamed(context, '/imgup');}
      break;
    }
  }
}