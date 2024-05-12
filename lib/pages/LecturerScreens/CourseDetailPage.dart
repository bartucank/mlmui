import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'package:mlmui/models/RoomDTO.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../models/OpenLibraryBookDetails.dart';
import '../../service/ApiService.dart';
import 'package:mlmui/components/BookCard.dart';
import 'dart:convert';
import 'package:mlmui/service/constants.dart';
import '../../models/CourseDTO.dart';

import 'package:http/http.dart' as http;
class CourseDetailPage extends StatefulWidget {
  //final CourseDTO courseDTO;
  const CourseDetailPage({Key? key, /*required this.courseDTO*/}) : super(key: key);

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


  TextEditingController nameController = TextEditingController();
  TextEditingController nfcController = TextEditingController();

  int defaultImg = 1;
  int lastIdForQr = 1;

  /*Future<void> _fetchImage(RoomDTO currentRoom) async {
    try {
      String base64Image = await getImageBase64(currentRoom.imageId);

      if (base64Image != "1") {
        setState(() {
          _base64Image = base64Image;
        });
      } else {
        print("Image not found");
      }
    } catch (error) {
      print("Error fetching image: $error");
    }
  }*/
  static Future<String> getImageBase64(int? imageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString(imageId.toString());

    if (base64Image != null) {
      return base64Image;
    } else {
      print(imageId);
      final response = await http.get(Uri.parse('${Constants.apiBaseUrl}/api/user/getImageBase64ById?id=$imageId'));

      if (response.statusCode == 200) {
        String base64 = base64Encode(response.bodyBytes);
        prefs.setString(imageId.toString(), base64);
        return base64;
      } else {
        return"1";
      }
    }
  }
  /*void setImagePicker(BookDTO currentbook) async{
    Uint8List? imageData = await fetchImageData(currentbook.imageId!);
    print(imageData);
    if (imageData != null) {
      Stream<List<int>> streamData = Stream.fromIterable([imageData.toList()]);

      final ImageFile imageFile = ImageFile(
          UniqueKey().toString(),
          name: 'image',
          extension: 'png',
          bytes: imageData,
          readStream: streamData,
          path: null
      );
      print(imageFile.toString());
      setState(() {
        // controller.addImage(imageFile);
      });
    }
  }*/

  @override
  void initState() {
    super.initState();

    //fetchInfos();
    setState(() {});
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //fetchInfos();
  }

  /*void fetchInfos(){
    nameController.text=widget.courseDTO.name!;
    if(widget.courseDTO.nfc_no != null){

      nfcController.text=widget.roomDTO.nfc_no!;
    }else{
      nfcController.text="PLEASE SCAN NFC CARDdddd";

    }
    setState(() {
      defaultImg = widget.roomDTO.imageId!;
      lastIdForQr = widget.roomDTO.qrImage!;
    });
    _fetchImage(widget.roomDTO);
  }*/

  /*Future<String> fetchImageBase64(int imageId) async {
    return BookCard.getImageBase64(imageId);
  }

  Future<Uint8List?> fetchImageData(int imageId) async {
    String base64String = await fetchImageBase64(imageId);
    return base64Decode(base64String);
  }


  Future<String> downloadQr() async {
    try {
      final Uri _url = Uri.parse("${Constants.apiBaseUrl}/api/admin/downloadImg?id=$lastIdForQr");
      if (!await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
      }
    } catch (e) {
    }
    return "1";
  }*/

  void _showRemoveStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove Student"),
          content: Text("Are you sure you want to remove this student?"),
          actions: [
            TextButton(
                onPressed: () {
                  // Add your logic here for removing a student
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Yes")
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("No")
            ),
          ],
        );
      },
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Student"),
          content: Text("Enter details for the new student."),
          actions: [
            TextButton(
                onPressed: () {
                  // Logic to add a student goes here
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Add")
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Cancel")
            ),
          ],
        );
      },
    );
  }

  void _showAddMaterialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Material"),
          content: Text("Provide details for the new material."),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  // Add your logic here for adding material
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

  void _showRemoveMaterialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove Material"),
          content: Text("Are you sure you want to remove this material?"),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  // Add your logic here for removing material
                  Navigator.of(context).pop();
                },
                child: Text("Remove")
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context). pop();
                },
                child: Text("Cancel")
            ),
          ],
        );
      },
    );
  }

  void _finishTerm(BuildContext context) {
    // Logic to finish the term
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure you want to finish the term?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Additional logic to finish term
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
    // Logic to delete the course
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure you want to delete this course?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Additional logic to delete course
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

  int currentStep = 0;

  @override
  Widget build(BuildContext context) {

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    color: Colors.white,  // Color for the entire section if needed
                    padding: EdgeInsets.fromLTRB(150, 0, 0, 0),  // Padding around the content
                    child: Text("CNG 352", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,10,100,0),
                    child: Text("Total User: 35", style: TextStyle(color: Colors.black, fontSize: 18)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,10,80,0),
                    child: Text("Total Material: 2", style: TextStyle(color: Colors.black, fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 3, color: Colors.black),  // Divider between sections
          Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showRemoveStudentDialog(context),
                  child: Text("Remove Student"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black, // Text color
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showAddStudentDialog(context),
                  child: Text("Add Student"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Button color
                    foregroundColor: Colors.white, // Text color
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 3, color: Colors.black),  // Divider between sections
          Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showAddMaterialDialog(context),
                  child: Text("Remove Material"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Button color
                    foregroundColor: Colors.white, // Text color
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showRemoveMaterialDialog(context),
                  child: Text("Add Material"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Button color
                    foregroundColor: Colors.white, // Text color
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 3, color: Colors.black),  // Divider between sections
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(50,0,30,200),
                child: ElevatedButton(
                  onPressed: () => _finishTerm(context),
                  child: Text("Delete Course"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Button color
                    foregroundColor: Colors.white, // Text color
                  ),
                ),
              ),
              SizedBox(height: 8), // Space between buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(30,0,0,200),
                child: ElevatedButton(
                  onPressed: () => _deleteCourse(context),
                  child: Text("Finish Term"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Button color
                    foregroundColor: Colors.white, // Text color
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0), // Adjust padding as needed
            child: Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => Navigator.pushNamed(context, '/editCoursePage'), // Adjust the route as necessary
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void dissmissed() {}
