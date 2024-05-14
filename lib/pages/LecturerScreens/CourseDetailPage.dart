import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
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
  final CourseDTO courseDTO;
  const CourseDetailPage({Key? key, required this.courseDTO}) : super(key: key);

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
                  value: selectedStudentId,
                  hint: Text("Select a student"),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedStudentId = newValue;
                      var selectedStudent = widget.courseDTO.courseStudentDTOList?.firstWhere(
                              (s) => s.id == newValue
                      );
                      if (selectedStudent != null) {
                        _studentIdController.text = selectedStudent.studentNumber ?? "";
                      } else {
                        _studentIdController.text = "";
                      }
                    });
                  },
                  items: widget.courseDTO.courseStudentDTOList?.map((student) {
                    return DropdownMenuItem<int>(
                      value: student.id,
                      child: Text("${student.studentName} (${student.studentNumber})"),
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
      String result = await apiService.removeStudentFromCourse(widget.courseDTO.id!, studentId);
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
                  _studentIdController.clear();
                  Navigator.of(context).pop();
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
      "courseId": widget.courseDTO.id,
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
                    allowedExtensions: ['pdf', 'epub'],
                  );
                  if (pickedFile != null) {
                    print("File selected: ${pickedFile?.files.single.name}");
                  }
                },
                child: Text("Select PDF/EPUB"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  saveMaterial();
                  _materialNameController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("Add")
            ),
            TextButton(
                onPressed: () {
                  _materialNameController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("Cancel")
            ),
          ],
        );
      },
    );
  }

  void saveMaterial() async {
    setState(() {
      isLoading = true;
    });

    if (pickedFile != null) {
      String filePath = pickedFile!.files.single.path!;

      try {
        String uploadResult = await apiService.uploadCourseMaterial(
            name!,
            widget.courseDTO.id!,
            filePath
        );

        setState(() {
          isLoading = false;
        });

        if (uploadResult == "S") {
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(
              message: "Success!",
              textAlign: TextAlign.left,
            ),
          );
          Navigator.pop(context, "s");
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
                    value: currentSelectedMaterialId,
                    onChanged: (int? newValue) {
                      setState(() {
                        currentSelectedMaterialId = newValue;
                      });
                    },
                    items: widget.courseDTO.courseMaterialDTOList!.map((material) {
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
                  await apiService.finishCourseTerm(widget.courseDTO.id!);
                  Navigator.of(context).pop();
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
                onPressed: () {
                  Navigator.of(context).pop();
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

  @override
  void initState() {
    super.initState();

    setState(() {});
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }



  @override
  Widget build(BuildContext context) {
    int numberOfStudents = widget.courseDTO.courseStudentDTOList?.length ?? 0;
    int numberOfMaterials = widget.courseDTO.courseMaterialDTOList?.length ?? 0;
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
                      widget.courseDTO.name ?? 'N/A',
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
            padding: const EdgeInsets.fromLTRB(0,10,0,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showRemoveStudentDialog(context),
                  child: Text("Remove Student"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    minimumSize: Size(150, 50),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showAddStudentDialog(context),
                  child: Text("Add Student"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: Size(150, 50),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 8, color: Colors.black),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,10,20,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showRemoveMaterialDialog(context),
                      child: Text('Remove Material'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: Size(150, 50),
                      ),
                    ),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20,10,0,10),
                  child:ElevatedButton(
                    onPressed: () => _showAddMaterialDialog(context),
                    child: Text("Add Material"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: Size(150, 50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 8, color: Colors.black),
          Row(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: () => _deleteCourse(context),
                    child: Text("Delete Course"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: Size(411, 50),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: () => _finishTerm(context),
                    child: Text("Finish Term"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: Size(411, 50),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => Navigator.pushNamed(context, '/editCoursePage'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void dissmissed() {}
