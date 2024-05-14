import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:mlmui/models/CourseDTO.dart';
import 'package:mlmui/models/RoomDTO.dart';
import 'package:mlmui/models/UserDTO.dart';
import 'package:mlmui/pages/Common/ProfileScreen.dart';
import 'package:mlmui/pages/LibrarianScreens/BookCreateByExcel.dart';
import 'package:mlmui/pages/LibrarianScreens/BookCreatePage.dart';
import 'package:mlmui/pages/LibrarianScreens/BookDetailsPageForLibrarian.dart';
import 'package:mlmui/pages/LibrarianScreens/EbookDetailsPageForLibrarian.dart';
import 'package:mlmui/pages/LibrarianScreens/BookListScreen.dart';
import 'package:mlmui/pages/LibrarianScreens/CopyCardManagement.dart';
import 'package:mlmui/pages/LibrarianScreens/LibListScreen.dart';
import 'package:mlmui/pages/LibrarianScreens/LibrarianHome.dart';
import 'package:mlmui/pages/LibrarianScreens/RoomDetailPage.dart';
import 'package:mlmui/pages/LibrarianScreens/RoomManagementScreen.dart';
import 'package:mlmui/pages/Onboarding/LoginScreen.dart';
import 'package:mlmui/pages/SplashScreen.dart';
import 'package:mlmui/pages/UserScreens/BookListForUserScreen.dart';
import 'package:mlmui/pages/UserScreens/CopyCard.dart';
import 'package:mlmui/pages/UserScreens/Queue.dart';
import 'package:mlmui/pages/UserScreens/RoomListScreen.dart';
import 'package:mlmui/pages/UserScreens/UserHome.dart';
import 'package:mlmui/pages/LibrarianScreens/UserListScreen.dart';
import 'package:mlmui/pages/Onboarding/VerifyScreen.dart';
import 'package:mlmui/pages/UserScreens/BookDetailsPage.dart';
import 'package:mlmui/pages/UserScreens/EbookDetailsPage.dart';
import 'package:mlmui/pages/LibrarianScreens/UpdateBookPage.dart';
import 'package:mlmui/pages/LibrarianScreens/CreateRoomPage.dart';
import 'models/BookDTO.dart';
import 'models/EbookDTO.dart';
import 'pages/Onboarding/RegisterScreen.dart';
import 'package:mlmui/pages/UserScreens/MyBooksPage.dart';
import 'package:mlmui/pages/UserScreens/FavoriteListScreen.dart';
import 'package:mlmui/pages/LecturerScreens/AddCourseScreen.dart';
import 'package:mlmui/pages/LecturerScreens/CreateCourse.dart';
import 'package:mlmui/pages/LecturerScreens/CourseDetailPage.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterWebFrame(
        builder: (context){
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
              '/bookcreate': (context) =>  BookCreatePage(),
              '/bookcreatebyexcel':(context) => BookCreateByExcelPage(),
              '/booklistforuser': (context) => BookListForUserScreen(),
              '/bookdetails': (context) => BookDetailsPage(book: ModalRoute.of(context)?.settings.arguments as BookDTO),
              '/bookdetailsForLibrarian': (context) => BookDetailsPageForLibrarian(book: ModalRoute.of(context)?.settings.arguments as BookDTO),
              '/updatebookpage' : (context) => UpdateBookPage(),
              '/ebookdetails': (context) => EbookDetailsPage(ebook: ModalRoute.of(context)?.settings.arguments as EbookDTO),
              '/ebookdetailsForLibrarian': (context) => EbookDetailsPageForLibrarian(ebook: ModalRoute.of(context)?.settings.arguments as EbookDTO),
              '/copycard':(context) => CopyCard(),
              '/copycardmanagement':(context) => CopyCardManagement(),
              '/queueuser':(context) => QueueUser(book: ModalRoute.of(context)?.settings.arguments as BookDTO),
              '/mybookspage':(context) => MyBooksPage(),
              '/createroom':(context) => CreateRoomPage(),
              '/roomLib':(context) => RoomManagementScreen(),
              '/roomlistuser':(context) => RoomListScreen(),
              '/profile':(context)=>ProfileScreen(userDTO: ModalRoute.of(context)?.settings.arguments as UserDTO, role: ModalRoute.of(context)?.settings.arguments as String),
              '/RoomDetailPage':(context) => RoomDetailPage(roomDTO: ModalRoute.of(context)?.settings.arguments as RoomDTO),
              '/FavoriteListScreen':(context) => const FavoriteListScreen(),
              '/AddCourseScreen':(context) => AddCourseScreen(),
              '/createCourse':(context) => CreateCourse(),
              '/coursedetailpage':(context) => CourseDetailPage(courseDTO: ModalRoute.of(context)?.settings.arguments as CourseDTO),
            },
          );
        },
      maximumSize: Size(675.0,MediaQuery.of(context).size.height),
      enabled: kIsWeb,
      backgroundColor: Colors.grey,

    );

  }
}
