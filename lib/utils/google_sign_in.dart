import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthHelper with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          "email": userCredential.user!.email,
          "username": userCredential.user!.displayName,
          "image_url": userCredential.user!.photoURL,
        });
      }
      // FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userCredential.user!.uid)
      //     .set({
      //   "email": userCredential.user!.email,
      //   "username": userCredential.user!.displayName,
      //   "image_url": userCredential.user!.photoURL,
      //   "joining_date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      // });

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      return null;
    }
  }

  Future<void> signOutFromGoogle() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
