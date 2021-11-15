import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookAuthHelper with ChangeNotifier {
  late Timer _timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FacebookAuth _fbAuth = FacebookAuth.instance;
  late UserCredential userCredential;
  static late UserCredential fbUser;

  Future<void> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await _fbAuth.login();
    final userData = await _fbAuth.getUserData();

    // Create a credential from the access token
    final facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    userCredential = await _auth.signInWithCredential(facebookAuthCredential);
    FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      "email": userData['email'],
      "username": userData['name'],
      "image_url": userData['picture']['data']['url'],
    });
    // userCredential.user!.sendEmailVerification();
    // fbUser = userCredential;
    // _timer = Timer.periodic(
    //   Duration(seconds: 10),
    //   (timer) async {
    //     // FirebaseAuth.instance.currentUser!..reload();
    //     var user = FirebaseAuth.instance.currentUser;
    //     if (user!.emailVerified) {
    //       timer.cancel();
    //       await userCredential.user!.reload();
    //       await FirebaseFirestore.instance
    //           .collection('users')
    //           .doc(userCredential.user!.uid)
    //           .set({
    //         "email": user.email,
    //         "username": user.displayName,
    //       });
    //       FirebaseAuth.instance.currentUser!.reload();
    //     } else {
    //       print("Verify!");
    //     }
    //   },
    // );

    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userCredential.user!.uid)
    //     .set({
    //   "email": userCredential.user!.email,
    //   "username": userCredential.user!.displayName,
    // });
    // FirebaseAuth.instance.userChanges();
    notifyListeners();
  }

  Future<void> signOutWithFacebook() async {
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }
}
