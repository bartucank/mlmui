import 'package:flutter/material.dart';
import 'package:mlmui/pages/LibrarianScreens/BookListScreen.dart';
import 'package:mlmui/pages/LibrarianScreens/LibListScreen.dart';
import 'package:mlmui/pages/LibrarianScreens/LibrarianHome.dart';
import 'package:mlmui/pages/Onboarding/LoginScreen.dart';
import 'package:mlmui/pages/SplashScreen.dart';
import 'package:mlmui/pages/UserScreens/UserHome.dart';
import 'package:mlmui/pages/LibrarianScreens/UserListScreen.dart';
import 'package:mlmui/pages/Onboarding/VerifyScreen.dart';

import 'pages/Onboarding/RegisterScreen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MLM',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home:  SplashScreen(),
      routes: {
        '/splash': (context) => SplashScreen(),
        '/register': (context) =>  RegisterScreen(),
        '/login': (context) =>  LoginScreen(),
        '/verify': (context) =>  VerifyScreen(),
        '/libHome': (context) =>  LibrarianHome(),
        '/userHome': (context) =>  UserHome(),
        '/userlist': (context) =>  UserListScreen(),
        '/liblist': (context) =>  LibListScreen(),
        '/booklist': (context) =>  BookListScreen(),
      },
    );

  }
}
