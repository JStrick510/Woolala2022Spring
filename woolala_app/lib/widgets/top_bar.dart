//
//
// import 'package:flutter/material.dart';
// import 'package:woolala_app/screens/search_screen.dart';
// import 'package:woolala_app/screens/homepage_screen.dart' as home;
//
// class AppBar extends StatelessWidget {
//   @override Widget build(BuildContext context) {
//     return AppBar(
//       title: Text(
//         'WooLaLa',
//         style: TextStyle(fontSize: 25),
//         textAlign: TextAlign.center,
//       ),
//       key: ValueKey("homepage"),
//       actions: <Widget>[
//         IconButton(
//           icon: Icon(Icons.search),
//           key: ValueKey("Search"),
//           color: Colors.white,
//           onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage())),
//         ),
//         IconButton(
//           icon: Icon(Icons.clear),
//           onPressed: () => startSignOut(context),
//         )
//       ],
//     );
//   }
// }