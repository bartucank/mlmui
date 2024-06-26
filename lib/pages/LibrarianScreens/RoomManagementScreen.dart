
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mlmui/models/RoomDTOListResponse.dart';
import 'package:mlmui/pages/LibrarianScreens/BookQueueDetail.dart';
import 'package:mlmui/pages/LibrarianScreens/RoomDetailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:mlmui/components/BookCard.dart';
import '../../components/MenuDrawerLibrarian.dart';

import '../../components/RoomItem.dart';
import '../../models/BookCategoryEnumDTO.dart';

import '../../models/RoomDTO.dart';
import '../../service/ApiService.dart';
import 'package:we_slide/we_slide.dart';


import '../../service/constants.dart';
import '../UserScreens/BookDetailsPage.dart';

class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({Key? key}) : super(key: key);

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {

  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<RoomDTO> roomDTOList = [];

  static Future<String> getImageBase64(int imageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString(imageId.toString());

    if (base64Image != null) {
      return base64Image;
    } else {
      final response = await http.get(Uri.parse(
          '${Constants.apiBaseUrl}/api/user/getImageBase64ById?id=$imageId'));

      if (response.statusCode == 200) {
        String base64 = base64Encode(response.bodyBytes);
        prefs.setString(imageId.toString(), base64);
        return base64;
      } else {
        return "1";
      }
    }
  }
  void fetchRooms() async {
    try {
      RoomDTOListResponse response = await apiService.getrooms();
      // print(response);
      setState(() {
        roomDTOList.clear();
        roomDTOList.addAll(response.roomDTOList);
      });
    } catch (e) {
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }



  @override
  void dispose() {
    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor:Constants.mainRedColor,
          onPressed: () async {
              Object? a = await Navigator.pushNamed(context, "/createroom");
              if(a=="s"){
                fetchRooms();
              }
          },
          child: Icon(Icons.add,color: Constants.whiteColor,),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        key: _scaffoldKey,
        backgroundColor: Constants.mainBackgroundColor,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Constants.mainRedColor,
          title: Text('Room Management', style: TextStyle(
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
        body: Container(
          width: double.infinity,
          child: GridView.builder(

            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            itemCount: roomDTOList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder<String>(
                future: getImageBase64(roomDTOList[index].imageId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return GestureDetector(
                         onTap: () async {
                           Object a = await Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => RoomDetailPage(roomDTO: roomDTOList[index],),
                             ),
                           );
                           if(a == 'reload'){
                             fetchRooms();
                           }

                         },
                          child: RoomItem(base64Image: snapshot.data!, roomDTO: roomDTOList[index],));
                    }
                  }
                },
              );
            },
          ),
        )
    );
  }
}

void dissmissed() {}
