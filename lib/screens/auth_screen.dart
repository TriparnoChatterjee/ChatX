import 'dart:async';
import 'dart:io';

import '../utils/providers/auth_choices.dart';
import '../screens/verification_screen.dart';
import '../screens/phone_sign_in_page.dart';
import './chat_screen.dart';
import '../utils/facebook_signin.dart';
import '../utils/google_sign_in.dart';
import '../widgets/auth/auth_form.dart';

import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late Timer _timer;
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  void _submitAuthForm(String email, String password, String username,
      File image, bool isLogin) async {
    UserCredential userCredential;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        //Log User In
        userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        print("Create New user");
        userCredential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VerifyScreen()),
        );
        userCredential.user!.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Theme.of(context).errorColor,
            elevation: 2,
            padding: const EdgeInsets.all(10),
            content: const Text(
                'Verify Your Email.!! A Confirmation link has been sent to your given email id ')));
        _timer = Timer.periodic(
          const Duration(seconds: 10),
          (timer) async {
            final ref = FirebaseStorage.instance
                .ref()
                .child('user_image')
                .child('${userCredential.user!.uid}.jpg');
            //Storing files
            await ref.putFile(image);

            //Getting image Download link
            final url = await ref.getDownloadURL();
            FirebaseAuth.instance.currentUser!.reload();
            var user = FirebaseAuth.instance.currentUser;
            if (user!.emailVerified) {
              timer.cancel();
              await userCredential.user!.reload();
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .set({
                'username': username,
                'email': email,
                'image_url': url,
                //changes
                // "image_url": "https://i.imgur.com/yfCr8yz.png",
              });
              FirebaseAuth.instance.currentUser!.reload();
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => const ChatScreen()));
            } else {
              print("Verify!");
            }
          },
        );
      }
    } on FirebaseAuthException {
      var message = "An Error Occurred ! Check Your Credentials";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          action: SnackBarAction(
            textColor: Colors.white,
            label: 'CLOSE',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
          elevation: 10.0,
          backgroundColor: Colors.red.shade600,
          content: Text(message),
        ),
      );
      // setState(() {
      //   _isLoading = false;
      // });
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authChoices = Provider.of<AuthChoices>(context, listen: false);

    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              return const ChatScreen();
            }
            return SingleChildScrollView(
              child: SizedBox(
                //   height: MediaQuery.of(context).size.height * 0.99,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * 0.302,
                      width: double.infinity,
                      image: const AssetImage('images/convo.png'),
                    ),
                    AuthForm(_submitAuthForm, _isLoading),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            authChoices.toggleAuthChoices(
                                emailAuth: false,
                                facebookAuth: false,
                                goggleAuth: true);
                            Provider.of<GoogleAuthHelper>(context,
                                    listen: false)
                                .signInWithGoogle();
                            // final user = FirebaseAuth.instance.currentUser;
                            // _submitAuthForm(user!.email!, user.uid, username, image, isLogin)
                          },
                          child: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            backgroundImage:
                                const AssetImage('images/google_logo.png'),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            authChoices.toggleAuthChoices(
                                emailAuth: false,
                                facebookAuth: true,
                                goggleAuth: false);
                            Provider.of<FacebookAuthHelper>(context,
                                    listen: false)
                                .signInWithFacebook();
                            // final user = FirebaseAuth.instance.currentUser;
                            // _submitAuthForm(user!.email!, user.uid, username, image, isLogin)
                          },
                          child: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            backgroundImage: const NetworkImage(
                                'https://kernel.sr/wp-content/uploads/2020/06/facebook-scalable-graphics-icon-facebook-logo-facebook-logo-png-clip-art.png'),
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(
                    //   height: 30,
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: ElevatedButton.icon(
                          onPressed: () {
                            authChoices.toggleAuthChoices(
                                emailAuth: false,
                                facebookAuth: false,
                                goggleAuth: false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PhoneVerificationScreen()),
                            );
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Sign in with Phone Number')),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
