import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:woolala_app/screens/profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:woolala_app/widgets/bottom_nav.dart';
import 'package:woolala_app/main.dart';

//Database call for Following people
Future<http.Response> follow(String currentAccountID, String otherAccountID) {
  return http.post(
    Uri.parse(domain + '/follow/' + currentAccountID + '/' + otherAccountID),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({}),
  );
}

//Database call for Unfollowing people
Future<http.Response> unfollow(String currentAccountID, String otherAccountID) {
  return http.post(
    Uri.parse(domain + '/unfollow/' + currentAccountID + '/' + otherAccountID),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({}),
  );
}

//Database call for blocking people
Future<http.Response> blockUser(
    String currentAccountID, String otherAccountID) async {
  await unfollow(currentAccountID, otherAccountID);
  return http.post(
    Uri.parse(domain + '/blockUser/' + currentAccountID + '/' + otherAccountID),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({}),
  );
}

//Database call for unblocking people
Future<http.Response> unblockUser(
    String currentAccountID, String otherAccountID) {
  return http.post(
    Uri.parse(
        domain + '/unblockUser/' + currentAccountID + '/' + otherAccountID),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({}),
  );
}

//Create Stateful Widget
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  List results = []; // names we get from API
  List filteredResults = []; // names filtered by search text
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Search');

  //Declare a Future List to call the getAllUsers function once
  Future<List> _future;

  //Asynchronously gets all users from the database
  Future<List> getAllUsers() async {
    http.Response res = await http.get(Uri.parse(domain + "/getAllUsers"));
    if (res.body.isNotEmpty) {
      results = jsonDecode(res.body.toString());
      filteredResults = results;
    }
    setState(() {});
    return results;
  }

  //When the Search Icon has been pressed, change the app bar to a TextField and change focus
  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          onChanged: (text) {
            filteredResults = results;
          },
          autofocus: true,
          // cursorColor: Colors.white,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: 'Search...'),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Search');
        filteredResults = results;
        _filter.clear();
      }
    });
  }

  //Listener for the changes in the filter
  @override
  _SearchPageState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredResults = results;
        });
      } else if (_filter.text.length > 0) {
        setState(() {
          _searchText = _filter.text;
        });
      } //else{
      //setState(() {
      //_searchText = _filter.text;
      //});
      //}
    });
  }

  //Build the List using FutureBuilder
  Widget _buildList() {
    //filter the list
    if ((_searchText.length > 0)) {
      List tempList = [];
      for (int i = 0; i < filteredResults.length; i++) {
        if (filteredResults[i]['profileName']
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredResults[i]);
        }
      }
      filteredResults = tempList;
    }
    //Build the List
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            key: ValueKey("ListView"),
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: results == null ? 0 : filteredResults.length,
            itemBuilder: (BuildContext context, int index) {
              return new ListTile(
                leading: CircleAvatar(
                  child: filteredResults[index]['profileName'] != ""
                      ? Text(filteredResults[index]['profileName'][0])
                      : Text(" "),
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                title: Text(filteredResults[index]['profileName']),
                subtitle: Text(filteredResults[index]['userName']),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ProfilePage(filteredResults[index]['email']))),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("No Results"));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    BottomNav bottomBar = BottomNav(context);
    bottomBar.currentIndex = 10;
    bottomBar.brand = false; //hardcoded since user info not present

    return Scaffold(
      appBar: AppBar(
          leading: BackButton(
            // color: Colors.white,
            onPressed: () => (Navigator.pop(context)),
          ),
          title: _appBarTitle,
          actions: <Widget>[
            IconButton(
              icon: _searchIcon,
              key: ValueKey("Search Icon"),
              onPressed: () {
                _searchPressed();
              },
            )
          ]),
      body: ListView(
          //padding: const EdgeInsets.all(8),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            _buildList(),
          ]),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          bottomBar.switchPage(index, context);
        },
        items: bottomBar.getItems(),
        backgroundColor: Colors.white,
      ),
    );
  }

  //Runs when the page first loads
  @override
  void initState() {
    super.initState();
    _future = getAllUsers();
    //_buildList();
    //Make the search pressed upon load
    _searchPressed();
  }
}
