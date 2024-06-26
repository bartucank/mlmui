
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../models/CourseDTO.dart';
import '../../components/CourseItem.dart';
import 'package:mlmui/models/CourseDTOListResponse.dart';
import '../../service/ApiService.dart';
import '../../service/constants.dart';
import 'CourseDetailPageUser.dart';

class GetCoursesScreen extends StatefulWidget {
  const GetCoursesScreen({Key? key}) : super(key: key);

  @override
  State<GetCoursesScreen> createState() => _GetCoursesScreen();
}

class _GetCoursesScreen extends State<GetCoursesScreen> {

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
      CourseDTOListResponse response = await apiService.getCourseForUser();
      setState(() {
        courseDTOList.clear();
        courseDTOList.addAll(response.courseDTOList);
      });
    } catch (e, stacktrace) {
      print("Error fetching courses: $e");
      print("Stacktrace: $stacktrace");
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

        key: _scaffoldKey,
        backgroundColor: Constants.mainBackgroundColor,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Constants.mainRedColor,
          title: const Text('Course List',
            style: TextStyle(
              color: Constants.whiteColor
            ),
          ),
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
                            Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CourseDetailPageUser(courseDTO: courseDTOList[index],),
                                  ),
                                );
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
