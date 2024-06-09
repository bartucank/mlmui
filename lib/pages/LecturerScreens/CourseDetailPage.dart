import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../models/CourseMaterialDTO.dart';
import '../../models/CourseStudentDTO.dart';
import '../../service/ApiService.dart';
import 'dart:convert';
import 'package:mlmui/service/constants.dart';
import '../../models/CourseDTO.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';



class CourseDetailPage extends StatefulWidget {
  final int courseId;
  const CourseDetailPage({Key? key, required this.courseId}) : super(key: key);

  @override
  State<CourseDetailPage> createState() => _CourseDetailPage();
}

class _CourseDetailPage extends State<CourseDetailPage> {
  MultiImagePickerController controller = MultiImagePickerController(
    maxImages: 1,
    allowedImageTypes: ['png', 'jpg', 'jpeg','heic','HEIC'],
    withData: true,
    withReadStream: true,
    images: <ImageFile>[],
  );
  late File selectedImage;
  late Uint8List? image;
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late String _base64Image;

  TextEditingController _studentIdController = TextEditingController();
  TextEditingController _materialNameController = TextEditingController();
  FilePickerResult? pickedFile;
  int? currentSelectedMaterialId;
  int? selectedStudentId;
  int defaultImg = 1;
  int lastIdForQr = 1;
  bool isLoading = false;
  String? name;

  CourseDTO courseDTO = new CourseDTO(1, "", 1, "", true, 1, [], []);




  void _showRemoveStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove Student"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                DropdownButton<int?>(
                  value: courseDTO.courseStudentDTOList?.first.id,
                  hint: Text("Select a student"),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedStudentId = newValue;
                      var selectedStudent = courseDTO.courseStudentDTOList?.firstWhere(
                              (s) => s.id == newValue
                      );
                      if (selectedStudent != null) {
                        _studentIdController.text = selectedStudent.studentNumber ?? "";
                      } else {
                        _studentIdController.text = "";
                      }
                    });
                  },
                  items: courseDTO.courseStudentDTOList?.map((student) {
                    return DropdownMenuItem<int>(
                      value: student.id,
                      child: Text("${student.studentName==null?"Unregistered St.":student.studentName} (${student.studentNumber})"),
                    );
                  }).toList(),
                ),
                TextFormField(
                  controller: _studentIdController,
                  decoration: InputDecoration(
                    labelText: "Or enter Student ID",
                    hintText: "Enter the student ID here",
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  await removeStudent(selectedStudentId);
                  _studentIdController.clear();
                  Navigator.of(context).pop();
                  fetchCourse();
                },
                child: Text("Yes")
            ),
            TextButton(
                onPressed: () {
                  _studentIdController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("No")
            ),
          ],
        );
      },
    );
  }

  Future<void> removeStudent(int? studentId) async {
    if (studentId == null) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "No valid student ID provided.",
          textAlign: TextAlign.left,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String result = await apiService.removeStudentFromCourse(courseDTO.id!, studentId);
      setState(() {
        isLoading = false;
      });

      if (result == "S") {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: "Student removed successfully!",
            textAlign: TextAlign.left,
          ),
        );
      } else {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "Unexpected error.",
            textAlign: TextAlign.left,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "Unexpected error please contact with the system administrator",
          textAlign: TextAlign.left,
        ),
      );
    }

    fetchCourse();
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Student"),
          contentPadding: EdgeInsets.all(0),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: _studentIdController,
                  decoration: InputDecoration(
                    labelText: "Student ID",
                    hintText: "Enter the student ID here",
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  saveStudent();

                  FocusScope.of(context).unfocus();
                  _studentIdController.clear();

                  fetchCourse();
                },
                child: Text("Add")
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel")
            ),
          ],
        );
      },
    );
  }

  void saveStudent() async{
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> request = {
      "courseId": courseDTO.id,
      "studentNumber": _studentIdController.text,
    };
    try{
      String result = await apiService.inviteStudent(request);
      setState(() {
        isLoading = false;
      });
      if(result == "S"){
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message:
            "Success!",
            textAlign: TextAlign.left,
          ),
        );
        Navigator.pop(context,"s");
      }else if(result.contains("Invalid student number.")){
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.info(
            message:
            "Invalid student number.",
            textAlign: TextAlign.left,
          ),
        );
      }else{
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message:
            "Unexpected error.",
            textAlign: TextAlign.left,
          ),
        );
      }
    }catch(e){
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message:
          "Unexpected error. Please contact system administrator.",
          textAlign: TextAlign.left,
        ),
      );
    }

    fetchCourse();
  }

  void _showAddMaterialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add File"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _materialNameController,
                decoration: InputDecoration(hintText: "Enter file name"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  pickedFile = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['epub','EPUB'],
                  );
                  if (pickedFile != null) {
                    print("File selected: ${pickedFile?.files.single.name}");
                  }
                },
                child: Text("Select EPUB"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                 Object a = saveMaterial();
                 if(a != -1){
                   _materialNameController.clear();

                   fetchCourse();

                   FocusScope.of(context).unfocus();
                   Navigator.of(context).pop();
                 }
                },
                child: Text("Add")
            ),
            TextButton(
                onPressed: () {
                  _materialNameController.clear();
                  Navigator.of(context).pop();

                  FocusScope.of(context).unfocus();

                  fetchCourse();
                },
                child: Text("Cancel")
            ),
          ],
        );
      },
    );
  }
  Future<String> downloadExcel() async {
    try {
      final Uri _url = Uri.parse("${Constants.apiBaseUrl}/api/admin/getCourseStudentExcelTemplate");
      if (!await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
      }
    } catch (e) {
      return "-1";
    }
    return "1";
  }

  void _showAddStudentBulkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Bulk Add Student"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  Object a = await downloadExcel();
                  if(a == "-1"){

                    Navigator.of(context).pop();
                  }
                },
                child: Text("Download Template"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  pickedFile = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['xlsx','Xlsx','XLSX','xls'],
                  );
                  if (pickedFile != null) {
                    print("File selected: ${pickedFile?.files.single.name}");
                  }
                },
                child: Text("Upload Filled Excel"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Object a = saveCourseStudentExcel();
                  if(a != -1){

                    fetchCourse();
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Save")
            ),
            TextButton(
                onPressed: () {
                  _materialNameController.clear();
                  Navigator.of(context).pop();

                  fetchCourse();
                },
                child: Text("Cancel")
            ),
          ],
        );
      },
    );
  }

  Future<int> saveMaterial() async {
    if(_materialNameController.text.isEmpty){
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message:
          "Material name cannot be empty.",
          textAlign: TextAlign.left,
        ),
      );
      return -1;
    }
    setState(() {
      isLoading = true;
    });

    if (pickedFile != null) {
      String filePath = pickedFile!.files.single.path!;

      try {
        String uploadResult = await apiService.uploadCourseMaterial(
            _materialNameController.text,
            courseDTO.id!,
            filePath
        );

        setState(() {
          isLoading = false;
        });

        if (uploadResult != "-1") {
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(
              message: "Success!",
              textAlign: TextAlign.left,
            ),
          );
        } else {

          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
              message: "Unexpected error.",
              textAlign: TextAlign.left,
            ),
          );
        }
      } catch (e) {
        print(e.toString());
        setState(() {
          isLoading = false;
        });
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "Unexpected error. Please contact system administrator.",
            textAlign: TextAlign.left,
          ),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "No file selected.",
          textAlign: TextAlign.left,
        ),
      );
    }

    fetchCourse();
    return 1;
  }
  Future<int> saveCourseStudentExcel() async {
    setState(() {
      isLoading = true;
    });

    if (pickedFile != null) {
      String filePath = pickedFile!.files.single.path!;

      try {
        String uploadResult = await apiService.uploadCourseStudentExcel(
            courseDTO.id!,
            filePath
        );

        setState(() {
          isLoading = false;
        });

        if (uploadResult != "-1") {
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(
              message: "Success!",
              textAlign: TextAlign.left,
            ),
          );
        } else {

          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
              message: "Unexpected error.",
              textAlign: TextAlign.left,
            ),
          );
        }
      } catch (e) {
        print(e.toString());
        setState(() {
          isLoading = false;
        });
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "Unexpected error. Please contact system administrator.",
            textAlign: TextAlign.left,
          ),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "No file selected.",
          textAlign: TextAlign.left,
        ),
      );
    }

    fetchCourse();
    return 1;
  }

  void _showRemoveMaterialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Remove Material"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Select a material to remove:"),
                  DropdownButton<int>(
                    value: courseDTO.courseMaterialDTOList!.first.id,
                    onChanged: (int? newValue) {
                      setState(() {
                        currentSelectedMaterialId = newValue;
                      });
                    },
                    items: courseDTO.courseMaterialDTOList!.map((material) {
                      return DropdownMenuItem<int>(
                        value: material.id,
                        child: Text(material.name!),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async{
                    if (currentSelectedMaterialId != null) {
                      String result = await apiService.deleteCourseMaterial(currentSelectedMaterialId!);
                      Navigator.of(context).pop();
                      if (result == "S") {

                        fetchCourse();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Material deleted successfully")));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete material")));
                      }
                    }
                  },
                  child: Text("Remove"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _finishTerm(BuildContext context) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure you want to finish the term? All students will be removed."),
          actions: [
            TextButton(
                onPressed: () async{
                  await apiService.finishCourseTerm(courseDTO.id!);
                  Navigator.of(context).pop();
                  fetchCourse();
                },
                child: Text("Yes")
            ),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("No")
            ),
          ],
        );
      },
    );
  }

  void _deleteCourse(BuildContext context) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure you want to delete this course?"),
          actions: [
            TextButton(
                onPressed: () async {
                  Object a = await apiService.deleteCourse(courseDTO.id!);
                  if(a=='S' ||a == 's'){
                    Navigator.of(context).pop();
                    Navigator.of(context).pop("reload");

                  }
                },
                child: Text("Yes")
            ),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("No")
            ),
          ],
        );
      },
    );
  }

  void fetchCourse() async{
    CourseDTO courseDTO2 = await apiService.getCourseByIdForLecturer(widget.courseId);
    setState(()  {
      courseDTO = courseDTO2 ;
    });

  }
  @override
  void initState() {
    super.initState();
    fetchCourse();
    setState(() {});
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }



  @override
  Widget build(BuildContext context) {
    int numberOfStudents = courseDTO.courseStudentDTOList?.length ?? 0;
    int numberOfMaterials = courseDTO.courseMaterialDTOList?.length ?? 0;
    return Scaffold(
        key: _scaffoldKey,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Constants.mainRedColor,
          title: Text('Course Details',style: TextStyle(color: Constants.whiteColor),),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Constants.whiteColor),
            onPressed: () {
              Navigator.pop(context,"reload");
            },
          ),
        ),
      body: ListView(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      courseDTO.name ?? 'N/A',
                      style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Text(
                    "Total Students: $numberOfStudents",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Text(
                    "Total Material: $numberOfMaterials",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 100,height: 100),
          Divider(height: 8, color: Colors.black),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if(courseDTO.courseStudentDTOList!.isNotEmpty!)
                  MaterialButton(
                    onPressed: () => _showRemoveStudentDialog(context),
                    color: Constants.mainRedColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(16),

                    child: Text(
                      "Remove Student",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    minWidth: (MediaQuery.of(context).size.width/2)-10,
                    textColor: Color(0xffffffff),
                  ),
                MaterialButton(
                  onPressed: () => _showAddStudentDialog(context),
                  color: Constants.mainRedColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(16),

                  child: Text(
                    "Add Student",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  textColor: Color(0xffffffff),
                  minWidth: courseDTO.courseStudentDTOList!.isNotEmpty? ((MediaQuery.of(context).size.width/2)-10):MediaQuery.of(context).size.width-5,

                ),
              ],
            ),
          ),
          Divider(height: 8, color: Colors.black),
          Padding(padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MaterialButton(
                onPressed: () => _showAddStudentBulkDialog(context),
                color: Constants.mainRedColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.all(16),

                child: Text(
                  "Bulk Add Student",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                textColor: Color(0xffffffff),
                minWidth: MediaQuery.of(context).size.width-5,

              ),
            ],
          ),),
          Divider(height: 8, color: Colors.black),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if(courseDTO.courseMaterialDTOList!.isNotEmpty)
                  MaterialButton(
                    onPressed: () => _showRemoveMaterialDialog(context),
                    color: Constants.mainRedColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(16),

                    child: Text(
                      "Remove Material",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    minWidth: (MediaQuery.of(context).size.width/2)-10,

                    textColor: Color(0xffffffff),
                  ),
                MaterialButton(
                  onPressed: () => _showAddMaterialDialog(context),
                  color: Constants.mainRedColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Add Material",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  minWidth: courseDTO.courseMaterialDTOList!.isNotEmpty? ((MediaQuery.of(context).size.width/2)-10):MediaQuery.of(context).size.width-5,

                  textColor: Color(0xffffffff),
                ),
              ],
            ),
          ),
          Divider(height: 8, color: Colors.black),

          Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  onPressed: () => _finishTerm(context),
                  color: Constants.mainRedColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(16),

                  child: Text(
                    "Finish Course",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  minWidth: MediaQuery.of(context).size.width-5,
                  textColor: Color(0xfffffffff),
                ),
              ],
            ),
          ),

          Divider(height: 8, color: Colors.black),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  onPressed: () => _deleteCourse(context),
                  color: Constants.mainRedColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(16),

                  child: Text(
                    "Delete Course",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  minWidth: MediaQuery.of(context).size.width-5,

                  textColor: Color(0xffffffff),
                ),
              ],
            ),
          ),

          Divider(height: 8, color: Colors.black),
        ],
      ),
    );
  }
}

void dissmissed() {}
