import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'package:mlmui/models/BookCategoryEnumDTO.dart';
import 'package:mlmui/models/BookCategoryEnumDTOListResponse.dart';
import 'package:mlmui/models/ShelfDTO.dart';
import 'package:mlmui/models/ShelfDTOListResponse.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../models/OpenLibraryBookDetails.dart';
import '../../service/ApiService.dart';
import 'package:mlmui/components/BookCard.dart';
import 'dart:convert';
import 'package:mlmui/service/constants.dart';




class UpdateBookPage extends StatefulWidget {
  const UpdateBookPage({Key? key}) : super(key: key);

  @override
  State<UpdateBookPage> createState() => _UpdateBookPage();
}

class _UpdateBookPage extends State<UpdateBookPage> {
  final controller = MultiImagePickerController(
      maxImages: 1,
      allowedImageTypes: ['png', 'jpg', 'jpeg'],
      withData: true,
      withReadStream: true,
      images: <ImageFile>[], // array of pre/default selected images
  );
  late File selectedImage;

  late Uint8List? image;


  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _publisherController;
  late TextEditingController _authorController;
  late TextEditingController _dateController;
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ShelfDTO> _dropdownItems = [];
  List<BookCategoryEnumDTO> _dropdownItems2 = [];

  ShelfDTO _selectedValue = new ShelfDTO(-1, "-1");
  BookCategoryEnumDTO _selectedValue2 = new BookCategoryEnumDTO("-1", "-1");

  void updateBook() async {
    int value = await apiService.uploadImage(controller.images.first);
    if(value == -1){
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.info(
          message:
          "Image did not uploaded. Please upload image again. ",
          textAlign: TextAlign.left,
        ),
      );
    }else{
      Map<String, dynamic> request = {
        "shelfId":_selectedValue.id,
        "imageId":value,
        "publisher":_publisherController.text,
        "name":_nameController.text,
        "description":_descController.text,
        "author":_authorController.text,
        "category":_selectedValue2.enumValue


      };
      try{

        String result = await apiService.updateBook(request);
        if(result == "S"){
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(
              message:
              "Nice",
              textAlign: TextAlign.left,
            ),
          );
        }else{
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
              message:
              ":((((",
              textAlign: TextAlign.left,
            ),
          );
        }

      }catch (e){

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
  }

  void fetchShelfs() async {
    try {
      ShelfDTOListResponse response =
      await apiService.getShelfDTOListResponse();
      setState(() {
        _dropdownItems.addAll(response.shelfDTOList);
        _selectedValue = _dropdownItems.first;
      });
    } catch (e) {
      print("Error! $e");
    }
  }

  void fetchCategories() async {
    try {
      BookCategoryEnumDTOListResponse response =
      await apiService.getBookCategoryEnumDTOListResponse();
      setState(() {
        _dropdownItems2.addAll(response.list);
        _selectedValue2 = _dropdownItems2.first;
      });
    } catch (e) {
      print("Error! $e");
    }
  }

  //todo catchSelfbyId() curretn book geldi buldu selectvalueya atandi.
  //todo catchCategory()

  @override
  void initState() {
    super.initState();
    setState(() {});
    fetchShelfs();
    fetchCategories();
  }

  Future<String> fetchImageBase64(int imageId) async {
    return BookCard.getImageBase64(imageId);
  }

  Future<Uint8List?> fetchImageData(int imageId) async {
    String base64String = await fetchImageBase64(imageId);
    return base64Decode(base64String);
  }






  @override
  void dispose() {
    super.dispose();
  }

  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final currentbook = args['currentbook'] as BookDTO;

    _nameController = TextEditingController(text: currentbook.name);
    _descController = TextEditingController(text: currentbook.description);
    _publisherController = TextEditingController(text: currentbook.publisher);
    _authorController = TextEditingController(text: currentbook.author);
    _dateController = TextEditingController(text: currentbook.publicationDateStr);
    _selectedValue.id = currentbook.shelfId!;
    //We can create a function that catch the current information for dropdown items
    //with using currentbook.shelfId and others but right now this is enough.
    _selectedValue2.str = currentbook.categoryStr!;
    //print(_selectedValue.id);
    //print(_selectedValue2.str);

    image = fetchImageData(currentbook.imageId!) as Uint8List?;
    final ImageFile imageData = ImageFile(
      'image',
      name: 'image',
      extension: 'png',
      bytes: image,
    );

    return Scaffold(
        key: _scaffoldKey,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Color(0xffd2232a),
          title: Text('Update Book Page'),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Theme(
          data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(primary: Color(0xffd2232a))),
          child: Stepper(
            physics: ClampingScrollPhysics(),
            onStepTapped: (step) => setState(() => currentStep = step),
            type: StepperType.vertical,
            steps: getsteps(),
            currentStep: currentStep,
            onStepContinue: () {
              final isLastStep = currentStep == getsteps().length - 1;
              if (isLastStep) {
                updateBook();
              } else {
                setState(() {
                  currentStep++;
                });
              }
            },
            onStepCancel: () {
              final isFirstStep = currentStep == 0;
              if (isFirstStep) {
                showAlertDialog(context);
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
                      if (currentStep == 0)
                        Expanded(
                          child: ElevatedButton(
                            child: Text("Cancel"),
                            onPressed: controls.onStepCancel,
                          ),
                        )
                      else
                        Expanded(
                          child: ElevatedButton(
                            child: Text("Back"),
                            onPressed: controls.onStepCancel,
                          ),
                        ),
                      const SizedBox(
                        width: 12,
                      ),
                      if (currentStep != getsteps().length - 1)
                        Expanded(
                          child: ElevatedButton(
                            child: Text("Continue"),
                            onPressed: controls.onStepContinue,
                          ),
                        )
                      else
                        Expanded(
                          child: ElevatedButton(
                            child: Text("Update"),
                            onPressed: controls.onStepContinue,
                          ),
                        ),
                      const SizedBox(
                        width: 12,
                      ),
                    ],
                  ));
            },
          ),
        )
    );
  }
  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Continue the process"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Exit"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(
          "You will lose the information you entered on the screen. Do you want to exit the book creation process?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  List<Step> getsteps() => [
    Step(
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 0,
        title: Text("General Informations"),
        content: Column(children: <Widget>[
          TextField(
            controller: _nameController,
            obscureText: false,
            textAlign: TextAlign.start,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 14,
              color: Color(0xff000000),
            ),
            decoration: InputDecoration(
              disabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              labelText: "Name",
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                color: Color(0xff000000),
              ),
              filled: true,
              fillColor: Color(0x00ffffff),
              isDense: false,
              contentPadding:
              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              prefixIcon:
              Icon(Icons.book, color: Color(0xff212435), size: 18),
            ),
          ),
          TextField(
            controller: _descController,
            obscureText: false,
            textAlign: TextAlign.start,
            maxLines: 4,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 14,
              color: Color(0xff000000),
            ),
            decoration: InputDecoration(
              disabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              labelText: "Description",
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                color: Color(0xff000000),
              ),
              filled: true,
              fillColor: Color(0x00ffffff),
              isDense: false,
              contentPadding:
              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              prefixIcon:
              Icon(Icons.book, color: Color(0xff212435), size: 18),
            ),
          ),
          TextField(
            controller: _publisherController,
            obscureText: false,
            textAlign: TextAlign.start,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 14,
              color: Color(0xff000000),
            ),
            decoration: InputDecoration(
              disabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              labelText: "Publisher",
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                color: Color(0xff000000),
              ),
              filled: true,
              fillColor: Color(0x00ffffff),
              isDense: false,
              contentPadding:
              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              prefixIcon:
              Icon(Icons.publish, color: Color(0xff212435), size: 18),
            ),
          ),
          TextField(
            controller: _authorController,
            obscureText: false,
            textAlign: TextAlign.start,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 14,
              color: Color(0xff000000),
            ),
            decoration: InputDecoration(
              disabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              labelText: "Author",
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                color: Color(0xff000000),
              ),
              filled: true,
              fillColor: Color(0x00ffffff),
              isDense: false,
              contentPadding:
              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              prefixIcon:
              Icon(Icons.person, color: Color(0xff212435), size: 18),
            ),
          ),
          TextField(
            controller: _dateController,
            obscureText: false,
            textAlign: TextAlign.start,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 14,
              color: Color(0xff000000),
            ),
            decoration: InputDecoration(
              disabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Color(0xff000000), width: 1),
              ),
              labelText: "Publish Date",
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                color: Color(0xff000000),
              ),
              filled: true,
              fillColor: Color(0x00ffffff),
              isDense: false,
              contentPadding:
              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              prefixIcon: Icon(Icons.date_range,
                  color: Color(0xff212435), size: 18),
            ),
          )
        ])), // Name, Desc, Publisher, Author, Publish Date

    Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: Text("Shelf and Image"),
        content: Column(children: <Widget>[
          DropdownButtonFormField<ShelfDTO>(
            value: _selectedValue,
            items: _dropdownItems.map((ShelfDTO value) {
              return DropdownMenuItem<ShelfDTO>(
                value: value,
                child: Text(
                  "ID: ${value.id} -- Floor: ${value.floor} ",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0xff000000),
                  ),
                ),
              );
            }).toList(),
            onChanged: (ShelfDTO? newValue) {
              setState(() {
                _selectedValue = newValue ?? _selectedValue;
              });
            },
            decoration: InputDecoration(
              disabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: Color(0xff000000),
                  width: 1,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: Color(0xff000000),
                  width: 1,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: Color(0xff000000),
                  width: 1,
                ),
              ),
              labelText: "Please select a shelf",
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                color: Color(0xff000000),
              ),
              filled: true,
              fillColor: Color(0x00ffffff),
              isDense: false,
              contentPadding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              prefixIcon: Icon(
                Icons.arrow_drop_down,
                color: Color(0xff212435),
                size: 18,
              ),
            ),
          ),
          DropdownButtonFormField<BookCategoryEnumDTO>(
            value: _selectedValue2,
            items: _dropdownItems2.map((BookCategoryEnumDTO value) {
              return DropdownMenuItem<BookCategoryEnumDTO>(
                value: value,
                child: Text(
                  "${value.str} ",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0xff000000),
                  ),
                ),
              );
            }).toList(),
            onChanged: (BookCategoryEnumDTO? newValue) {
              setState(() {
                _selectedValue2 = newValue!;
              });
            },
            decoration: InputDecoration(
              disabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: Color(0xff000000),
                  width: 1,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: Color(0xff000000),
                  width: 1,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: Color(0xff000000),
                  width: 1,
                ),
              ),
              labelText: "Please select a category",
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                color: Color(0xff000000),
              ),
              filled: true,
              fillColor: Color(0x00ffffff),
              isDense: false,
              contentPadding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              prefixIcon: Icon(
                Icons.arrow_drop_down,
                color: Color(0xff212435),
                size: 18,
              ),
            ),
          ),
          MultiImagePickerView(
            controller: controller,
            padding: const EdgeInsets.all(10),
          ),
        ]
      )
    ),
  ];
}

void dissmissed() {}
