import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'package:mlmui/models/BookCategoryEnumDTO.dart';
import 'package:mlmui/models/BookCategoryEnumDTOListResponse.dart';
import 'package:mlmui/models/RoomDTO.dart';
import 'package:mlmui/models/ShelfDTO.dart';
import 'package:mlmui/models/ShelfDTOListResponse.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../models/OpenLibraryBookDetails.dart';
import '../../service/ApiService.dart';
import 'package:mlmui/components/BookCard.dart';
import 'dart:convert';
import 'package:mlmui/service/constants.dart';

import 'package:http/http.dart' as http;
class RoomDetailPage extends StatefulWidget {
  final RoomDTO roomDTO;
  const RoomDetailPage({Key? key, required this.roomDTO}) : super(key: key);

  @override
  State<RoomDetailPage> createState() => _RoomDetailPage();
}

class _RoomDetailPage extends State<RoomDetailPage> {
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

  Future<void> _fetchImage(RoomDTO currentRoom) async {
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
  }
  static Future<String> getImageBase64(int? imageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString(imageId.toString());

    if (base64Image != null) {
      return base64Image;
    } else {
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
  void setImagePicker(BookDTO currentbook) async{
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
  }

  @override
  void initState() {
    super.initState();

    fetchInfos();
    setState(() {});
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchInfos();
  }

  void fetchInfos(){
      nameController.text=widget.roomDTO.name!;
      if(widget.roomDTO.nfc_no != null){

        nfcController.text=widget.roomDTO.nfc_no!;
      }else{
        nfcController.text="PLEASE SCAN NFC CARDdddd";

      }
      setState(() {
        defaultImg = widget.roomDTO.imageId!;
      });
      _fetchImage(widget.roomDTO);
  }

  Future<String> fetchImageBase64(int imageId) async {
    return BookCard.getImageBase64(imageId);
  }

  Future<Uint8List?> fetchImageData(int imageId) async {
    String base64String = await fetchImageBase64(imageId);
    return base64Decode(base64String);
  }



  int currentStep = 0;
  @override
  Widget build(BuildContext context) {




    return Scaffold(
        key: _scaffoldKey,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Constants.mainRedColor,
          title: Text('Room Details',style: TextStyle(color: Constants.whiteColor),),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Constants.whiteColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(primary: Constants.mainRedColor)),
              child: Stepper(
                physics: ClampingScrollPhysics(),
                onStepTapped: (step) => setState(() => currentStep = step),
                type: StepperType.vertical,
                steps: getsteps(),
                currentStep: currentStep,
                onStepContinue: () {
                  final isLastStep = currentStep == getsteps().length - 1;
                  if (isLastStep) {
                    // saveBook();
                  } else {
                    setState(() {
                      currentStep++;
                    });
                  }
                },
                onStepCancel: () {
                  final isFirstStep = currentStep == 0;
                  if (isFirstStep) {
                    // showAlertDialog(context);
                  } else {
                    setState(() {
                      currentStep -= 1;
                    });
                  }
                },
                controlsBuilder: (BuildContext context, ControlsDetails controls) {
                  return Container(
                      margin: EdgeInsets.only(top: 1),
                      child: Row(
                        children: [

                        ],
                      ));
                },
              ),
            ),

          ],
        ));
  }

  List<Step> getsteps() => [
    Step(
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 0,
        title: Text("General Info"),
      subtitle:Text("You can update it."),
        content: Column(children: <Widget>[
          TextField(
            controller: nameController,
            obscureText: false,
            textAlign: TextAlign.start,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 14,
              color: Constants.mainDarkColor,
            ),
            decoration: InputDecoration(
              disabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
              ),
              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
              ),
              labelText: "Name of the Room",
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                color: Constants.mainDarkColor,
              ),
              filled: true,
              fillColor: Color(0x00ffffff),
              isDense: false,
              contentPadding:
              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              prefixIcon:
              Icon(Icons.text_fields, color: Constants.mainDarkColor, size: 18),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: MaterialButton(
              onPressed: () {

              },
              color: Constants.mainDarkColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.all(8),
              child: Text(
                "Update!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                ),
              ),
              textColor: Color(0xffffffff),
              height: 10,
            ),
          )
        ])), //ISBN

    Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: Text("QR Code for Verification"),
        content: Column(children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment:MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  onPressed: () {

                  },
                  color: Constants.mainDarkColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Download It!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  textColor: Color(0xffffffff),
                  height: 10,
                ),
                MaterialButton(
                  onPressed: () {

                  },
                  color: Constants.mainRedColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Renew It!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  textColor: Color(0xffffffff),
                  height: 10,
                ),
              ],
            ),
          ),

        ])), // Name, Desc, Publisher, Author, Publish Date

    Step(
        state: currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 2,
        title: Text("NFC Card for Verification"),
        content: Column(children: <Widget>[
          TextField(
            readOnly: true,
            controller: nfcController,
            obscureText: false,
            textAlign: TextAlign.start,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 14,
              color: Constants.mainDarkColor,
            ),
            decoration: InputDecoration(
              disabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
              ),
              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
              ),
              labelText: "NFC Code",
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                color: Constants.mainDarkColor,
              ),
              filled: true,
              fillColor: Color(0x00ffffff),
              isDense: false,
              contentPadding:
              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              prefixIcon:
              Icon(Icons.text_fields, color: Constants.mainDarkColor, size: 18),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: MaterialButton(
              onPressed: () async {
                bool isAvailable = await NfcManager.instance.isAvailable();
                print(isAvailable);
                NfcManager.instance.startSession(
                  onDiscovered: (NfcTag tag) async {
                    Ndef? ndef = Ndef.from(tag);

                    if (ndef != null && ndef.cachedMessage != null) {
                      String tempRecord = "";
                      for (var record in ndef.cachedMessage!.records) {
                        tempRecord =
                        "$tempRecord ${String.fromCharCodes(record.payload.sublist(record.payload[0] + 1))}";
                      }

                      setState(() {
                        nfcController.text = tempRecord;
                      });
                    } else {
                      // Show a snackbar for example
                    }
                  },
                );

              },
              color: Constants.mainDarkColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.all(8),
              child: Text(
                "Scan new NFC Tag",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                ),
              ),
              textColor: Color(0xffffffff),
              height: 10,
            ),
          ),
        ])), // Shelf, Image

    Step(
        state: currentStep > 3 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 3,
        title: Text("Image"),
        content: Column(children: <Widget>[
          // if(_base64Image != "-1")
          //   Text("If you want to change image, please add new one. If not, do not upload new image."),
          // if(_base64Image != "-1")
          //   Image.memory(
          //     base64Decode(_base64Image),
          //     width: 150,
          //     height: 150,
          //     fit: BoxFit.cover,
          //   ),
          MultiImagePickerView(
            controller: controller,
            padding: const EdgeInsets.all(10),
          ),

        ]))
  ];
}

void dissmissed() {}
