//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:woolala_app/screens/EditProfileScreen.dart';
import 'package:woolala_app/screens/following_list_screen.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/screens/post_screen.dart';
import 'package:woolala_app/screens/profile_screen.dart';
import 'package:woolala_app/screens/search_screen.dart';
import 'package:woolala_app/screens/wouldbuy_list_screen.dart';
import 'package:woolala_app/screens/imageupload_screen.dart';


void main() {

  test(
      'create delete button', () {

    WidgetsFlutterBinding.ensureInitialized();

    //init
    EditProfilePage edit = new EditProfilePage();

    //do the test
    var state = edit.createState();
    Widget w = state.createDeleteButton();

    //expected result
    expect(w.runtimeType, RaisedButton);

  }
  );

  test('create profile name text from field', () {

    WidgetsFlutterBinding.ensureInitialized();

    //init
    EditProfilePage edit = new EditProfilePage();

    //do the test
    var state = edit.createState();
    Widget w = state.createProfileNameTextFormField();

    //expected result
    expect(w.runtimeType, Column);

  }
  );

  test('get profile name', () {

    WidgetsFlutterBinding.ensureInitialized();

    //init
    FollowingListScreen edit = new FollowingListScreen('msagor@tamu.edu');

    //do the test
    var state = edit.createState();
    List<dynamic> list = state.followingEmailList;

    //expected result
    expect(list.runtimeType,new List<dynamic>().runtimeType);

  }
  );

  test('google login screen', () {

    WidgetsFlutterBinding.ensureInitialized();

    //init
    LoginScreen edit = new LoginScreen();

    //do the test
    var state = edit.createState();
    state.googleLoginUser();

    //expected result
    expect(state.isSignedInWithGoogle,false);

  }
  );


  test('image_display', () {

    WidgetsFlutterBinding.ensureInitialized();

    //init
    ImageUploadScreen edit = new ImageUploadScreen();

    //do the test
    var state = edit.createState();
    Widget w = state.pickImages();

    //expected result
    //expect(state.isSignedInWithGoogle,false);

  }
  );



}