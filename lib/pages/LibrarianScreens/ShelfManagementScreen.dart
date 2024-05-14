import 'dart:async';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'package:mlmui/models/UserNamesDTO.dart';
import 'package:mlmui/models/UserNamesDTOListResponse.dart';
import 'package:mlmui/pages/LibrarianScreens/BookQueueDetail.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:mlmui/components/BookCard.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../models/BookCategoryEnumDTO.dart';
import '../../models/BookCategoryEnumDTOListResponse.dart';
import '../../models/BookDTOListResponse.dart';
import '../../models/ShelfDTO.dart';
import '../../service/ApiService.dart';
import 'package:we_slide/we_slide.dart';
import '../../service/constants.dart';
import 'BookDetailsPageForLibrarian.dart';
import 'package:mlmui/models/ShelfDTOListResponse.dart';

class ShelfManagementScreen extends StatefulWidget {
  const ShelfManagementScreen({Key? key}) : super(key: key);

  @override
  State<ShelfManagementScreen> createState() => _ShelfManagementScreen();
}

class _ShelfManagementScreen extends State<ShelfManagementScreen> {
  final listcontroller = ScrollController();
  WeSlideController weSlideController = WeSlideController();
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int page = -1;
  int size =kIsWeb?10:10;
  int totalSize = 0;
  int totalPage = 1000;
  List<ShelfDTO> shelfDTO = [];
  GlobalKey<ArtDialogState> _artDialogKey = GlobalKey<ArtDialogState>();
  bool isLoading = false;

  bool _switchValue = false;



  void fetchShelfs() async{
    try{
      ShelfDTOListResponse response =
      await apiService.getShelfDTOListResponse();
      setState(() {
        shelfDTO.addAll(response.shelfDTOList);
      });
    }catch(e){
      print("Error! $e");
    }
  }


  @override
  void initState() {
    super.initState();
    //fetchFirstBooks();
    listcontroller.addListener(() {
      if (listcontroller.position.maxScrollExtent == listcontroller.offset) {
        //fetchMoreBook();
      }
    });
    //_dropdownItemsForUsers.insert(0, UserNamesDTO("Select a user", -1));

  }

  @override
  void dispose() {
    listcontroller.dispose();
    super.dispose();
  }

  Future refresh() async {
    if(isLoading){
      return;
    }
    setState(() {
      //bookDTOList.clear();
    });
    page = -1;
    size = 10;
    //fetchFirstBooks();
  }




  final double _panelMinSize = 70.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Constants.mainRedColor,
          title: Text('Shelf List', style: TextStyle(
              color: Constants.whiteColor
          ),),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Constants.whiteColor,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      body:WeSlide(
        controller: weSlideController,
        panelMinSize: _panelMinSize,
        blur:false,
        panelMaxSize: MediaQuery.of(context).size.height / 2,
        overlayColor: Constants.mainDarkColor,
        blurColor: Constants.mainDarkColor,
        blurSigma: 2,
        backgroundColor: Colors.white,
        overlayOpacity: 0.7,
        overlay: true,
        panel:Container(
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
          padding:const EdgeInsets.fromLTRB(0, 0, 0, 80),
          child: shelfDTO.isEmpty ? const Text("")
              : RefreshIndicator(
              onRefresh: refresh,
            child: ListView.builder(
              controller: listcontroller,
              itemCount: shelfDTO.length + 1,
              itemBuilder: (context2, index) {
                if (index < shelfDTO.length) {
                  ShelfDTO currentShelf = shelfDTO[index];
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const StretchMotion(),
                      children: [
                        SlidableAction(
                            backgroundColor: Colors.blue,
                            icon: Icons.edit,
                            label: 'Delete',
                            onPressed: (context) {
                              //removeFavorite(currentbook);
                            }
                        ),
                        SlidableAction(
                          backgroundColor: Colors.green,
                          icon: Icons.format_list_bulleted,
                          label: 'Update',
                          onPressed: (BuildContext context) {  },
                        )
                      ],
                    ),
                    child: ListTile(
                      
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

void dissmissed() {}
