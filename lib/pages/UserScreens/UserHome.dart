
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
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

import '../../service/constants.dart';
import 'BookDetailsPage.dart';


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
  late Future<bool> reservationFlag;
  int size = 10;
  late Future<BookDTOListResponse> bookDTOListResponseFuture;
  List<BookDTO> bookDTOList = [];
  String? code;

  @override
  void initState() {
    super.initState();
    fetchBooks();
    userFuture = apiService.getUserDetails();
    reservationFlag = apiService.checkReservationIsExists();
  }

  refresh()  {
    setState(() {

    reservationFlag = apiService.checkReservationIsExists();
    });
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
        backgroundColor: Constants.mainRedColor,
        title: const Text(
            'MLM',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
              Icons.menu,
              color: Colors.white,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
              icon: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 34.0),
              onPressed: (){
                Navigator.pushNamed(context, '/FavoriteListScreen');
              }
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
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  if (snapshot.error is CustomException) {
                    CustomException customException = snapshot.error as CustomException;
                    if (customException.message == 'NEED_LOGIN') {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.error(
                            message: "Session experied.",
                            textAlign: TextAlign.center,
                          ),
                        );
                        Navigator.pushReplacementNamed(context2, '/login');
                      });
                      return const Text('');
                    } else {
                      return const Text('');
                    }
                  } else {
                    return const Text('');
                  }
                } else {
                  final user = snapshot.data;
                  return Row(
                    children: [
                      Text(
                          'Welcome, ${user?.fullName}',
                          style: const TextStyle(
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
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  if (snapshot.error is CustomException) {
                    CustomException customException = snapshot.error as CustomException;
                    if (customException.message == 'NEED_LOGIN') {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.error(
                            message: "Session experied.",
                            textAlign: TextAlign.center,
                          ),
                        );
                        Navigator.pushReplacementNamed(context2, '/login');
                      });
                      return const Text('');
                    } else {
                      return const Text('');
                    }
                  } else {
                    return const Text('');
                  }
                } else {
                  final user = snapshot.data;
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30.0,0,0,0),
                        child: Row(
                          children: <Widget>[
                            if(user!.role == "USER")
                              if(user!.debt != null && user.debt! > 0)
                                const Text(
                                  'Debt:',
                                  style: TextStyle(
                                    color: Constants.mainRedColor,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if(user.debt != null && user.debt! > 0)
                                Text(
                                  '${user.debt} ₺',//${user?.dept}
                                  style: const TextStyle(
                                    color: Constants.mainDarkColor,
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                OutlinedButtons(
                  buttonLabel: 'Copy Card',
                  buttonIcon: Icons.credit_card,
                  onPressed: () async {
                   Object? status = await Navigator.pushNamed(context, '/copycard');

                  },
                  color: Constants.mainDarkColor,
                ),
                OutlinedButtons(
                    buttonLabel: 'My Books',
                    buttonIcon: Icons.library_books,
                    onPressed: () {

                      Navigator.pushNamed(context, '/mybookspage');
                    },
                  color: Constants.mainDarkColor,
                )
              ],
            ),

            FutureBuilder<bool>(
              future: reservationFlag,
              builder: (context2, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('');
                } else if (snapshot.hasError) {
                  print("error mu"+snapshot.hasError.toString());
                  if (snapshot.error is CustomException) {
                    CustomException customException = snapshot.error as CustomException;
                    if (customException.message == 'NEED_LOGIN') {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.error(
                            message: "Session experied.",
                            textAlign: TextAlign.center,
                          ),
                        );
                        Navigator.pushReplacementNamed(context2, '/login');
                      });

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlinedButtons(
                            buttonLabel: 'Room Res.',
                            buttonIcon: Icons.schedule,
                            onPressed: (){
                              Navigator.pushNamed(context, '/roomlistuser');
                            },
                            color: Constants.mainDarkColor,
                          ),
                        ],
                      );


                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlinedButtons(
                            buttonLabel: 'Room Res.',
                            buttonIcon: Icons.schedule,
                            onPressed: (){
                              Navigator.pushNamed(context, '/roomlistuser');
                            },
                            color: Constants.mainDarkColor,
                          ),
                        ],
                      );
                    }
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        OutlinedButtons(
                          buttonLabel: 'Room Res.',
                          buttonIcon: Icons.schedule,
                          onPressed: (){
                            Navigator.pushNamed(context, '/roomlistuser');
                          },
                          color: Constants.mainDarkColor,
                        ),
                      ],
                    );
                  }
                }else if(snapshot.data! == true){
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      OutlinedButtons(
                        buttonLabel: 'Room Res.',
                        buttonIcon: Icons.schedule,
                        onPressed: () async{
                          Object? a = await Navigator.pushNamed(context, '/roomlistuser');
                          if (a == "s") {
                            refresh();
                          }
                        },
                        color: Constants.mainDarkColor,
                      ),
                      OutlinedButtons(
                        buttonLabel: 'Room Con.',
                        buttonIcon: Icons.check_circle,
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AiBarcodeScanner(

                                canPop: false,
                                onScan: (String value) {
                                  debugPrint(value);
                                  setState(() {
                                    code = value;
                                  });
                                },
                                onDetect: (p0) {
                                  Navigator.pop(context);
                                },
                                onDispose: () {
                                  debugPrint("Barcode scanner disposed!");
                                },
                                controller: MobileScannerController(
                                  detectionSpeed: DetectionSpeed.noDuplicates,
                                ),
                              ),
                            ),
                          );
                          print('Room Con. pressed');

                        },
                        color: Colors.green,
                      )
                    ],
                  );



                }else{
                  print(snapshot.data);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      OutlinedButtons(
                        buttonLabel: 'Room Res.',
                        buttonIcon: Icons.schedule,
                        onPressed: (){
                          Navigator.pushNamed(context, '/roomlistuser');
                        },
                        color: Constants.mainDarkColor,
                      ),

                    ],
                  );
                }
              }),

            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Books',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
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
                    child: const Text(
                      'MORE',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),//Books
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
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Text('');
                              } else {
                                String base64Image = snapshot.data!;
                                return GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookDetailsPage(
                                            book: currentbook),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 140,
                                    width: 110,
                                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox.fromSize(
                                        size: const Size.fromRadius(10), // Image radius
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
                                              filter: ui.ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                                              child: Container(
                                                color: Constants.mainDarkColor.withOpacity(0.4),
                                              ),
                                            ),
                                            Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Text(
                                                        currentbook.name!.length<10?currentbook.name!:"${currentbook.name!.substring(0,10)}...",
                                                        style: const TextStyle(
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
                                  ),
                                );
                              }
                            }
                        );
                      }
                      return null;
                    }
                ),
              ),
            ),//List of books
            Padding(
              padding: const EdgeInsets.fromLTRB(3.0, 3.0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Licenced Softwares',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
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
                    child: const Text(
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
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
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
                              const Padding(
                                padding: EdgeInsets.all(10), // Padding for the text inside the card
                                child: Text(
                                  'Digital Library', // Replace with your title text
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Padding(
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

