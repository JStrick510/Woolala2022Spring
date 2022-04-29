import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

enum SignInMethod { google, facebook, emailAndPassword }

class SignInProvider {
  SignInMethod signInMethod;

  // Google sign in members
  final googleSignIn = GoogleSignIn();
  // GoogleSignInAccount? _user;
  // GoogleSignInAccount? get user => _user;

  Future<GoogleSignInAccount> googleLogIn() async {
    // logout();
    signInMethod = SignInMethod.google;
    GoogleSignInAccount _user = null;
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;
      _user = googleUser;

      final googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e.toString());
    }
    // notifyListeners();
    return _user;
  }

  Future facebookLogIn() async {
    // logout();
    signInMethod = SignInMethod.facebook;
    String _accessToken;
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        _accessToken = result.accessToken?.token;
      } else {
        print(result.status);
        print(result.message);
      }

      if (_accessToken != null) {
        final AuthCredential credential =
            FacebookAuthProvider.credential(_accessToken);
        await FirebaseAuth.instance.signInWithCredential(credential);
        Map<String, dynamic> userdata =
            await FacebookAuth.instance.getUserData();
        return userdata;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future logout() async {
    if (signInMethod == SignInMethod.google) {
      await googleSignIn.disconnect();
    } else if (signInMethod == SignInMethod.facebook) {
      await FacebookAuth.instance.logOut();
    }
    FirebaseAuth.instance.signOut();
  }
}
