import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/providers/auth_choices.dart';
import '../utils/facebook_signin.dart';
import '../utils/google_sign_in.dart';
import '../screens/splash_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => GoogleAuthHelper()),
        ChangeNotifierProvider(create: (ctx) => FacebookAuthHelper()),
        ChangeNotifierProvider(create: (ctx) => AuthChoices()),
      ],
      child: FutureBuilder(
        future: _initialization,
        builder: (ctx, snapShot) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Chat X',
          theme: ThemeData.dark().copyWith(
              iconTheme: const IconThemeData(color: Colors.purpleAccent),
              appBarTheme: const AppBarTheme(
                  elevation: 10.0, backgroundColor: Colors.black45),
              textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all(Colors.deepPurpleAccent),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)))),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(10.0)),
                    backgroundColor: MaterialStateProperty.all(Colors.purple),
                    elevation: MaterialStateProperty.all(15.0)),
              ),
              primaryColor: Colors.purpleAccent,
              colorScheme:
                  ColorScheme.fromSwatch().copyWith(secondary: Colors.yellow)),
          home: snapShot.connectionState != ConnectionState.done
              ? const SplashScreen()
              : StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (ctx, userSnapShot) {
                    if (userSnapShot.hasData &&
                        FirebaseAuth.instance.currentUser!.emailVerified) {
                      // print(
                      //     "Here ${FirebaseAuth.instance.currentUser!.emailVerified}");
                      return const ChatScreen();
                    }
                    return const AuthScreen();
                  },
                ),
        ),
      ),
    );
  }
}
