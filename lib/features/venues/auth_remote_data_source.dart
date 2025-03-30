import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDatasource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDatasource(this._firebaseAuth);

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      log("Sign in with google catch error: " + e.toString());
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}