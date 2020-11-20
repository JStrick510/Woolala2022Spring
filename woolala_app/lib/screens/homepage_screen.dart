import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'dart:io' as Io;
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:collection';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'dart:io';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:woolala_app/screens/post_screen.dart';
import 'package:woolala_app/screens/profile_screen.dart';
import 'package:woolala_app/screens/search_screen.dart';
import 'package:woolala_app/widgets/bottom_nav.dart';
import 'package:woolala_app/widgets/card.dart';
import 'package:woolala_app/main.dart';
import 'package:social_share_plugin/social_share_plugin.dart';
import 'package:social_share/social_share.dart';

AudioPlayer advancedPlayer;

Widget starSlider(String postID, num) =>
    RatingBar(
      initialRating: num,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      unratedColor: Colors.black,
      itemSize: 30,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.blue,
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
    domain + '/ratePost/' + id.toString() + '/' + rating.toString(),
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
    domain + '/insertPost',
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
      'cumulativeRating': 0,
      'numRatings': 0
    }),
  );
}

// Will be used to get info about the post
Future<List> getPost(String id) async {
  http.Response res = await http.get(domain + '/getPostInfo/' + id);
  Map info = jsonDecode(res.body.toString());
  final decodedBytes = base64Decode(info["image"]);
  var ret = [
    Image.memory(decodedBytes),
    info["caption"],
    info["userID"],
    info["date"]
  ];
  return ret;

  //DO THIS TO GET IMAGE

  // FutureBuilder(
  //   future: getPost(POSTID),
  //   builder: (context, snapshot) {
  //     if (snapshot.hasData) {
  //       return snapshot.data;
  //     } else {
  //       return CircularProgressIndicator();
  //     }
  //   },
  // );
}

Future<User> getUserFromDB(String userID) async {
  http.Response res = await http.get(domain + '/getUser/' + userID);
  Map userMap = jsonDecode(res.body.toString());
  return User.fromJSON(userMap);
}

Future<List> getFeed(String userID) async {
  http.Response res = await http.get(domain + '/getFeed/' + userID);
  return jsonDecode(res.body.toString())["postIDs"];
}

//final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class HomepageScreen extends StatefulWidget {
  final bool signedInWithGoogle;

  HomepageScreen(this.signedInWithGoogle);

  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List postIDs = [];
  int numToShow;
  int postsPerReload = 2;

  void sortPosts(list) {
    list.removeWhere((item) => item == "");
    list.sort((a, b) =>
        int.parse(b.substring(b.indexOf(':::') + 3)) -
        int.parse(a.substring(a.indexOf(':::') + 3)));
  }

  void _onRefresh() async {
    postIDs = await getFeed(currentUser.userID);
    sortPosts(postIDs);
    print(postIDs);
    // if failed,use refreshFailed()
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

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
    if (currentUser != null)
      getFeed(currentUser.userID).then((list) {
        postIDs = list;
        if (postIDs.length < postsPerReload)
          numToShow = postIDs.length;
        else
          numToShow = postsPerReload;
        sortPosts(postIDs);
        print(postIDs);
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    print(Navigator.of(context).toString());
    BottomNav bottomBar = BottomNav(context);
    bottomBar.currentIndex = 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('WooLaLa', style: TextStyle(fontSize: 25)),
        centerTitle: true,
        key: ValueKey("homepage"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            key: ValueKey("Search"),
            color: Colors.white,
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => SearchPage())),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => startSignOut(context),
          )
        ],
      ),
      body: Center(
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
                return SizedBox(
                    width: double.infinity,
                    height: 620,
                    child: FeedCard(postIDs[index]));
              }),
        )
            : Padding(padding: EdgeInsets.all(70.0), child: Text("Follow People to see their posts on your feed!", style: TextStyle(fontSize: 30, color: Colors.grey, fontFamily: 'Lucida'))),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          bottomBar.switchPage(index, context);
        },
        items: bottomBar.bottom_items,
        backgroundColor: Colors.blue,
      ),
    );
  }

  void startSignOut(BuildContext context) {
    print("Sign Out");
    if (widget.signedInWithGoogle) {
      googleLogoutUser();
      Navigator.pushReplacementNamed(context, '/');
    } else {
      facebookLogoutUser();
      Navigator.pushReplacementNamed(context, '/');
    }
  }
}



