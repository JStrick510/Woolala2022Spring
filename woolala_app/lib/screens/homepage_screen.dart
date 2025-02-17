//import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:audioplayers/audioplayers.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
//import 'package:woolala_app/screens/profile_screen.dart';
import 'package:woolala_app/screens/search_screen.dart';
import 'package:woolala_app/screens/conversation_list_screen.dart';
import 'package:woolala_app/widgets/bottom_nav.dart';
import 'package:woolala_app/widgets/card.dart';
import 'package:woolala_app/main.dart';
import 'dart:io';
import "dart:math";
import "dart:collection";
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

// Star widget on the home page
Widget starSlider(String postID, num, rated) => RatingBar(
  initialRating: num,
  minRating: 0,
  direction: Axis.horizontal,
  allowHalfRating: true,
  ignoreGestures: rated,
  itemCount: 5,
  unratedColor: rated ? Colors.grey[400] : Colors.grey[400],
  itemSize: 25, //30
  itemPadding: EdgeInsets.symmetric(horizontal: 2.0), //4
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

////////////////////////////////////////////////////////////////////////////////
class SliderThumbImage extends SliderComponentShape {
  final ui.Image image;

  SliderThumbImage(this.image);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(0, 0);
  }

  @override
  void paint( PaintingContext context,
      Offset center,
      {Animation<double> activationAnimation,
        Animation<double> enableAnimation,
        bool isDiscrete,
        TextPainter labelPainter,
        RenderBox parentBox,
        SliderThemeData sliderTheme,
        TextDirection textDirection,
        double value,
        double textScaleFactor,
        Size sizeWithOverflow}
      ) {
    final canvas = context.canvas;
    final imageWidth = image?.width ?? 34;
    final imageHeight = image?.height ?? 34;

    Offset imageOffset = Offset(
      center.dx - (imageWidth / 2),
      center.dy - (imageHeight / 2),
    );

    Paint paint = Paint()..filterQuality = FilterQuality.high;

    if (image != null) {
      canvas.drawImage(image, imageOffset, paint);
    }
  }
}

////////////////////////end_farnaz//////////////////////////////////////////////


// Will be used to make the post for the first time.
Future<http.Response> createPost(String postID, String image1, String image2,
    String image3, String image4, String image5, String date,
    String caption, String userID, String userName, String Category, String minprice,String maxprice, String currency) {
  return http.post(
    Uri.parse(domain + '/insertPost'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'postID': postID,
      'userID': userID,
      'userName': userName,
      'image1': image1,
      'image2': image2,
      'image3': image3,
      'image4': image4,
      'image5': image5,
      'date': date,
      'caption': caption,
      'cumulativeRating': 0.0,
      'numRatings': 0,
      'Category': Category,
      'minprice': minprice,
      'maxprice': maxprice,
      'wouldBuy': [],
      'currency': currency,
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

  List<Image> display = []; //store the image IDs to be displayed as buttons

  if(info["image1"] != null){ //should never be null since posts have to have one image to post but handles exceptions
    display.add(Image.memory(base64Decode(info["image1"])));
  }
  if(info["image2"] != null){
    display.add(Image.memory(base64Decode(info["image2"])));
  }
  if(info["image3"] != null){
    display.add(Image.memory(base64Decode(info["image3"])));
  }
  if(info["image4"] != null){
    display.add(Image.memory(base64Decode(info["image4"])));
  }
  if(info["image5"] != null){
    display.add(Image.memory(base64Decode(info["image5"])));
  }

  var avg;
  if (info["numRatings"] > 0) {
    avg = info["cumulativeRating"] / info["numRatings"];
  } else {
    avg = 0.0;
  }
  var ret = [
    info["caption"],
    info["userID"],
    info["date"],
    avg,
    info["numRatings"],
    display,
    info["Category"], //category in which a post belongs to
    info["minprice"],
    info["maxprice"],
    info["currency"]
  ];
  return ret; //this ends up getting sent to card and profile_card as postInfo
}

// Returns a list of all the posts the provided user has rated
Future<List> getRatedPosts(String userID) async {
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
  if (res.body.isNotEmpty) {
    Map userMap = jsonDecode(res.body.toString());
    return User.fromJSON(userMap);
  } else
    return null;
}

// Will return a list of posts from all the users the provided user is following
Future<List> getFeed(String userID) async {
  http.Response res = await http.get(Uri.parse(domain + '/getFeed/' + userID));
  return jsonDecode(res.body.toString())["postIDs"];
}

//Will return a list of all the users:
Future<List> getUsrs() async {
  List results = new List();
  List filteredResults = new List();
  http.Response res = await http.get(Uri.parse(domain + "/getAllUsers"));
  if (res.body.isNotEmpty) {
    results = jsonDecode(res.body.toString());
    filteredResults = results;
  }
  return filteredResults;
}

//Will return a list of all the posts of selected user:
Future<List> getAllPosts(String userID) async {
  http.Response res = await http
      .get(Uri.parse(domain + '/getOwnFeed/' + userID));
  return jsonDecode(res.body.toString());
}
////////////////////////////////END///////////////////////////////////////////

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

  //Initialize global variables:
  List postIDs = [];
  var ratedPosts = [];
  File file;
  int numToShow; //number of posts to show
  var feedLoading = true; //indicates if all posts of the feed is loaded

  int count = 0; //count
  String dropdownvalue = 'None'; //category that filter will use

  //list of categories that will be filtered:
  var itemsFilter = [
    "Apparel",
    "Shoes",
    "Accessories",
    "Crafts",
    "Designs",
    "Home",
    "Others",
    "None",
  ];

  List <String> toRemove = []; //list to filter out posts
  var sorted = false; //indicates if feed is sorted
  List prePostIDs = []; //pre-loaded posts
  List users = [];//users in the app
  final Map<String, double> popular = HashMap();//hash map to sort popular user
  bool sortConfirm = false;
  bool hasFeed = false; //indicates if user has posts or follows users with posts

  final Map<String, double> sortIDposts = HashMap(); //hash map  to sort most popular following

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
    print("refresh");
    sorted = false;
    List temp = [];
    temp = await getFeed(currentUser.userID);
    var reg = [];
    if (temp.length > 0){
      for (int i = 0; i < temp.length; i++){
        if (!postIDs.contains(temp[i]) && temp[i] != null){
          reg.add(temp[i]);
        }
      }
      sortPosts(reg);
      postIDs = reg  + postIDs;
    }
    ratedPosts = await getRatedPosts(currentUser.userID);
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

  //function that filters out posts:
  void filterOut() async {
    await Future.delayed(Duration(milliseconds: 1000));
    var rem = List.unmodifiable(toRemove);
    if (rem.length > 0){
      for (int j = 0; j < rem.length; j++){
        if (postIDs.contains(rem[j])){
          postIDs.remove(rem[j]);

          //update number of posts to load on feed:
          if (postIDs.length < postsPerReload)
            numToShow = postIDs.length;
          else
            numToShow = postsPerReload;
        }
      }
    }

    count += 1;
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  //function that populates a list (toRemove) with posts that do not fit in the category selected:
  void _filterPosts(List postIDs, String category) async {
    print("Category:");
    print(category);

    if (toRemove.length > 0){
      postIDs = toRemove;
      toRemove = [];
    }

    if (category != "None"){
      for (int i = 0; i < postIDs.length; i++){
        getPost(postIDs[i]).then((info) {
          if (info[6] != category){
            toRemove.add(postIDs[i]);
          }
        });
      }
    }
  }

  //function that sorts out posts by popularity of users followed:
  void _sortPosts(Map<String, double> sortPosts) async {
    await Future.delayed(Duration(milliseconds: 1000));

    if (sortPosts.length >= postIDs.length){

      print("sorting posts...");

      //Sort hash map by key (score):
      var sortKeyPosts = sortPosts.keys.toList(growable:false)
        ..sort((k1, k2) => sortPosts[k2].compareTo(sortPosts[k1]));
      LinkedHashMap sortedMapPosts = new LinkedHashMap
          .fromIterable(sortKeyPosts, key: (k) => k, value: (k) => sortPosts[k]);

      var sortedPosts = sortedMapPosts.keys.toList(growable:false);

      //update posts on feed:
      postIDs = [];
      postIDs = List.from(sortedPosts);
      prePostIDs = List.from(sortedPosts);
      sortConfirm = true;

    }

    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  //function that sorts out posts by popularity of users if user is not following or has no posts:
  void _sort(Map<String, double> popular, List users) async {
    await Future.delayed(Duration(milliseconds: 9000));
    if (popular.length >= users.length){
      print("sorting users by popularity...");

      //Sort hash map by key (score):
      var sortedKeys = popular.keys.toList(growable:false)
        ..sort((k1, k2) => popular[k2].compareTo(popular[k1]));
      LinkedHashMap sortedMap = new LinkedHashMap
          .fromIterable(sortedKeys, key: (k) => k, value: (k) => popular[k]);

      var sortedIDs = sortedMap.keys.toList(growable:false);

      //populate empty feed:
      if (postIDs.length == 0){
        hasFeed = false;

        for (int i = 0; i < sortedIDs.length; i++){
          getAllPosts(sortedIDs[i]).then((list) {

            if(i == 0){
              postIDs = [];
            }

            sortPosts(list);
            postIDs+=list;

            //update number of posts to load on feed:
            if (postIDs.length < postsPerReload)
              numToShow = postIDs.length;
            else
              numToShow = postsPerReload;
          });
        }
      }

    }

    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  //initialize feed:
  @override
  initState() {
    super.initState();
    if (currentUser != null && postIDs.length == 0) {

      //initialize sorting and loading of posts:
      sorted = false;
      feedLoading = true;

      //see if user has posts or following users with posts:
      getFeed(currentUser.userID).then((list) {
        postIDs = List.from(list);
        prePostIDs = List.from(list);

        //if user has posts or following users with posts, sort posts by popularity:
        if (postIDs.length > 0){
          getUsrs().then((list1){
            User rateUser;
            users += list1; //all users
            for (int j = 0; j < users.length; j++){

              getUserFromDB(users[j]['userID']).then((usr){
                rateUser = usr;

                //Find the popularity of user:
                rateUser.getAvgScore().then((score){
                  popular.addAll({users[j]['userID']: score});
                  getAllPosts(users[j]['userID']).then((list4) {
                    for (int y = 0; y < list4.length; y++){
                      if (postIDs.contains(list4[y])){
                        sortIDposts.addAll({list4[y]: score});
                      }
                    }
                  });
                });

              });

            }
          });
          hasFeed = true;

          //update number of posts to load on feed:
          if (postIDs.length < postsPerReload)
            numToShow = postIDs.length;
          else
            numToShow = postsPerReload;
        }
        //if user has no posts nor following users with posts, find popularity of all users in app:
        else {
          hasFeed = false;
          getUsrs().then((list1){
            User rateUser;
            users += list1; //all users
            for (int j = 0; j < users.length; j++){

              getUserFromDB(users[j]['userID']).then((usr){
                rateUser = usr;

                //Find the popularity of user:
                rateUser.getAvgScore().then((score){
                  popular.addAll({users[j]['userID']: score});
                });

              });

            }
          });
        }

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
    bottomBar.brand = currentUser.brand;

    if (postIDs.length > 0){ //if feed is not empty, sort posts:

      //if user has no posts nor following, populate and sort by popularity and filter:
      if (!sorted){
        _sort(popular, users);
        _filterPosts(postIDs, dropdownvalue);
        sorted = true;
      }

      //if user has posts and/or following, sort these posts by popularity and filter:
      if (!sortConfirm && hasFeed){
        _sortPosts(sortIDposts);
        _filterPosts(postIDs, dropdownvalue);
      }
      else if (sortConfirm && hasFeed){ //if already sorted, load the posts to feed:
        feedLoading = false;
      }
      else if (!hasFeed){
        feedLoading = false;
      }

      //count 3 iterations to refresh feed when filter is added:
      if (count < 3){
        print("Filtering");
        filterOut();
      }

      //if filter is not applied, load old posts pre-filter:
      if ((toRemove.length == 0) && hasFeed){
        postIDs = List.from(prePostIDs);
      }

    }
    else{ //if feed is empty, populate it with posts in order of popularity:
      _sort(popular, users);
    }

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
            icon: Icon(Icons.message_outlined),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => ConversationListScreen())
            ),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => startSignOut(context),
          ),
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
              padding: EdgeInsets.fromLTRB(10, 1, 10, 0),
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
                    minHeight: 50, //this is the space between the posts
                    minWidth: double.infinity,
                  ),

                  //load filters and first post, then load the rest of the posts:
                  child: !(index > 0)
                      ?
                  Column(
                    children:[
                      SizedBox(height: 20.0),
                      Text("New Releases", style: TextStyle(fontSize: 22)),
                      //SizedBox(height: 10.0),
                      //Text("Filter Feed by Category:"),
                      SizedBox(height: 15.0),
                      Container(
                          height: 25,

                          //horizontal listview for scrollable filter icons:
                          child:ListView(
                            scrollDirection: Axis.horizontal,
                            children: itemsFilter.map((fil){
                              return Container(

                                  margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  alignment: Alignment.center,

                                  child: ElevatedButton.icon(
                                      onPressed: (){
                                        setState(() {

                                          //if filter is applied, indicate it and update filter:
                                          dropdownvalue = fil;
                                          count = 0;
                                          postIDs = List.from(prePostIDs);
                                          toRemove = [];
                                          _filterPosts(postIDs, dropdownvalue);
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        onPrimary: Colors.black,
                                      ),
                                      icon: Icon(Icons.add_circle_outline),
                                      label: Text(fil)
                                  )
                              );
                            }).toList(),
                          )
                      ),
                      FeedCard(postIDs[index], ratedPosts),//load in the first post
                    ],
                  ):
                  FeedCard(postIDs[index], ratedPosts), //load the rest of the posts
                );
              }),
        )
            : Padding( //if no posts are loaded, let user follow other users:
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
        items: bottomBar.getItems(),
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.black, //color was not asked to change but just in case
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
