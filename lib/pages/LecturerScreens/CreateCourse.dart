import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mlmui/components/MenuDrawerLibrarian.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../service/ApiService.dart';
import '../../service/constants.dart';


class CreateCourse extends StatefulWidget{
  const CreateCourse({Key? key}) : super(key: key);

  @override
  State<CreateCourse> createState() => _CreateCourse();
}

class _CreateCourse extends State<CreateCourse>{
  final controller = MultiImagePickerController(
    maxImages: 1,
    allowedImageTypes: ['png', 'jpg', 'jpeg', 'heic', 'HEIIC'],
    withData: true,
    withReadStream: true,
    images: <ImageFile>[],
  );

  late File selectedImage;
  late Uint8List? image;
  String _base64Image = "-1";

  TextEditingController _nameController = TextEditingController();
  late String _selectedChoice;
  List<String> _dropdownitems = ["Yes","No"];
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  late bool _choice;

  void saveCourse() async{
    setState(() {
      isLoading = true;
    });
    int value;
    print(_base64Image);
    if(_base64Image != null && _base64Image != "-1"){
      value = await apiService.uploadImageByBase64(_base64Image);
    }else{
      value = await apiService.uploadImage(controller.images.first);
    }
    print(value);
    print("BURADA");
    if(value == -1){
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.info(
          message:  "Image did not uploaded. Please upload image again. ",
          textAlign: TextAlign.left,
        ),
      );
    }else{
      Map<String, dynamic> request = {
        "imageId": value,
        "isPublic": _choice,
        "name": _nameController.text,
      };
      try{
        String result = await apiService.createCourse(request);
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
  }

  @override
  void initState(){
    super.initState();
    _selectedChoice = _dropdownitems.first;
    if(_selectedChoice == "Yes"){
      _choice = true;
    }else{
      _choice = false;
    }
    setState(() {

    });
  }
  @override
  void dispose(){
    super.dispose();
  }

  int currentStep = 0;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuDrawerLibrarian(),
      appBar: AppBar(
        backgroundColor: Constants.mainRedColor,
        title: Text('Create a course',style: TextStyle(color: Constants.whiteColor),),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Constants.whiteColor,),
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
                  saveCourse();
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
              color: Constants.mainDarkColor.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
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


    AlertDialog alert = AlertDialog(
      content: Text(
          "You will lose the information you entered on the screen. Do you want to exit the book creation process?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );


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
        title: Text("Course Code"),
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
              labelText: "Course Code",
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
              Icon(Icons.numbers, color: Constants.mainDarkColor, size: 18),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: MaterialButton(
              onPressed: () {
                if (_nameController.text == "" ||
                    _nameController.text.isEmpty) {
                  showTopSnackBar(
                    Overlay.of(context),
                    CustomSnackBar.error(
                      message: "Please enter Course code.",
                      textAlign: TextAlign.left,
                    ),
                  );
                }
              },
            ),
          )
        ]
        )
    ),
    Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: Text("Make the course public"),
        content: Column(children: <Widget>[
          DropdownButtonFormField<String>(
            value: _selectedChoice,
            items: _dropdownitems.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  "Public: ${value} ",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Constants.mainDarkColor,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedChoice = newValue!;
              });
            },
            decoration: InputDecoration(
              disabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: Constants.mainDarkColor,
                  width: 1,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: Constants.mainDarkColor,
                  width: 1,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: Constants.mainDarkColor,
                  width: 1,
                ),
              ),
              labelText: "Please select your choice",
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                color: Constants.mainDarkColor,
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
                color: Constants.mainDarkColor,
                size: 18,
              ),
            ),
          ),
        ]
      ),
    ),

    Step(
        state: currentStep > 3 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 3,
        title: Text("Course Image"),
        content: Column(children: <Widget>[
          if(_base64Image != "-1")
            Text("If you want to change image, please add new one. If not, do not upload new image."),
          if(_base64Image != "-1")
            Image.memory(
              base64Decode(_base64Image),
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          MultiImagePickerView(
            controller: controller,
            padding: const EdgeInsets.all(10),
          ),

        ]))
  ];

}

void dissmissed(){}