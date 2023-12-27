import 'dart:async';


import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:mlmui/models/BookDTO.dart';
import 'package:mlmui/models/MyBooksDTO.dart';
import 'package:mlmui/models/MyBooksDTOListResponse.dart';
import 'package:mlmui/components/BookCard.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../service/ApiService.dart';
import 'package:we_slide/we_slide.dart';
import 'dart:convert';



class MyBooksPage extends StatefulWidget {
  const MyBooksPage({Key? key}) : super(key: key);

  @override
  State<MyBooksPage> createState() => _MyBooksPage();
}

class _MyBooksPage extends State<MyBooksPage> {
  final listcontroller = ScrollController();
  WeSlideController weSlideController = WeSlideController();
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<MyBooksDTO> mybooksDTOList = [];
  late Future<MyBooksDTOListResponse> mybookDTOListResponseFuture;

  bool isLoading = true;


  void fetchMyBooks() async{
    try{
      MyBooksDTOListResponse response =
      await apiService.getMyBooks();
      print('Geldi mi ?9');
      setState(() {
        mybooksDTOList.addAll(response.myBooksDTOList);
        print('Geldi mi ?7');
      });
    }catch(e){
      print("Error! $e");
    }
  }

  Future refresh() async {
    setState(() {
      mybooksDTOList.clear();
    });
    fetchMyBooks();
    print('Geldi mi ?6');
  }

  @override
  void initState() {
    super.initState();

    fetchMyBooks();
    print('Geldi mi ?8');
    listcontroller.addListener(() {
      if (listcontroller.position.maxScrollExtent == listcontroller.offset) {
        print('Geldi mi ?5');
        fetchMyBooks();
      }
    });
  }

  final double _panelMinSize = 70.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Color(0xffd2232a),
          title: Text('My Books'),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: WeSlide(
          controller: weSlideController,
          panelMinSize: _panelMinSize,
          blur: false,
          panelMaxSize: MediaQuery.of(context).size.height / 2,
          overlayColor: Colors.black,
          blurColor: Colors.black,
          blurSigma: 2,
          backgroundColor: Colors.white,
          overlayOpacity: 0.7,
          overlay: true,
          panel: Container(
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Books", // Replace with the text you want to display
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 400),
                  child: mybooksDTOList.isEmpty ? Text("") :
                  RefreshIndicator(
                    onRefresh: refresh,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: mybooksDTOList.length,
                      itemBuilder: (context, index) {
                        MyBooksDTO currentbook = mybooksDTOList[index];
                        return Column(
                          children: [
                            Container(
                              height: 110,
                              width: 100,
                              margin: EdgeInsets.all(5),
                              child: FutureBuilder<String>(
                                future: BookCard.getImageBase64(currentbook.book.imageId!),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error');
                                  } else {
                                    String base64Image = snapshot.data!;
                                    return Stack(
                                      alignment: Alignment.bottomLeft,
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.memory(
                                            base64Decode(base64Image),
                                            fit: BoxFit.cover,
                                            height: 150,
                                            width: 100,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.black.withOpacity(0.3), // Semi-transparent black overlay
                                          ),
                                          height: 150,
                                          width: 100,
                                          alignment: Alignment.center,
                                        ),
                                        Text(
                                          currentbook.book.name!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            // The paint property here creates the stroke effect.
                                            foreground: Paint()
                                              ..style = PaintingStyle.stroke
                                              ..strokeWidth = 4
                                              ..color = Colors.black,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          currentbook.book.name!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0), // Add padding inside the container
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 2), // Border color and width
                                borderRadius: BorderRadius.circular(4), // Adjust radius to match your design
                              ),
                              child: Row(
                                children: <Widget>[
                                  if(currentbook!.isLate == false)
                                  Text(
                                    '${currentbook.days} Days Left!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if(currentbook!.isLate == true)
                                    Text(
                                      '${currentbook.days} Days Late!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    )
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}

void dissmissed() {}
