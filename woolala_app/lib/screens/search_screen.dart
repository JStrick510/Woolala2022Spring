import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

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

  void _getNames() async {
    mongo.Db db = new mongo.Db.pool([
      "mongodb://Developer_1:Developer_1@woolalacluster-shard-00-00.o4vv6.mongodb.net:27017/Feed?ssl=true&replicaSet=project-shard-0&authSource=admin&retryWrites=true&w=majority",
      "mongodb://Developer_1:Developer_1@woolalacluster-shard-00-01.o4vv6.mongodb.net:27017/Feed?ssl=true&replicaSet=project-shard-0&authSource=admin&retryWrites=true&w=majority",
      "mongodb://Developer_1:Developer_1@woolalacluster-shard-00-02.o4vv6.mongodb.net:27017/Feed?ssl=true&replicaSet=project-shard-0&authSource=admin&retryWrites=true&w=majority"
    ]);
    await db.open();
    var coll = db.collection('Users');
    List tempList = new List();
    tempList = await coll.find(mongo.where.sortBy('profileName')).toList();
    //print(tempList);
    db.close();

    setState(() {
      results = tempList;
      filteredResults = results;
    });
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
    return ListView.builder(
      key: ValueKey("ListView"),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: results == null ? 0 : filteredResults.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: Text(filteredResults[index]['profileName']),
          onTap: () => print(filteredResults[index]['profileName']),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: BackButton(
                color: Colors.white,
                onPressed: () => (Navigator.pushReplacementNamed(context, '/home'))
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
        )
    );

  }
  @override
  void initState() {
    super.initState();
    _getNames();
  }

}

