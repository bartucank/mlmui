
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mlmui/pages/LecturerScreens/CourseDetailPage.dart';
import 'package:mlmui/pages/LibrarianScreens/RoomDetailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../models/CourseDTO.dart';
import '../../components/CourseItem.dart';
import 'package:mlmui/models/CourseDTOListResponse.dart';
import '../../service/ApiService.dart';


import '../../service/constants.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({Key? key}) : super(key: key);

  @override
  State<AddCourseScreen> createState() => _AddCourseScreen();
}

class _AddCourseScreen extends State<AddCourseScreen> {

  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<CourseDTO> courseDTOList = [];

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
  void fetchCourse() async {
    try {
      CourseDTOListResponse response = await apiService.getCourseForLecturer();
      print(response);
      setState(() {
        courseDTOList.clear();
        courseDTOList.addAll(response.courseDTOList);
      });
    } catch (e) {
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCourse();
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
            Object? a = await Navigator.pushNamed(context, "/coursedetailpage");
            if(a=="s"){
              fetchCourse();
            }
          },
          child: const Icon(Icons.add,color: Constants.whiteColor,),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        key: _scaffoldKey,
        backgroundColor: Constants.mainBackgroundColor,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Constants.mainRedColor,
          title: const Text('Course Management', style: TextStyle(
              color: Constants.whiteColor
          ),),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,color: Constants.whiteColor,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          child: GridView.builder(

            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            itemCount: courseDTOList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder<String>(
                future: getImageBase64(courseDTOList[index].imageId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return GestureDetector(
                          onTap: () async {
                            Object a = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseDetailPage(/*courseDTO: courseDTOList[index],*/),
                              ),
                            );
                            if(a == 'reload'){
                              fetchCourse();
                            }

                          },
                          child: CourseItem(base64Image: snapshot.data!, courseDTO: courseDTOList[index],));
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
