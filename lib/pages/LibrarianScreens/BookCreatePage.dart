import 'dart:io';

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
import '../../components/MenuDrawerLibrarian.dart';
import '../../models/OpenLibraryBookDetails.dart';
import '../../service/ApiService.dart';

class BookCreatePage extends StatefulWidget {
  const BookCreatePage({Key? key}) : super(key: key);

  @override
  State<BookCreatePage> createState() => _BookCreatePageState();
}

class _BookCreatePageState extends State<BookCreatePage> {
  final controller = MultiImagePickerController(
      maxImages: 1,
      allowedImageTypes: ['png', 'jpg', 'jpeg'],
      withData: true,
      withReadStream: true,
      images: <ImageFile>[] // array of pre/default selected images
      );
  late File selectedImage;

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


  ShelfDTO _selectedValue = new ShelfDTO(-1, "-1");
  BookCategoryEnumDTO _selectedValue2 = new BookCategoryEnumDTO("-1", "-1");
  void saveBook() async {
    setState(() {
      isLoading = true;
    });
    int value = await apiService.uploadImage(controller.images.first);
    if(value == -1){
      setState(() {
        isLoading = false;
      });
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
        "isbn":_isbnController.text,
        "publisher":_publisherController.text,
        "name":_nameController.text,
        "description":_descController.text,
        "author":_authorController.text,
        "category":_selectedValue2.enumValue


      };
      Map<String, dynamic> request2 = {



      };
      try{

        String result = await apiService.createBook(request2);
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
            const CustomSnackBar.error(
              message:
              "Unexpected error.",
              textAlign: TextAlign.left,
            ),
          );
        }

      }catch (e){
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

  }
  void fetchByIsbn() async {

    FocusScope.of(context).unfocus();
    try {
      setState(() {
        isLoading = true;
      });
      OpenLibraryBookDetails response =
          await apiService.getOpenLibraryBookDetails(_isbnController.text);
      setState(() {
        _nameController.text = response.title!;
        _nameController.text = response.title != null ? response.title! : "";
        _descController.text =
            response.subjects != null ? response.subjects!.toString() : "";
        _publisherController.text = response.publishers!.first != null
            ? response.publishers!.first!
            : "";
        _dateController.text =
            response.publish_date != null ? response.publish_date! : "";
        _authorController.text = response.authors!.first.key != null
            ? response.authors!.first.key!
            : "";
        currentStep++;

        isLoading = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(
          message:
              "Some informations about books filled. Please fill blank areas too.",
          textAlign: TextAlign.left,
        ),
      );

    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message:
          "Book Details could not fetched. Please enter informations manually.",
          textAlign: TextAlign.left,
        ),
      );
      setState(() {
        isLoading = false;
      });
      print("Error! $e");
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

  @override
  void initState() {
    super.initState();
    setState(() {});
    fetchShelfs();
    fetchCategories();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final double _panelMinSize = 70.0;
  final double _panelMaxSize = 200;
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Color(0xffd2232a),
          title: Text('Create a book'),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            Theme(
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
                    saveBook();
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
                                child: Text("Save"),
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
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ));
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
            title: Text("ISBN"),
            content: Column(children: <Widget>[
              Align(
                alignment: Alignment.bottomLeft,
                child:
                    Text("You can click \"Fill\" button to fill whole form."),
              ),
              TextField(
                controller: _isbnController,
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
                  labelText: "ISBN number",
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
                      Icon(Icons.numbers, color: Color(0xff212435), size: 18),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: MaterialButton(
                  onPressed: () {
                    if (_isbnController.text == "" ||
                        _isbnController.text.isEmpty) {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.error(
                          message: "Please enter ISBN number.",
                          textAlign: TextAlign.left,
                        ),
                      );
                    } else {
                      fetchByIsbn();
                    }
                  },
                  color: Color(0xffd2232a),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Fill",
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
            state: currentStep > 2 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 2,
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
                    _selectedValue = newValue!;
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
              )
            ])), // Shelf, Image
      ];
}

void dissmissed() {}
