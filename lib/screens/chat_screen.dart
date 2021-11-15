import 'package:flutter/cupertino.dart';

import '../utils/facebook_signin.dart';
import '../utils/google_sign_in.dart';
import '../utils/providers/auth_choices.dart';
import '../screens/auth_screen.dart';
import '../widgets/chat/new_message.dart';
import '../widgets/chat/messages.dart';

import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;
    final authChoices = Provider.of<AuthChoices>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Chit Chat'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton(
                onChanged: (itemIdentifier) async {
                  if (itemIdentifier == 'logout') {
                    if (authChoices.isEmailVerification) {
                      await _auth.signOut();
                      Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                              builder: (builder) => const AuthScreen()));
                    } else if (authChoices.isGoogleVerification) {
                      Provider.of<GoogleAuthHelper>(context, listen: false)
                          .signOutFromGoogle();
                    } else if (authChoices.isFacebookVerification) {
                      Provider.of<FacebookAuthHelper>(context, listen: false)
                          .signOutWithFacebook();
                    } else {
                      Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                              builder: (builder) => const AuthScreen()));
                      await _auth.signOut();
                    }
                  }
                },
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.purpleAccent,
                ),
                items: [
                  DropdownMenuItem(
                      value: 'logout',
                      child: Row(
                        children: const [
                          Text('Log Out'),
                          SizedBox(
                            width: 8,
                          ),
                          Icon(Icons.logout_rounded)
                        ],
                      )),
                ]),
          )
        ],
      ),
      body: Column(
        children: const [
          Expanded(child: Messages()),
          NewMessage(),
        ],
      ),
    );
  }
}
