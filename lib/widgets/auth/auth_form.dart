import 'dart:io';

import '/utils/providers/auth_choices.dart';
import '../pickers/user_image_picker.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(String email, String password, String username,
      File image, bool isLogin) _submitForm;
  final bool _isLoading;
  const AuthForm(this._submitForm, this._isLoading);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;

  String _userEmail = "";
  String _userName = "";
  String _userPassword = "";
  String _retypedPassword = "";
  var _userImageFile = File("");
  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() {
    final authChoices = Provider.of<AuthChoices>(context, listen: false);
    authChoices.toggleAuthChoices(
        emailAuth: true, facebookAuth: false, goggleAuth: false);
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_userImageFile == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).errorColor,
          content: const Text('Please Pick An Image'),
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState!.save();
      // print(_userName);
      // print(_userEmail);
      // print(_userPassword);
      widget._submitForm(_userEmail.trim(), _userPassword.trim(), _userName,
          _userImageFile, _isLogin);
    }
    //after validating send to server
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        elevation: 20.0,
        margin: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isLogin) UserImagePicker(_pickedImage),
                  TextFormField(
                    onSaved: (value) {
                      _userEmail = value!;
                    },
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Please Chek Your Email-ID';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(labelText: 'Email Address'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onSaved: (value) {
                      _userName = value!;
                    },
                    validator: (value) {
                      if (value!.isEmpty || value.length < 4) {
                        return 'Enter atleast 4 characters';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(labelText: 'User Name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onChanged: (val) {
                      _userPassword = val;
                    },
                    onSaved: (value) {
                      _userPassword = value!;
                    },
                    validator: (value) {
                      if (value!.isEmpty || value.length < 7) {
                        return 'Password must be atleast 7 character long';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (!_isLogin)
                    TextFormField(
                      // onSaved: (value) {
                      //   _retypedPassword  = value!;
                      // },
                      validator: (value) {
                        if (value!.isEmpty ||
                            value.length < 7 ||
                            value != _userPassword) {
                          return 'Check Your Retyped Password !';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: 'Confirm Password'),
                    ),
                  if (!_isLogin)
                    const SizedBox(
                      height: 10,
                    ),
                  if (widget._isLoading) const CircularProgressIndicator(),
                  if (!widget._isLoading)
                    ElevatedButton(
                        onPressed: _trySubmit,
                        child: Text(
                          _isLogin ? 'Login' : 'Signup',
                          style: const TextStyle(fontSize: 15),
                        )),
                  if (!widget._isLoading)
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(_isLogin
                            ? 'Create New Account'
                            : 'I have an account'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
