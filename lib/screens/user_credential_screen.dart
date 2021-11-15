import 'dart:io';

import '/screens/chat_screen.dart';
import '../widgets/pickers/user_image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserCredentialInputPage extends StatefulWidget {
  const UserCredentialInputPage({Key? key}) : super(key: key);

  @override
  _UserCredentialInputPageState createState() =>
      _UserCredentialInputPageState();
}

class _UserCredentialInputPageState extends State<UserCredentialInputPage> {
  late File? _userImageFile = File("");
  void _pickedImage(File? image) {
    _userImageFile = image;
  }

  Future<void> _submitUserInformation() async {
    FocusScope.of(context).unfocus();
    if (_userImageFile == File("")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).errorColor,
          content: const Text('Please Pick An Image'),
        ),
      );
      return;
    } else if (userNameController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).errorColor,
          content: const Text('Please Enter An User Name'),
        ),
      );
      return;
    } else {
      User? userCredential = FirebaseAuth.instance.currentUser;
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_image')
          .child('${userCredential!.uid}.jpg');
      //Storing files
      await ref.putFile(_userImageFile!);
      final url = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.uid)
          .set({
        'username': userNameController.text,
        'image_url': url,
        //changes
        // "image_url": "https://i.imgur.com/yfCr8yz.png",
      }).whenComplete(() {
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (_) => const ChatScreen()));
      });
    }
  }

  final userNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Enter you information'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.98,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  image: const AssetImage('images/user_info.png'),
                  height: MediaQuery.of(context).size.height * 0.40,
                  width: double.infinity,
                ),
                UserImagePicker(_pickedImage),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 20.0),
                  child: TextField(
                    controller: userNameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.info,
                        color: Colors.orange,
                      ),
                      hintText: 'Enter your Chit-Chat User Name',
                      labelText: 'User Name',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(255, 68, 51, 1), width: 1.5),
                      ),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                    onPressed: _submitUserInformation,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Lets Chat !'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
