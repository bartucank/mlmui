import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlmui/models/BookCategoryEnumDTO.dart';
import 'package:mlmui/models/BookCategoryEnumDTOListResponse.dart';
import 'package:mlmui/models/ShelfDTO.dart';
import 'package:mlmui/models/ShelfDTOListResponse.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../models/OpenLibraryBookDetails.dart';
import '../../service/ApiService.dart';
import '../../service/constants.dart';

class BookCreateByExcelPage extends StatefulWidget {
  const BookCreateByExcelPage({Key? key}) : super(key: key);

  @override
  State<BookCreateByExcelPage> createState() => _BookCreateByExcelPageState();
}

class _BookCreateByExcelPageState extends State<BookCreateByExcelPage> {
  final controller = MultiImagePickerController(
      maxImages: 1,
      allowedImageTypes: ['png', 'jpg', 'jpeg', 'heic', 'HEIC'],
      withData: true,
      withReadStream: true,
      images: <ImageFile>[] // array of pre/default selected images
      );
  late File selectedImage;
  String _base64Image = "-1";

  TextEditingController _nameController = TextEditingController();
  TextEditingController _isbnController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _publisherController = TextEditingController();
  TextEditingController _authorController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<OpenLibraryBookDetails> openLibrary;
  List<ShelfDTO> _dropdownItems = [];
  List<BookCategoryEnumDTO> _dropdownItems2 = [];
  bool isLoading = false;





  Future<String> downloadExcel() async {
    try {
      final Uri _url = Uri.parse("${Constants.apiBaseUrl}/api/admin/getExcel");
      if (!await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
      }
    } catch (e) {

    }
    return "1";
  }



  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Constants.mainRedColor,
          title: Text(
            'Upload Books',
            style: TextStyle(color: Constants.whiteColor),
          ),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Constants.whiteColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                  colorScheme:
                      ColorScheme.light(primary: Constants.mainRedColor)),
              child: Stepper(
                physics: ClampingScrollPhysics(),
                onStepTapped: (step) => setState(() => currentStep = step),
                type: StepperType.vertical,
                steps: getsteps(),
                currentStep: currentStep,

                controlsBuilder:
                    (BuildContext context, ControlsDetails controls) {
                  return Container(
                      margin: EdgeInsets.only(top: 1),
                      child: Row(
                        children: [


                        ],
                      ));
                },
              ),
            ),
            if (isLoading)
              Container(
                color: Constants.mainDarkColor.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ));
  }


  List<Step> getsteps() => [
        Step(
            state: currentStep > 0 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 0,
            title: Text("Download Template"),
            subtitle: Text("You have to use template.",style: TextStyle(color: Constants.mainRedColor),),
            content: Column(children: <Widget>[
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                    "You will find instructions on the columns."),
              ),
              MaterialButton(
                  onPressed: () async {
                    Object a = await downloadExcel();
                  },
                  color: Constants.mainRedColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minWidth:MediaQuery.of(context).size.width-(MediaQuery.of(context).size.width/3),
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Download",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  textColor: Color(0xffffffff),
                  height: 15,
                ),

            ])),
        Step(
            state: currentStep > 3 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 3,
            title: Text("Upload Excel File"),
            content: Column(children: <Widget>[
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                    "Please fill the Excel file and upload again."),
              ),
              MaterialButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['xlsx'],
                    allowMultiple: false
                  );

                  if(result == null){
                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.error(
                        message:
                        "The Excel file cannot be uploaded. Please try again.",
                        textAlign: TextAlign.left,
                      ),
                    );
                  }else{
                    if(kIsWeb){
                      Object flag = await apiService.uploadExcelForBookForWeb(result.files.first.bytes!);
                      print(flag);
                      if(flag == "0"){
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.error(
                            message:
                            "There is no valid row :(",
                            textAlign: TextAlign.left,
                          ),
                        );
                      }else if(flag == "-1"){
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.error(
                            message:
                            "Something happened :(",
                            textAlign: TextAlign.left,
                          ),
                        );
                      }else{
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.success(
                            message:
                            "Valid rows created!",
                            textAlign: TextAlign.left,
                          ),
                        );
                        Navigator.pop(context,"s");
                      }
                    }else{
                      File file = File(result!.files.single.path!);
                      Object flag = await apiService.uploadExcelForBook(file);
                      print(flag);
                      if(flag == "0"){
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.error(
                            message:
                            "There is no valid row :(",
                            textAlign: TextAlign.left,
                          ),
                        );
                      }else if(flag == "-1"){
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.error(
                            message:
                            "Something happened :(",
                            textAlign: TextAlign.left,
                          ),
                        );
                      }else{
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.success(
                            message:
                            "Valid rows created!",
                            textAlign: TextAlign.left,
                          ),
                        );
                        Navigator.pop(context,"s");
                      }
                    }

                  }
                },
                color: Constants.mainDarkColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                minWidth:MediaQuery.of(context).size.width-(MediaQuery.of(context).size.width/3),
                child: Text(
                  "Upload",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                textColor: Color(0xffffffff),
              )
            ]))
      ];
}
