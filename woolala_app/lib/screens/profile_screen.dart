import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:woolala_app/main.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/models/user.dart';
import 'package:woolala_app/screens/chat_screen.dart';
import 'package:woolala_app/screens/follower_list_screen.dart';
import 'package:woolala_app/screens/following_list_screen.dart';
import 'package:woolala_app/screens/search_screen.dart';
import 'package:woolala_app/widgets/bottom_nav.dart';
import 'package:http/http.dart' as http;
import 'package:woolala_app/widgets/profile_card.dart';
import 'package:woolala_app/widgets/card.dart';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool isBlocked = true;
  bool isClient = false;
  User viewingUser;
  User tempUser;
  List postIDs = [];
  int numToShow = 1;
  int postsPerReload = 2;
  var ratedPosts = [];
  bool feedLoading = true;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  initState() {
    super.initState();
    // getStartingFeed();
    // getRatedPosts(currentUser.userID).then((list) {
    //   ratedPosts = list;
    // });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getStartingFeed();
      getRatedPosts(currentUser.userID).then((list) {
        ratedPosts = list;
      });
    });
  }

  Future<List> getRatedPosts(String userID) async {
    http.Response res =
        await http.get(Uri.parse(domain + '/getRatedPosts/' + userID));
    return jsonDecode(res.body.toString());
  }

  Future<List> getOwnFeed() async {
    print("USERID");
    print(profilePageOwner.userID);
    http.Response res = await http
        .get(Uri.parse(domain + '/getOwnFeed/' + profilePageOwner.userID));
    return jsonDecode(res.body.toString());
  }

  createProfileTop() {
    return FutureBuilder(
      future: getDoesUserExists(widget.userProfileEmail),
      builder: (context, dataSnapshot) {
        switch (dataSnapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  strokeWidth: 8,
                ),
              ),
            );
          default:
            if (dataSnapshot.hasError)
              return Text('Error: ${dataSnapshot.error}');
            else
              print('Result: ${dataSnapshot.data}');
        }
        profilePageOwner = dataSnapshot.data;
        return SizedBox(
          // height: 360,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                profilePageOwner.createProfileAvatar(),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text(
                    profilePageOwner.profileName.substring(
                        0, min(22, profilePageOwner.profileName.length)),
                    style: TextStyle(
                        fontSize: 20.0, //30
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 1.0),
                  child: Text(
                    profilePageOwner.userName,
                    style: TextStyle(fontSize: 12.0, color: Colors.black38), //16
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 3.0),
                  child: Text(
                    profilePageOwner.bio,
                    style: TextStyle(
                        fontSize: 16.0, //20
                        color: Colors.black54,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                profilePageOwner.url != null && profilePageOwner.url != ""
                    ? Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 3.0),
                        child: Text(
                          profilePageOwner.url,
                          style: TextStyle(
                              fontSize: 14.0, //16
                              color: Colors.black54,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    : Container(),
                // 2 rows 1st posts followers following avg row 2nd buttons
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
                                createIntColumns(
                                    "Posts", profilePageOwner.postIDs.length),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FollowerListScreen(
                                                    widget.userProfileEmail)));
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
                                                FollowingListScreen(
                                                    widget.userProfileEmail)));
                                  },
                                  child: createIntColumns("Following",
                                      profilePageOwner.following.length - 1),
                                ),
                                createAveragesColumn("Avg."),
                              ],
                            ),
                          ),
                          // 2nd row buttons edit profile, follow, block
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Builder(
                                  builder: (BuildContext context) {
                                    if (currentOnlineUserEmail !=
                                        widget.userProfileEmail)
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: 12.0, left: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            createButton(),
                                            Expanded(
                                              child: createBlockButton(),
                                            ),
                                          ],
                                        ),
                                      );
                                    else {
                                      return Padding(
                                        padding: EdgeInsets.only(top: 12),
                                        child: createButton(),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          // 3rd row DM/Client buttons
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Builder(
                                  builder: (BuildContext context) {
                                    if (currentOnlineUserEmail !=
                                        widget.userProfileEmail)
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: 12.0, left: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            createDMButton(),
                                            Expanded(
                                              child: createClientButton(),
                                            ),
                                          ],
                                        ),
                                      );
                                    else {
                                      return Container();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
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
    feedLoading = true;
    profilePageOwner = await getDoesUserExists(widget.userProfileEmail);
    tempUser = await getDoesUserExists(currentOnlineUserEmail);
    await checkBlockandFollowing();
    if (currentUser != null)
      getOwnFeed().then((list) {
        if (isBlocked) {
          numToShow = 1;
        } else {
          postIDs = list;
          if (postIDs.length == 0)
            numToShow = 1;
          else
            numToShow = postsPerReload;
        }
        sortPosts(postIDs);
        setState(() {
          feedLoading = false;
        });
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
    print('isBlocked: $isBlocked');
    print('isFollowing: $checker');
    await Future.delayed(Duration(milliseconds: 1000));

    if (numToShow + postsPerReload > postIDs.length) {
      numToShow = postIDs.length + 1;
    } else {
      numToShow += postsPerReload;
    }

    if (isBlocked) {
      numToShow = 1;
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
              fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold), //20
        ),
        Container(
          margin: EdgeInsets.only(top: 3.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 12.0, //16
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
              // return CircularProgressIndicator();
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                  ),
                ],
              );
            default:
              if (snapshot.hasError)
                print('Error: ${snapshot.error}');
              else
                print('Result: ${snapshot.data}');
          }

          double avg;
          if (snapshot.data == null) {
            avg = 0.0;
          } else {
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
              fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold), //20
        ),
        Container(
          margin: EdgeInsets.only(top: 3.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 12.0, //18
                color: Colors.black,
                fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Future<bool> checkIfFollowing() async {
    print('checking if following user');
    User currentUser = await getDoesUserExists(currentOnlineUserEmail);
    viewingUser = await getDoesUserExists(widget.userProfileEmail);
    for (int i = 0; i < currentUser.following.length; i++) {
      if (currentUser.following[i] == viewingUser.userID) {
        print('Current user is following this user');
        checker = true;
        return true;
      }
    }
    print('Current user is not following this user');
    return false;
  }

  Future<bool> checkIfBlocked() async {
    print('checking blocked users');
    User currentUser = await getDoesUserExists(currentOnlineUserEmail);
    viewingUser = await getDoesUserExists(widget.userProfileEmail);
    for (int i = 0; i < currentUser.blockedUsers.length; i++) {
      if (currentUser.blockedUsers[i] == viewingUser.userID) {
        isBlocked = true;
        print('user is blocked');
        return true;
      }
    }
    print('user is not blocked');
    return false;
  }

  Future<bool> checkIfIsClient() async {
    print('checking client users');
    User currentUser = await getDoesUserExists(currentOnlineUserEmail);
    viewingUser = await getDoesUserExists(widget.userProfileEmail);
    for (int i = 0; i < currentUser.clients.length; i++) {
      if (currentUser.clients[i] == viewingUser.userID) {
        isClient = true;
        print('user is a client');
        return true;
      }
    }
    print('user is not a client');
    return false;
  }

  Future<bool> checkBlockandFollowing() async { //also check if is client
    print('Checking if blocked, following and client are true');
    // User currentUser = await getDoesUserExists(currentOnlineUserEmail);
    // viewingUser = await getDoesUserExists(widget.userProfileEmail);
    User currentUser = tempUser; //grabbed from initState()
    viewingUser = profilePageOwner;
    // print(currentUser.blockedUsers);
    for (int i = 0; i < currentUser.following.length; i++) {
      if (currentUser.following[i] == viewingUser.userID) {
        checker = true;
        print('Current user is following this user');
      }
    }
    bool tempBlock = false; //to keep atomicity
    for (int i = 0; i < currentUser.blockedUsers.length; i++) {
      if (currentUser.blockedUsers[i] == viewingUser.userID) {
        tempBlock = true;
        print('user is blocked');
      }
    }
    isBlocked = tempBlock;
    bool tempClient = false;
    for (int i=0; i<currentUser.clients.length; i++) {
      if (currentUser.clients[i] == viewingUser.userID) {
        tempClient = true;
        print('user is a client');
      }
    }
    isClient = tempClient;
    print('checkBlockandFollowing function finished');
    //prevent loading posts from blocked users
    if (isBlocked && checker) {
      return true;
    } else if (isBlocked) {
      checker = false;
      return true;
    } else if (checker) {
      isBlocked = false;
      return true;
    }
    isBlocked = false;
    checker = false;
    return false;
  }

  createButton() {
    bool ownProfile = currentOnlineUserEmail == widget.userProfileEmail;
    if (ownProfile) {
      return createButtonTitleAndFunction(
        title: 'Edit Profile',
        performFunction: editUserProfile,
        color: Colors.white,
        width: 280,
      );
    } else if (checker) {
      return createButtonTitleAndFunction(
        title: 'Unfollow',
        futureFunctionName: "unfollowUser",
        color: Colors.grey[400],
        width: 220,
      );
    } else {
      return createButtonTitleAndFunction(
        title: 'Follow',
        futureFunctionName: "followUser",
        color: Colors.white38,
        width: 220,
      );
    }
  }

  createBlockButton() {
    bool ownProfile = currentOnlineUserEmail == widget.userProfileEmail;
    if (ownProfile) {
      return Container();
    } else if (isBlocked) {
      return createButtonTitleAndFunction(
        title: 'Unblock',
        futureFunctionName: "unblockUser",
        color: Colors.red,
        width: 100,
      );
    } else {
      return createButtonTitleAndFunction(
        title: 'Block',
        futureFunctionName: "blockUser",
        color: Colors.white,
        width: 100,
      );
    }
  }

  createDMButton() {
    bool ownProfile = currentOnlineUserEmail == widget.userProfileEmail;
    if (ownProfile) {
      return Container();
    } else {
      return createButtonTitleAndFunction(
        title: 'DM',
        performFunction: startConversation,
        color: Colors.white,
        width: 150,
      );
    }
  }

  startConversation() {
    // TODO
    // Navigator.pushReplacementNamed(context, '/editProfile'); // something like that
  }

  createClientButton() {
    bool ownProfile = currentOnlineUserEmail == widget.userProfileEmail;
    if (ownProfile || currentUser.brand==false) {
      return Container();
    } else if (isClient) {
      return createButtonTitleAndFunction(
        title: "Remove Client", 
        futureFunctionName: "removeClient",
        color: Colors.grey[400],
        width: 70,
      );
    } else {
      return createButtonTitleAndFunction(
        title: 'Make Client',
        futureFunctionName: 'makeClient',
        color: Colors.white,
        width: 70,
      );
    }
  }

Future<void> showBlockConfirmDialog() async {
 return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
     return AlertDialog(
        title: Text('Confirm Block'),
        content: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                    Text('Are you sure you want to block this user?'),
                ],
            ),
        ),
        actions: <Widget>[
            TextButton(

                child: Text('Confirm'),
                style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                    Navigator.of(context).pop();
                    FutureBuilder(
                        future: blockUser(currentUser.userID, viewingUser.userID),
                        builder: (context, snapshot) {}
                    );
                    Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                              ProfilePage(viewingUser.email),
                        transitionDuration: Duration(seconds: 0),
                    ));
                  },
            ),
            TextButton(
            style: TextButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 20),
                                    ),
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
            ),
        ],
     );
    },
 );
}

  Widget createButtonTitleAndFunction({
    String title,
    Function performFunction,
    String futureFunctionName,
    Color color,
    double width,
  }) {
    if (futureFunctionName == "followUser") {
      return Container(
        padding: EdgeInsets.only(top: 3.0),
        child: GestureDetector(
          onTap: () {
            if (isBlocked) {
              final snackBar = SnackBar(
                  content: Text(
                      'You must unblock this user first before following!'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }
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
            width: width,
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
        child: GestureDetector(
          onTap: () {
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
            width: width,
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
    } else if (futureFunctionName == "blockUser") {
      return Container(
        padding: EdgeInsets.only(top: 3.0),
        child: FlatButton(
          onPressed: () {
            showBlockConfirmDialog();
          },
          key: ValueKey(title),
          child: Container(
            width: width,
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
    } else if (futureFunctionName == "unblockUser") {
      return Container(
        padding: EdgeInsets.only(top: 3.0),
        child: GestureDetector(
          onTap: () {
            FutureBuilder(
                future: unblockUser(currentUser.userID, viewingUser.userID),
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
            width: width,
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
    } else if (futureFunctionName == "makeClient") {
      return Container(
        padding: EdgeInsets.only(top: 3.0),
        child: GestureDetector(
          onTap: () {
            FutureBuilder(
                future: makeClient(currentUser.userID, viewingUser.userID),
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
            width: width,
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
    } else if (futureFunctionName == "removeClient") {
      return Container(
        padding: EdgeInsets.only(top: 3.0),
        child: GestureDetector(
          onTap: () {
            FutureBuilder(
                future: removeClient(currentUser.userID, viewingUser.userID),
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
            width: width,
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
    
    else {
      return Container(
        padding: EdgeInsets.only(top: 3.0),
        child: GestureDetector(
          onTap: performFunction,
          key: ValueKey(title),
          child: Container(
            width: width,
            height: 35.0,
            child: Text(
              title,
              style:
                  TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black54, width: 2.0),
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

  //prompts to the default mailing app to email only individual.
  launchMailtoSingle() async {
    var url = "www.google.com";
    if (Platform.isAndroid) { //Play Store url
      url = "https://play.google.com/store/apps/details?id=com.fashionxt.choosenxt&hl=en_US&gl=US";
    } else if (Platform.isIOS) { //Apple Store url
      url = "https://www.apple.com/store";
    }
    //String greeting = "Hi " + '${widget.wouldBuyNameList[index - 1]}' + ",\n\n";
    final mailtoLink = Mailto(
      to: [],
      cc: [],
      subject: 'Invitation to Join ChooseNXT',
      body: "Click here to download: " + url,
    );
    await launch('$mailtoLink');
  }

  @override
  Widget build(BuildContext context) {
    BottomNav bottomBar = BottomNav(context);
    bottomBar.currentIndex = 2;
    bottomBar.currEmail = currentUser.email;
    bottomBar.brand = currentUser.brand;

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Image.asset(
          './assets/logos/ChooseNXT wide logo WBG.png',
          width: 200,
        ),
        centerTitle: true,
        key: ValueKey("homepage"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            // color: Colors.white,
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => SearchPage())),
          ),
          IconButton(
            icon: Icon(Icons.person_add_alt_rounded),
            color: Colors.black,
            onPressed: launchMailtoSingle,
          ),
        ],
      ),
      body: !feedLoading
          ? Center(
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
                              return createProfileTop();
                            } else {
                              // The height on this will need to be edited to match whatever height is set for the picture
                              if (profilePageOwner.userID ==
                                  currentUser.userID) {
                                return Container(
                                    constraints: BoxConstraints(
                                      minHeight: 50,
                                      minWidth: double.infinity,
                                    ),
                                    child: OwnFeedCard(postIDs[index - 1]));
                              } else {
                                return Container(
                                    constraints: BoxConstraints(
                                      minHeight: 50, //this is the space between the posts
                                      minWidth: double.infinity,
                                    ),
                                    child: FeedCard(
                                        postIDs[index - 1], ratedPosts));
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
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int pageIndex) {
          bottomBar.switchPage(pageIndex, context);
        },
        items: bottomBar.getItems(),
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.black, //color was not asked to change but just in case
      ),
    );
  }
}
