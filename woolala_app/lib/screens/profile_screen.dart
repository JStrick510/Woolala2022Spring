import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:woolala_app/main.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/models/user.dart';
import 'package:woolala_app/screens/follower_list_screen.dart';
import 'package:woolala_app/screens/following_list_screen.dart';
import 'package:woolala_app/screens/search_screen.dart';
import 'package:woolala_app/widgets/bottom_nav.dart';
import 'package:http/http.dart' as http;
import 'package:woolala_app/widgets/profile_card.dart';
import 'package:woolala_app/widgets/card.dart';
import 'dart:math';

class ProfilePage extends StatefulWidget {
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
  bool checker = false;
  User viewingUser;
  List postIDs = [];
  int numToShow = 1;
  int postsPerReload = 2;
  var ratedPosts = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  initState() {
    getStartingFeed();
    super.initState();
    getRatedPosts(currentUser.userID).then((list) {
      ratedPosts = list;
    });
  }

  Future<List> getRatedPosts(String userID) async {
    http.Response res = await http.get(Uri.parse(domain + '/getRatedPosts/' + userID));
    return jsonDecode(res.body.toString());
  }

  Future<List> getOwnFeed() async {
    print("USERID");
    print(profilePageOwner.userID);
    http.Response res =
        await http.get(Uri.parse(domain + '/getOwnFeed/' + profilePageOwner.userID));
    return jsonDecode(res.body.toString());
  }

  createProfileTop() {
    return FutureBuilder(
      future: getDoesUserExists(widget.userProfileEmail),
      builder: (context, dataSnapshot) {
        switch (dataSnapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            if (dataSnapshot.hasError)
              return Text('Error: ${dataSnapshot.error}');
            else
              print('Result: ${dataSnapshot.data}');
        }
        profilePageOwner = dataSnapshot.data;
        return SizedBox(
            height: 360,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  profilePageOwner.createProfileAvatar(),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      profilePageOwner.profileName.substring(0,min(22,profilePageOwner.profileName.length)),
                      style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 1.0),
                    child: Text(
                      profilePageOwner.userName,
                      style: TextStyle(fontSize: 16.0, color: Colors.black38),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 3.0),
                    child: Text(
                      profilePageOwner.bio,
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  createIntColumns(
                                      "Posts", profilePageOwner.postIDs.length),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FollowerListScreen(widget
                                                      .userProfileEmail)));
                                    },
                                    child: createIntColumns("Followers",
                                        profilePageOwner.followers.length),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FollowingListScreen(widget
                                                      .userProfileEmail)));
                                    },
                                    child: createIntColumns("Following",
                                        profilePageOwner.following.length - 1),
                                  ),
                                  createAveragesColumn("Avg."),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: FutureBuilder(
                                    future: checkIfFollowing(),
                                    builder: (context, snapshot) {
                                      return createButton();
                                    },
                                  ),
                                ),
                                //createButton(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }

  void sortPosts(list) {
    list.removeWhere((item) => item == "");
    list.sort((a, b) =>
        int.parse(b.substring(b.indexOf(':::') + 3)) -
        int.parse(a.substring(a.indexOf(':::') + 3)));
  }

  void getStartingFeed() async {
    profilePageOwner = await getDoesUserExists(widget.userProfileEmail);
    if (currentUser != null)
      getOwnFeed().then((list) {
        postIDs = list;
        if (postIDs.length == 0)
          numToShow = 1;
        else
          numToShow = postsPerReload;
        sortPosts(postIDs);
        setState(() {});
      });
  }

  void _onRefresh() async {
    postIDs = await getOwnFeed();
    sortPosts(postIDs);
    // if failed,use refreshFailed()
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    if (numToShow + postsPerReload > postIDs.length) {
      numToShow = postIDs.length + 1;
    } else {
      numToShow += postsPerReload;
    }

    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  Column createIntColumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          getFormattedText(count.toString()),
          style: TextStyle(
              fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 3.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
                fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  String getFormattedText(String number) {
    if (number.length < 4) {
      //text < 1000
      return number;
    } else if (number.length < 7) {
      //text < 1,000,000
      return number[0] + "." + number[1] + " K";
    } else if (number.length < 10) {
      //text < 1,000,000,000
      return number[0] + "." + number[1] + " M";
    } else {
      // text > 1 billion
      return number[0] + "." + number[1] + " B";
    }
  }

  createAveragesColumn(String title) {
    return FutureBuilder(
        future: profilePageOwner.getAvgScore(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              if (snapshot.hasError)
                print('Error: ${snapshot.error}');
              else
                print('Result: ${snapshot.data}');
          }

          double avg;
          if(snapshot.data == null)
            {
              avg = 0.0;
            }
          else{
            avg = snapshot.data;
          }
          return createDoubleColumns(title, avg);
        });
  }

  Column createDoubleColumns(String title, double count) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toStringAsFixed(2),
          style: TextStyle(
              fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 3.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
                fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  checkIfFollowing() async {
    User currentUser = await getDoesUserExists(currentOnlineUserEmail);
    viewingUser = await getDoesUserExists(widget.userProfileEmail);
    for (int i = 0; i < currentUser.following.length; i++) {
      if (currentUser.following[i] == viewingUser.userID) {
        checker = true;
      }
    }
  }

  createButton() {
    bool ownProfile = currentOnlineUserEmail == widget.userProfileEmail;
    if (ownProfile) {
      return createButtonTitleAndFunction(
          title: 'Edit Profile',
          performFunction: editUserProfile,
          color: Colors.white);
    } else if (checker) {
      return createButtonTitleAndFunction(
          title: 'Unfollow',
          futureFunctionName: "unfollowUser",
          color: Colors.red[400]);
    } else {
      return createButtonTitleAndFunction(
          title: 'Follow',
          futureFunctionName: "followUser",
          color: Colors.blue);
    }
  }

  Widget createButtonTitleAndFunction(
      {String title,
      Function performFunction,
      String futureFunctionName,
      Color color}) {
    if (futureFunctionName == "followUser") {
      return Container(
        padding: EdgeInsets.only(top: 3.0),
        child: FlatButton(
          onPressed: () {
            FutureBuilder(
                future: follow(currentUser.userID, viewingUser.userID),
                builder: (context, snapshot) {});
            Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      ProfilePage(viewingUser.email),
                  transitionDuration: Duration(seconds: 0),
                ));
          },
          key: ValueKey(title),
          child: Container(
            width: 280.0,
            height: 35.0,
            child: Text(
              title,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
        ),
      );
    } else if (futureFunctionName == "unfollowUser") {
      return Container(
        padding: EdgeInsets.only(top: 3.0),
        child: FlatButton(
          onPressed: () {
            FutureBuilder(
                future: unfollow(currentUser.userID, viewingUser.userID),
                builder: (context, snapshot) {});
            Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      ProfilePage(viewingUser.email),
                  transitionDuration: Duration(seconds: 0),
                ));
          },
          key: ValueKey(title),
          child: Container(
            width: 280.0,
            height: 35.0,
            child: Text(
              title,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(top: 3.0),
        child: FlatButton(
          onPressed: performFunction,
          key: ValueKey(title),
          child: Container(
            width: 280.0,
            height: 35.0,
            child: Text(
              title,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
        ),
      );
    }
  }

  editUserProfile() {
    Navigator.pushReplacementNamed(context, '/editProfile');
  }

  @override
  Widget build(BuildContext context) {
    BottomNav bottomBar = BottomNav(context);
    bottomBar.currentIndex = 2;
    bottomBar.currEmail = currentUser.email;

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Text(
          'WooLaLa',
          style: TextStyle(fontSize: 25, fontFamily: 'Lucida'),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        key: ValueKey("homepage"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => SearchPage())),
          ),
        ],
      ),
      body: Center(
        child: numToShow > 0
            ? SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                header: ClassicHeader(),
                footer: ClassicFooter(),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: numToShow,
                    addAutomaticKeepAlives: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return SizedBox(
                          width: double.infinity,
                          height: 360,
                          child: createProfileTop(),
                        );
                      } else {
                        // The height on this will need to be edited to match whatever height is set for the picture
                        if (profilePageOwner.userID == currentUser.userID) {
                          return SizedBox(
                              width: double.infinity,
                              height: 620,
                              child: OwnFeedCard(postIDs[index - 1]));
                        } else {
                          return SizedBox(
                              width: double.infinity,
                              height: 620,
                              child: FeedCard(postIDs[index - 1], ratedPosts));
                        }
                      }
                    }),
              )
            : Padding(
                padding: EdgeInsets.all(70.0),
                child: Text("Make a post to see it here!",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.grey,
                        fontFamily: 'Lucida'))),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int pageIndex) {
          bottomBar.switchPage(pageIndex, context);
        },
        items: bottomBar.bottom_items,
        backgroundColor: Colors.blue,
      ),
    );
  }
}
