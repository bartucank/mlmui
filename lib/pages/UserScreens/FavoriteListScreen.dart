import 'dart:async';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mlmui/models/MyBooksDTO.dart';
import 'package:mlmui/models/MyBooksDTOListResponse.dart';
import 'package:mlmui/components/BookCard.dart';
import 'package:mlmui/pages/UserScreens/BookDetailsPage.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../service/ApiService.dart';
import 'package:we_slide/we_slide.dart';
import 'dart:convert';
import 'package:mlmui/models/BookDTO.dart';

import '../../service/constants.dart';



class FavoriteListScreen extends StatefulWidget {

  const FavoriteListScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteListScreen> createState() => _FavoriteListScreen();
}

class _FavoriteListScreen extends State<FavoriteListScreen> {
  final listcontroller = ScrollController();
  WeSlideController weSlideController = WeSlideController();
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<BookDTO> favoritebooks = [];
  bool isLoading = false;
  Map<String, dynamic> globalFilterRequest = {};


  void removeFavorite(BookDTO book)async{
    try{
      String response = await apiService.removeFavorite(book.id!);
    }catch(e){
      print("Error! $e");
    }
    fetchMyBooks();
  }

  void fetchMyBooks() async{

    try{
      List<BookDTO> response =
      await apiService.getFavoriteBooks();
      setState(() {
        favoritebooks = response.toList();
      });
    }catch(e){
      print("Error! $e");
    }
  }

  Future refresh() async {
    setState(() {
      favoritebooks.clear();
    });
    fetchMyBooks();
  }
  

  @override
  void initState() {
    super.initState();

    fetchMyBooks();
    listcontroller.addListener(() {
      if (listcontroller.position.maxScrollExtent == listcontroller.offset) {
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
          backgroundColor: Constants.mainRedColor,
          title: const Text('My Books'),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
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
          overlayColor: Constants.mainDarkColor,
          blurColor: Constants.mainDarkColor,
          blurSigma: 2,
          backgroundColor: Colors.white,
          overlayOpacity: 0.7,
          overlay: true,
          panel: Container(
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
            child: favoritebooks.isEmpty
                ? const Text("")
                : RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                controller: listcontroller,
                itemCount: favoritebooks.length + 1,
                itemBuilder: (context2, index) {
                  if (index < favoritebooks.length) {
                    BookDTO currentbook = favoritebooks[index];
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                              backgroundColor: Colors.blue,
                              icon: Icons.edit,
                              label: 'Remove',
                              onPressed: (context) {
                                removeFavorite(currentbook);
                              }
                          ),
                          SlidableAction(
                            backgroundColor: Colors.green,
                            icon: Icons.format_list_bulleted,
                            label: 'Details',
                            onPressed: (context) {
                              dissmissed();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookDetailsPage(book: currentbook),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                      child: ListTile(
                        title: BookCard(book: currentbook),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        )
    );
  }
}

void dissmissed() {}
