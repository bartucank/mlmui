import 'dart:async';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mlmui/components/ShelfCard.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'package:mlmui/models/UserNamesDTO.dart';
import 'package:mlmui/models/UserNamesDTOListResponse.dart';
import 'package:mlmui/pages/LibrarianScreens/BookQueueDetail.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:mlmui/components/BookCard.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../models/BookCategoryEnumDTO.dart';
import '../../models/BookCategoryEnumDTOListResponse.dart';
import '../../models/BookDTOListResponse.dart';
import '../../models/ShelfDTO.dart';
import '../../service/ApiService.dart';
import 'package:we_slide/we_slide.dart';
import '../../service/constants.dart';
import 'BookDetailsPageForLibrarian.dart';
import 'package:mlmui/models/ShelfDTOListResponse.dart';

class ShelfManagementScreen extends StatefulWidget {
  const ShelfManagementScreen({Key? key}) : super(key: key);

  @override
  State<ShelfManagementScreen> createState() => _ShelfManagementScreen();
}

class _ShelfManagementScreen extends State<ShelfManagementScreen> {
  final listcontroller = ScrollController();
  WeSlideController weSlideController = WeSlideController();
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int page = -1;
  int size =kIsWeb?10:10;
  int totalSize = 0;
  int totalPage = 1000;
  List<ShelfDTO> shelfDTOList = [];
  GlobalKey<ArtDialogState> _artDialogKey = GlobalKey<ArtDialogState>();
  bool isLoading = false;
  TextEditingController _floorController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  bool _switchValue = false;
  late int newId;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();




  void fetchShelfs() async{
    try{
      ShelfDTOListResponse response =
      await apiService.getShelfDTOListResponse();
      setState(() {
        shelfDTOList.clear();
        shelfDTOList.addAll(response.shelfDTOList);
      });
    }catch(e){
      print("Error! $e");
    }
  }


  void saveShelf() async {
    if (_floorController.text.isEmpty) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Shelf Floor cannot be empty.",
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> request = {
      "floor": _floorController.text,
      "id": _idController.text,
    };
    try {
      String result = await apiService.createShelf(request);
      setState(() {
        isLoading = false;
      });
      if (result == "S") {
        refresh();
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "Success!",
          ),
        );
        Navigator.pop(context, "s");
      } else {
        refresh();
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.warning,
            title: "Unexpected error.",
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Unexpected error. Please contact system administrator.",
        ),
      );
    }
  }

  void createShelf(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Create New Shelf"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _floorController,
                  decoration: InputDecoration(
                    labelText: "Floor",
                    hintText: "Enter the Floor",
                  ),
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Create", style: TextStyle(color: Colors.black)),
              onPressed: () {
                saveShelf();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateShelfDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update Shelf"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _floorController,
                  decoration: InputDecoration(
                    labelText: "Floor",
                    hintText: "Enter the Floor",
                  ),
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Update", style: TextStyle(color: Colors.black)),
              onPressed: () {
                updateShelf();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateShelf() async {
    if (_floorController.text.isEmpty) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Shelf Floor cannot be empty.",
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> request = {
      "floor": _floorController.text,
      "id": _idController.text,
    };
    try {
      String result = await apiService.updateShelf(request);
      setState(() {
        isLoading = false;
      });
      if (result == "S") {
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "Success!",
          ),
        );
        Navigator.pop(context, "s");
      } else {
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.warning,
            title: "Unexpected error.",
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Unexpected error. Please contact system administrator.",
        ),
      );
    }
  }


  Future<void> justDelete(BuildContext context,int shelfId) async {
    ArtDialogResponse response = await ArtSweetAlert.show(
        barrierDismissible: false,
        context: context,
        artDialogArgs: ArtDialogArgs(
            denyButtonText: "Cancel",
            title: "Are you sure?",
            text: "You won't be able to revert this!",
            confirmButtonText: "Yes",
            type: ArtSweetAlertType.warning
        )
    );

    if(response==null) {
      return;
    }

    if(response.isTapConfirmButton) {
      String result =  await apiService.deleteShelf(shelfId);
      print(result);
      if (result == "S") {
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "Shelf Deleted!"
            )
        );
        fetchShelfs();
      } else {
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Shelf couldn't deleted :("
            )
        );
      }

      return;
    }
  }


  Future<String> moveAndDelete(BuildContext context, int currentShelfId) async {
    Completer<String> completer = Completer<String>();
    List<ShelfDTO> newShelfs = [];
    shelfDTOList.forEach((element) {
      if(element.id != currentShelfId){
        newShelfs.add(element);
      }
    });
    int selectedShelf = newShelfs.first.id;
    ArtDialogResponse response = await ArtSweetAlert.show(
        artDialogKey: _artDialogKey,
        context: context,
        artDialogArgs: ArtDialogArgs(
          barrierColor: Constants.mainBarrierColor,
          title: "Move and Delete",
          customColumns: [
            Container(
              child: Text(
                  'This shelf has some books. Please select new shelf to move these books.'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: DropdownButtonFormField<ShelfDTO>(
                value: newShelfs.first,
                onChanged: (value) {
                  setState(() {
                    selectedShelf = value!.id;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Select a shelf",
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
                  prefixIcon: Icon(Icons.person,
                      color: Constants.mainDarkColor, size: 18),
                  border: OutlineInputBorder(
                    // Add this line to define a border
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide:
                    BorderSide(color: Constants.mainDarkColor, width: 1),
                  ),
                ),
                items: shelfDTOList.map((elem) {
                  return DropdownMenuItem<ShelfDTO>(
                    value: elem,
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Text("ID: ${elem.id} - Floor: ${elem.floor!}"),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          ],
          confirmButtonText: "Move and Delete!!",
          confirmButtonColor: Color(0xFFD2232A),
          onConfirm: () async {
            if (selectedShelf == null) {
              completer.completeError('Please select a user.');
            }

            _artDialogKey.currentState?.showLoader();
            String result = await apiService.moveAndDeleteShelf(
                selectedShelf,currentShelfId);
            _artDialogKey.currentState?.hideLoader();
            try {
              if (result.toUpperCase() == "S") {
                _artDialogKey.currentState?.closeDialog();
                completer.complete('success');
              } else {

                completer.completeError("Unexpected Error!");
                _artDialogKey.currentState?.closeDialog();
              }
            } catch (e) {
              completer.completeError("Unexpected Error!");
              _artDialogKey.currentState?.closeDialog();
            }
          },
          onDispose: () {
            _artDialogKey = GlobalKey<ArtDialogState>();
          },
        ));


    return completer.future;
  }

  @override
  void initState() {
    super.initState();
    fetchShelfs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future refresh() async {
    if(isLoading){
      return;
    }
    setState(() {
      fetchShelfs();
    });
  }




  final double _panelMinSize = 70.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor:Constants.mainRedColor,
        onPressed: () async {
          createShelf(context);
        },
        child: const Icon(Icons.add,color: Constants.whiteColor,),
      ),
        key: _scaffoldKey,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Constants.mainRedColor,
          title: Text('Shelf List Management', style: TextStyle(
              color: Constants.whiteColor
          ),),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Constants.whiteColor,),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(context);
            },
          ),

        ),
      body:WeSlide(
        controller: weSlideController,
        panelMinSize: _panelMinSize,
        blur:false,
        panelMaxSize: MediaQuery.of(context).size.height / 2,
        overlayColor: Constants.mainDarkColor,
        blurColor: Constants.mainDarkColor,
        blurSigma: 2,
        backgroundColor: Colors.white,
        overlayOpacity: 0.7,
        overlay: true,
        panel:Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
        body: Padding(
          padding:const EdgeInsets.fromLTRB(0, 0, 0, 80),
          child: shelfDTOList.isEmpty ? const Text("")
              : RefreshIndicator(
              onRefresh: refresh,
            child: ListView.builder(
              controller: listcontroller,
              itemCount: shelfDTOList.length + 1,
              itemBuilder: (context2, index) {
                if (index < shelfDTOList.length) {
                  ShelfDTO currentShelf = shelfDTOList[index];
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const StretchMotion(),
                      children: [
                        if(shelfDTOList.length > 1)
                          SlidableAction(
                              backgroundColor: Colors.red,
                              icon: Icons.delete,
                              label: 'Delete',
                              onPressed: (context) {
                                if (currentShelf.bookCount == 0 || currentShelf.bookCount == null){
                                  justDelete(context, currentShelf.id);
                                }else{
                                  moveAndDelete(context, currentShelf.id).then((s) {
                                    if (s != null) {
                                      if (s == 'success') {
                                        showTopSnackBar(
                                          Overlay.of(context2),
                                          const CustomSnackBar.success(
                                            message: "Success!",
                                            textAlign: TextAlign.left,
                                          ),
                                        );

                                        refresh();
                                      } else {
                                        showTopSnackBar(
                                          Overlay.of(context2),
                                          CustomSnackBar.error(
                                            message: s,
                                            textAlign: TextAlign.left,
                                          ),
                                        );
                                      }
                                    }
                                  }).catchError((e) {
                                    showTopSnackBar(
                                      Overlay.of(context2),
                                      CustomSnackBar.error(
                                        message: e,
                                        textAlign: TextAlign.left,
                                      ),
                                    );
                                  });
                                }
                              }
                          ),
                        SlidableAction(
                          backgroundColor: Colors.green,
                          icon: Icons.format_list_bulleted,
                          label: 'Update',
                          onPressed: (context) {
                            _idController = TextEditingController(text: currentShelf.id.toString());
                            _floorController = TextEditingController(text: currentShelf.floor);
                            updateShelfDialog(context);
                          },
                        )
                      ],
                    ),
                    child: ListTile(
                      title: ShelfCard(shelf: currentShelf),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

void dissmissed() {}
