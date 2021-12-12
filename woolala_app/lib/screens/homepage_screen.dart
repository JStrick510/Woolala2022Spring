import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:woolala_app/screens/profile_screen.dart';
import 'package:woolala_app/screens/search_screen.dart';
import 'package:woolala_app/widgets/bottom_nav.dart';
import 'package:woolala_app/widgets/card.dart';
import 'package:woolala_app/main.dart';
import 'dart:io';

// Star widget on the home page
Widget starSlider(String postID, num, rated) => RatingBar(
      initialRating: num,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      ignoreGestures: rated,
      itemCount: 5,
      unratedColor: rated ? Colors.grey[400] : Colors.grey[400],
      itemSize: 30,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: rated ? Colors.black : Colors.grey[800],
      ),
      onRatingUpdate: (rating) {
        print(rating);
        //Changing rating here
        ratePost(rating, postID);
        //getFeed("cmpoaW5ja0BnbWFpbC5jb20=", "2020-10-28");
      },
    );

// Will be used anytime the post is rated
Future<http.Response> ratePost(double rating, String id) {
  return http.post(
    Uri.parse(domain +
        '/ratePost/' +
        id.toString() +
        '/' +
        rating.toString() +
        '/' +
        currentUser.userID),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({}),
  );
}

// Will be used to make the post for the first time.
Future<http.Response> createPost(String postID, String image, String date,
    String caption, String userID, String userName) {
  return http.post(
    Uri.parse(domain + '/insertPost'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'postID': postID,
      'userID': userID,
      'userName': userName,
      'image': image,
      'date': date,
      'caption': caption,
      'cumulativeRating': 0.0,
      'numRatings': 0,
      'wouldBuy': []
    }),
  );
}

// Will add a post to the reported section of the DB
Future<http.Response> reportPost(
    String postID, String reportingUserID, String date, String postUserID) {
  return http.post(
    Uri.parse(domain + '/reportPost'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'postID': postID,
      'reportingUserID': reportingUserID,
      'date': date,
      'postUserID': postUserID
    }),
  );
}

Future<http.Response> getReports(String postID, String postUserID) async {
  http.Response res =
      await http.get(Uri.parse(domain + '/getReports/' + postID));
  Map ret = jsonDecode(res.body.toString());
  if (ret["numReports"] >= 3) {
    print("About to http to delete");
    return http.post(
      Uri.parse(domain + '/deleteOnePost/' + postID + '/' + postUserID),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({}),
    );
  } else {
    return http.Response("NoDeletion", 400);
  }
}

// Will be used to get info about the post
Future<List> getPost(String id) async {
  http.Response res = await http.get(Uri.parse(domain + '/getPostInfo/' + id));
  Map info = jsonDecode(res.body.toString());
  final decodedBytes = base64Decode(info["image"]);
  var avg;
  if (info["numRatings"] > 0) {
    avg = info["cumulativeRating"] / info["numRatings"];
  } else {
    avg = 0.0;
  }
  var ret = [
    Image.memory(decodedBytes),
    info["caption"],
    info["userID"],
    info["date"],
    avg,
    info["numRatings"],
    ImageSlideshow(
      width: double.infinity,
      children: [
        Image.memory(decodedBytes),
        Image.memory(decodedBytes),
        Image.memory(decodedBytes)
      ]
    )
  ];
  return ret;
}

// Returns a list of all the posts the provided user has rated
Future<List> getRatedPosts(String userID) async {
  // print('Getting rated posts');
  http.Response res =
      await http.get(Uri.parse(domain + '/getRatedPosts/' + userID));
  if (res.body.isNotEmpty) {
    return jsonDecode(res.body.toString());
  }
  return [];
}

// Will retrieve the entire user document from the DB with the provided user ID
Future<User> getUserFromDB(String userID) async {
  http.Response res = await http.get(Uri.parse(domain + '/getUser/' + userID));
  Map userMap = jsonDecode(res.body.toString());
  return User.fromJSON(userMap);
}

// Will return a list of posts from all the users the provided user is following
Future<List> getFeed(String userID) async {
  http.Response res = await http.get(Uri.parse(domain + '/getFeed/' + userID));
  return jsonDecode(res.body.toString())["postIDs"];
}

class HomepageScreen extends StatefulWidget {
  final bool signedInWithGoogle;
  final bool signedInWithFacebook;
  final bool signedInWithApple;

  HomepageScreen(this.signedInWithGoogle, this.signedInWithFacebook,
      this.signedInWithApple);

  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  //ScreenshotController screenshotController = ScreenshotController();

  List postIDs = [];
  var ratedPosts = [];
  File file;
  int numToShow;
  var feedLoading = true;

  // Change this to load more posts per refresh
  int postsPerReload = 4;

  // Puts posts sorted order by date
  void sortPosts(list) {
    list.removeWhere((item) => item == "");
    list.sort((a, b) =>
        int.parse(b.substring(b.indexOf(':::') + 3)) -
        int.parse(a.substring(a.indexOf(':::') + 3)));
  }

  // is called when the user pulls up on home screen
  void _onRefresh() async {
    postIDs = await getFeed(currentUser.userID);
    ratedPosts = await getRatedPosts(currentUser.userID);
    sortPosts(postIDs);
    print(postIDs);
    print(ratedPosts);
    // if failed,use refreshFailed()
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  // is called when the user pulls down on the home screen
  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    if (numToShow + postsPerReload > postIDs.length) {
      numToShow = postIDs.length;
    } else {
      numToShow += postsPerReload;
    }

    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  initState() {
    super.initState();
    if (currentUser != null) {
      feedLoading = true;
      getFeed(currentUser.userID).then((list) {
        postIDs = list;
        if (postIDs.length < postsPerReload)
          numToShow = postIDs.length;
        else
          numToShow = postsPerReload;
        sortPosts(postIDs);
        print(postIDs);
        setState(() {
          feedLoading = false;
        });
      });
    }
    getRatedPosts(currentUser.userID).then((list) {
      ratedPosts = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(Navigator.of(context).toString());
    BottomNav bottomBar = BottomNav(context);
    bottomBar.currentIndex = 1;
    bottomBar.currEmail = currentUser.email;

    return Scaffold(
      appBar: AppBar(
        // title: Text('ChooseNXT', style: TextStyle(fontSize: 25)),
        title: Image.asset(
          './assets/logos/ChooseNXT wide logo WBG.png',
          width: 200,
        ),
        centerTitle: true,
        key: ValueKey("homepage"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            key: ValueKey("Search"),
            // color: Colors.white,
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => SearchPage())),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => startSignOut(context),
          )
        ],
      ),
      body: !feedLoading
          ? Center(
              child: postIDs.length > 0
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
                            // The height on this will need to be edited to match whatever height is set for the picture
                            // return SizedBox(
                            //   width: double.infinity,
                            //   height: 550,
                            //   child: FeedCard(postIDs[index], ratedPosts),
                            // );
                            return Container(
                              constraints: BoxConstraints(
                                minHeight: 570,
                                minWidth: double.infinity,
                              ),
                              child: FeedCard(postIDs[index], ratedPosts),
                            );
                          }),
                    )
                  : Padding(
                      padding: EdgeInsets.all(70.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Follow People to see their posts on your feed!",
                            style: TextStyle(
                                fontSize: 30,
                                color: Colors.grey,
                                fontFamily: 'Lucida'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ),
                              child: Container(
                                constraints: BoxConstraints(
                                  minWidth: 150,
                                  maxWidth: 300,
                                  minHeight: 50,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Icon(Icons.search),
                                    Text('Search people here'),
                                  ],
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return SearchPage();
                                }));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            )
          : Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Feed Loading...',
                    style: TextStyle(
                      fontSize: 36,
                    ),
                  ),
                  Container(width: 50),
                  CircularProgressIndicator(),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          bottomBar.switchPage(index, context);
        },
        items: bottomBar.bottom_items,
        backgroundColor: Colors.white,
      ),
    );
  }

  void startSignOut(BuildContext context) {
    print("Sign Out");
    if (widget.signedInWithGoogle) {
      googleLogoutUser();
      Navigator.pushReplacementNamed(context, '/');
    } else if (widget.signedInWithFacebook) {
      facebookLogoutUser();
      Navigator.pushReplacementNamed(context, '/');
    } else {
      googleLogoutUser();
      facebookLogoutUser();
      Navigator.pushReplacementNamed(context, '/');
    }
  }
}
