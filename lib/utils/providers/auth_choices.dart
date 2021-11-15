import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthChoices with ChangeNotifier {
  final String _keyForEmailVerification = 'email';
  final String _keyForGoggleVerification = 'google';
  final String _keyForFacebookVerification = 'facebook';

  bool isEmailVerification = false;
  bool isGoogleVerification = false;
  bool isFacebookVerification = false;

  SharedPreferences? _prefs;

  AuthChoices() {
    isEmailVerification = false;
    isGoogleVerification = false;
    isFacebookVerification = false;
    _loadFromPrefs();
  }
  _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    isEmailVerification = _prefs!.getBool(_keyForEmailVerification) ?? false;
    isFacebookVerification =
        _prefs!.getBool(_keyForFacebookVerification) ?? false;
    isGoogleVerification = _prefs!.getBool(_keyForGoggleVerification) ?? false;
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    _prefs!.setBool(_keyForGoggleVerification, isGoogleVerification);
    _prefs!.setBool(_keyForFacebookVerification, isFacebookVerification);
    _prefs!.setBool(_keyForEmailVerification, isEmailVerification);

    notifyListeners();
  }

  // bool get isFacebookVerification => _isFacebookVerification;
  //
  // set isFacebookVerification(bool value) {
  //   _isFacebookVerification = value;
  // }
  //
  // set isEmailVerification(bool value) {
  //   _isEmailVerification = value;
  // }
  //
  // set isGoogleVerification(bool value) {
  //   _isGoogleVerification = value;
  // }
  //
  // bool get isGoogleVerification => _isGoogleVerification;
  //
  // bool get isEmailVerification => _isEmailVerification;
  void toggleAuthChoices(
      {required bool emailAuth,
      required bool facebookAuth,
      required bool goggleAuth}) {
    isEmailVerification = emailAuth;
    isFacebookVerification = facebookAuth;
    isGoogleVerification = goggleAuth;
    _saveToPrefs();
    notifyListeners();
  }
}
