// ignore_for_file: prefer_const_declarations, prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FirebaseOptions firebaseOptions = const FirebaseOptions(
    apiKey: "AIzaSyDK8DgkMS5aFFPinAdYYlaJtOF7bfEwb2Y",
    appId: "1:217824312912:android:b481879ffc783d0a3d1b55",
    messagingSenderId: "217824312912",
    projectId: "chatapptut-b7e82",
  );

  await Firebase.initializeApp(options: firebaseOptions);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
    );
  }
}
