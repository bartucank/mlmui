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
          body: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
            child: mybooksDTOList.isEmpty ? Text(""):
                RefreshIndicator(
                    onRefresh: refresh,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: mybooksDTOList.length,
                      itemBuilder: (context, index){
                        if(index < mybooksDTOList.length){
                          print('Geldi mi ?');
                          MyBooksDTO currentbook = mybooksDTOList[index];
                          return Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  child: FutureBuilder<String>(
                                      future: BookCard.getImageBase64(currentbook.book.imageId!),
                                      builder: (context, snapshot){
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          print('Geldi mi ?2');
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          print('Geldi mi ?3');
                                          return Text('');
                                        } else {
                                          print('Geldi mi ?4');
                                          String base64Image = snapshot.data!;
                                          return Container(
                                            height: 150,
                                            width: 100,
                                            margin: EdgeInsets.fromLTRB(0, 0, 70, 10),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: SizedBox.fromSize(
                                                size: Size.fromRadius(10), // Image radius
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: <Widget>[
                                                    Image.memory(
                                                      base64Decode(base64Image),
                                                      fit: BoxFit.cover,
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
                                                                currentbook.book.name!.length<10?currentbook.book.name!:currentbook.book.name!.substring(0,10)+"...",
                                                                style: TextStyle(
                                                                    fontSize: 30,
                                                                    fontWeight: FontWeight.bold,
                                                                    foreground: Paint()
                                                                      ..style = PaintingStyle.stroke
                                                                      ..strokeWidth = 3
                                                                      ..color = Colors.black
                                                                ),
                                                              ),
                                                              Text(
                                                                currentbook.book.name!.length<10?currentbook.book.name!:currentbook.book.name!.substring(0,10)+"...",
                                                                style: TextStyle(
                                                                    fontSize: 30,
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
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        margin: EdgeInsets.only(bottom: 5),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black),
                                        ),
                                        child: Stack(
                                          children: <Widget>[
                                            if(currentbook!.isLate == false)
                                              Text(
                                                '${currentbook.days} Days Left!',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color:Colors.red
                                                ),
                                            ),
                                            if(currentbook!.isLate == true)
                                              Text(
                                                '-${currentbook.days} Days Left!',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color:Colors.red
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      }
                  ),
                )
          ),
        )
    );
  }
}

void dissmissed() {}
