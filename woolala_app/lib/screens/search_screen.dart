import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:woolala_app/screens/profile_screen.dart';
import 'package:http/http.dart' as http;
import 'homepage_screen.dart';
import 'login_screen.dart';

Future<http.Response> follow(String currentAccountID, String otherAccountID) {
  return http.post(
    domain + '/follow/' + currentAccountID + '/' + otherAccountID,
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({}),
  );
}

Future<http.Response> unfollow(String currentAccountID, String otherAccountID) {
  return http.post(
    domain + '/unfollow/' + currentAccountID + '/' + otherAccountID,
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({}),
  );
}


class SearchPage extends StatefulWidget{
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  List results = new List(); // names we get from API
  List filteredResults = new List(); // names filtered by search text
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text( 'Search' );
  List userList;

  Future<List> getAllUsers() async{
     print("Getting all Users.");
     http.Response res = await http.get(domain + "/getAllUsers");
     if (res.body.isNotEmpty) {
       results = jsonDecode(res.body.toString());
       filteredResults = results;
     }
     setState((){});
     return results;
  }



  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: 'Search...'
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Search');
        filteredResults = results;
        _filter.clear();
      }
    });
  }
  @override
  _SearchPageState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredResults = results;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List tempList = new List();
      for (int i = 0; i < filteredResults.length; i++) {
        if (filteredResults[i]['profileName'].toLowerCase().contains(_searchText.toLowerCase())) {
          tempList.add(filteredResults[i]);
        }
      }
      filteredResults = tempList;
    }

    return FutureBuilder(
      future: getAllUsers(),
      builder: (context, snapshot){
        if(snapshot.hasData){
          return ListView.builder(
            key: ValueKey("ListView"),
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: results == null ? 0 : filteredResults.length,
            itemBuilder: (BuildContext context, int index) {
              return new ListTile(
                leading: CircleAvatar(
                  child: Text(filteredResults[index]['profileName'][0]),
                ),
                title: Text(filteredResults[index]['profileName']),
                subtitle: Text(filteredResults[index]['userName']),
                /*trailing: Wrap(
                  spacing: 12,
                  children: <Widget> [

                    new Container(
                      child: new IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {follow(currentUser.userID, filteredResults[index]['userID']);},
                      ),
                    ),
                  ],
                ),*/
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProfilePage(filteredResults[index]['email']))),
              );
            },
          );
        }

        else if(snapshot.hasError){
          return Center(child: Text("No Results"));
        }
        else{
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: BackButton(
                color: Colors.white,
                onPressed: () => ( Navigator.pop(context))
            ),
            title: _appBarTitle,
            actions: <Widget>[
              IconButton(
                icon: _searchIcon,
                key: ValueKey("Search Icon"),
                onPressed: (){_searchPressed();},
              )
            ]
        ),
        body: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              _buildList(),

            ]
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
  @override
  void initState() {
    super.initState();
    //_getNames();
    getAllUsers();
  }

  void switchPage(int index, BuildContext context) {
    switch(index) {
      case 0: {
        Navigator.pushReplacementNamed(context, '/home');}
      break;
      case 1: {
        Navigator.pushReplacementNamed(context, '/imgup');}
      break;
      case 2:
        {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProfilePage(currentUser.email)));
        }
        break;
    }
  }
}

