import 'package:flutter/material.dart';
import 'package:mlmui/models/CourseDTO.dart';
import 'package:mlmui/models/CourseMaterialDTO.dart';
import 'package:mlmui/models/UserDTO.dart';
import 'package:mlmui/pages/Common/ProfileScreen.dart';
import 'package:mlmui/pages/UserScreens/EbookDetailsPage.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../components/MaterialCard.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../components/UserCard.dart';
import '../../service/ApiService.dart';
import 'package:we_slide/we_slide.dart';

import '../../service/constants.dart';

class CourseDetailPageUser extends StatefulWidget {
  final CourseDTO courseDTO;
  const CourseDetailPageUser({Key? key, required this.courseDTO}) : super(key: key);

  @override
  State<CourseDetailPageUser> createState() => _CourseDetailPageUserState();
}

class _CourseDetailPageUserState extends State<CourseDetailPageUser> {

  final ApiService apiService = ApiService();



  @override
  void initState() {
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.mainRedColor,
          title: Text('${widget.courseDTO.name} Material List',style: TextStyle(color: Constants.whiteColor),),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Constants.whiteColor,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
          child: widget.courseDTO.courseMaterialDTOList!.isEmpty
              ? Center(child: Container(child: const Text("There is no material :(")))
              : ListView.builder(
            itemCount: widget.courseDTO.courseMaterialDTOList!.length ,
            itemBuilder: (context2, index) {
                CourseMaterialDTO current = widget.courseDTO.courseMaterialDTOList![index];
                return GestureDetector(
                  onTap: () async{
                    Future<CourseMaterialDTO> courseMaterialFuture = apiService.getCourseMaterialById(current.id!);
                    CourseMaterialDTO courseMaterialDTO = await courseMaterialFuture;
                    if(courseMaterialDTO != null){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EbookDetailsPage(
                                ebookData: courseMaterialDTO.data!,),
                        ),
                      );
                    }

                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide()),
                    ),
                    child: ListTile(
                      title: MaterialCard(item: current),
                    ),
                  ),
                );
            },
          )
        )
    );
  }
}
