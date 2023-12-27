import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:mlmui/models/BookDTO.dart';
import '../../components/MenuDrawer.dart';
import '../../models/UserDTO.dart';
import '../../service/ApiService.dart';
import '../../components/OutlinedButtons.dart';
import '../../models/BookDTOListResponse.dart';
import 'dart:convert';
import 'package:mlmui/components/BookCard.dart';
import 'dart:ui' as ui;


class UserHome extends StatefulWidget {
  const UserHome({Key? key}) : super(key: key);

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {

  final ApiService apiService = ApiService();
  late Future<UserDTO> userFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> imgList = [
    'assets/images/bg.jpg',
    'assets/images/default.png',
    'assets/images/logo.png',
    'assets/images/mail.png',
  ];//Dummy code just to show licenced softwares

  int size = 6;
  late Future<BookDTOListResponse> bookDTOListResponseFuture;
  List<BookDTO> bookDTOList = [];


  @override
  void initState() {
    super.initState();
    fetchBooks();
    userFuture = apiService.getUserDetails();
  }


  void fetchBooks() async{
    Map<String, dynamic> request = {
      "size": size,
    };
    try {
      BookDTOListResponse response =
      await apiService.getBooksBySpecification(request);
      setState(() {
        bookDTOList.addAll(response.bookDTOList);
      });
    } catch (e) {
      print("Error! $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuDrawer(),
      appBar: AppBar(
        backgroundColor: Color(0xffd2232a),
        title: Text(
            'MLM',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
              Icons.menu,
              color: Colors.white,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
              icon: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 34.0),
              onPressed: (){}
          ),
          IconButton(
              icon: Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 34.0),
              onPressed: (){
                Navigator.pushNamed(context, '/mybookspage');
              }
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              PopupMenuItem(
                value: 'about',
                child: Text('About'),
              ),
            ],
            onSelected: (value) {
              // Handle menu item selection ask
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FutureBuilder<UserDTO>(
              future: userFuture,
              builder: (context2, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  if (snapshot.error is CustomException) {
                    CustomException customException = snapshot.error as CustomException;
                    if (customException.message == 'NEED_LOGIN') {
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
                            message: "Session experied.",
                            textAlign: TextAlign.center,
                          ),
                        );
                        Navigator.pushReplacementNamed(context2, '/login');
                      });
                      return Text('');
                    } else {
                      return Text('');
                    }
                  } else {
                    return Text('');
                  }
                } else {
                  final user = snapshot.data;
                  return Row(
                    children: [
                      Text(
                          'Welcome, ${user?.username}!',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                      ),



                    ],
                  );
                }
              },
            ),
            FutureBuilder<UserDTO>(
              future: userFuture,
              builder: (context2, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  if (snapshot.error is CustomException) {
                    CustomException customException = snapshot.error as CustomException;
                    if (customException.message == 'NEED_LOGIN') {
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
                            message: "Session experied.",
                            textAlign: TextAlign.center,
                          ),
                        );
                        Navigator.pushReplacementNamed(context2, '/login');
                      });
                      return Text('');
                    } else {
                      return Text('');
                    }
                  } else {
                    return Text('');
                  }
                } else {
                  final user = snapshot.data;
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30.0,0,0,0),
                        child: Row(
                          children: <Widget>[
                            if(user!.debt != null && user!.debt! > 0)
                              Text(
                                'Debt:',
                                style: TextStyle(
                                  color: Color(0xffd2232a),
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if(user!.debt != null && user!.debt! > 0)
                              Text(
                                '${user?.debt} ₺',//${user?.dept}
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  );
                }
              },
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0, 0),
              child: Row(
                children: <Widget>[
                  OutlinedButtons(
                    buttonLabel: 'Copy Card',
                    buttonIcon: Icons.credit_card,
                    onPressed: () async {
                     Object? status = await Navigator.pushNamed(context, '/copycard');

                    },
                    color: Colors.black,
                  ),
                  OutlinedButtons(
                      buttonLabel: 'My Books',
                      buttonIcon: Icons.library_books,
                      onPressed: () {
                        print("My books Pressed");
                      },
                    color: Colors.black,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0, 0),
              child: Row(
                children: <Widget>[
                  OutlinedButtons(
                    buttonLabel: 'Room Res.',
                    buttonIcon: Icons.schedule,
                    onPressed: (){
                      print('Room Res. pressed');
                    },
                    color: Colors.black,
                  ),
                  OutlinedButtons(
                      buttonLabel: 'Room Con.',
                      buttonIcon: Icons.check_circle,
                      onPressed: () {
                        print('Room Con. pressed');
                      },
                      color: Colors.green,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Books',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/booklistforuser');
                    },
                    child: Text(
                      'MORE',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(3.0, 3.0, 0, 0),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                height: 140,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: bookDTOList.length,
                    itemBuilder: (context, index){
                      if(index < bookDTOList.length){
                        BookDTO currentbook = bookDTOList[index];
                        return FutureBuilder<String>(
                            future: BookCard.getImageBase64(currentbook.imageId!),
                            builder: (context, snapshot){
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('');
                              } else {
                                String base64Image = snapshot.data!;
                                return Container(
                                  height: 140,
                                  width: 110,
                                  margin: EdgeInsets.symmetric(horizontal: 2.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox.fromSize(
                                      size: Size.fromRadius(10), // Image radius
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: <Widget>[
                                          Image.memory(
                                            base64Decode(base64Image),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,// Cover the card's upper part with the image
                                          ),
                                          BackdropFilter(
                                            filter: ui.ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0), // Adjust the blur intensity
                                            child: Container(
                                              color: Colors.black.withOpacity(0.1), // You can add a translucent color over the blurred image
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
                                              child: Stack(
                                                children: <Widget>[
                                                  Text(
                                                    currentbook.name!.length<10?currentbook.name!:currentbook.name!.substring(0,10)+"...",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        foreground: Paint()
                                                          ..style = PaintingStyle.stroke
                                                          ..strokeWidth = 3
                                                          ..color = Colors.black
                                                    ),
                                                  ),
                                                  Text(
                                                    currentbook.name!.length<10?currentbook.name!:currentbook.name!.substring(0,10)+"...",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color:Colors.white
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                        );
                      }
                    }
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(3.0, 3.0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Licenced Softwares',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      print('More Button Pressed for Licenced Softwares');
                    },
                    child: Text(
                      'MORE',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(3.0, 3.0, 0, 0),
              child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  height: 140,
                  child: ListView.builder(
                    // This makes the ListView scrollable horizontally.
                    scrollDirection: Axis.horizontal,
                    itemCount: imgList.length, // The number of items in the list
                    itemBuilder: (context, index) {
                      return Container(
                        width: 180,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Card(
                          clipBehavior: Clip.antiAlias, // Ensures the image corners are also clipped
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Rounded corners for the card
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretches children across the card's width
                            children: <Widget>[
                              Expanded(
                                child: Image.asset(
                                  imgList[index], // Replace with your image URL or asset
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover, // Covers the space, maintaining aspect ratio
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10), // Padding for the text inside the card
                                child: Text(
                                  'Digital Library', // Replace with your title text
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10), // Padding for the subtitle text
                                child: Text(
                                  'ACM', // Replace with your subtitle text
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

