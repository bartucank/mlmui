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
        shelfDTOList.addAll(response.shelfDTOList);
      });
    }catch(e){
      print("Error! $e");
    }
  }

  void removeShelf(ShelfDTO shelf) async {
    try {
      String response = await apiService.deleteShelf(0,shelf.id);
      print("Shelf deleted: $response");
    } catch (e) {
      print("Error deleting shelf: $e");
    }
  }

  void showDeleteDialog(BuildContext context, ShelfDTO shelf) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete Shelf"),
            actions: <Widget>[
              TextButton(
                child: Text("Next"),
                onPressed: () {
                  showDeleteConfirmation(context, shelf);
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        }
    );
  }

  void showDeleteConfirmation(BuildContext context, ShelfDTO shelf) {
    ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.warning,
            title: "Are you sure?",
            text: "This will delete the shelf",
            confirmButtonText: "Delete",
            cancelButtonText: "Cancel",
            showCancelBtn: true,
            onConfirm: () {
              removeShelf(shelf);
              Navigator.pop(context);
            }
        )
    );
  }

  void moveShelf(ShelfDTO shelf,int newId) async {
    if (newId == null) {
      print("Invalid ID entered");
      return;
    }

    try {
      String response = await apiService.moveShelf(newId,shelf.id);
      print("Shelf moved: $response");
    } catch (e) {
      print("Error moving shelf: $e");
    }
  }

  void showMoveDialog(BuildContext context, ShelfDTO shelf) {
    final TextEditingController newIdController = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter New ID"),
            content: TextField(
              controller: newIdController,
              decoration: InputDecoration(
                labelText: "New ID",
                hintText: "Enter the new ID for move",
              ),
              keyboardType: TextInputType.number,
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Next"),
                onPressed: () {
                  Navigator.of(context).pop();
                  newId = int.tryParse(newIdController.text)!;
                  if (newId != null) {
                    showMoveConfirmation(context, shelf);
                  } else {
                    showError(context, "Invalid ID Entered");
                  }
                },
              ),
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        }
    );
  }

  void showError(BuildContext context, String message) {
    ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: message
        )
    );
  }

  void showMoveConfirmation(BuildContext context, ShelfDTO shelf) {
    ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.warning,
            title: "Are you sure?",
            text: "This will move the shelf with new ID: $newId",
            confirmButtonText: "Move",
            cancelButtonText: "Cancel",
            showCancelBtn: true,
            onConfirm: () {
              moveShelf(shelf,newId!);
              Navigator.pop(context);
            }
        )
    );
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
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: "ID",
                    hintText: "Enter the ID",
                  ),
                  keyboardType: TextInputType.number,
                ),
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
        key: _scaffoldKey,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Constants.mainRedColor,
          title: Text('Shelf List', style: TextStyle(
              color: Constants.whiteColor
          ),),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Constants.whiteColor,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add, color: Constants.whiteColor),
              onPressed: () {
                createShelf(context);  // Call the function that handles shelf creation
              },
            )
          ],
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
                        if (currentShelf.bookCount == 0 || currentShelf.bookCount == null)
                          SlidableAction(
                              backgroundColor: Colors.red,
                              icon: Icons.delete,
                              label: 'Delete',
                              onPressed: (context) {
                                showDeleteDialog(context, currentShelf);
                              }
                          ),
                        if ((currentShelf.bookCount ?? 0) > 0)
                          SlidableAction(
                              backgroundColor: Colors.blue,
                              icon: Icons.move_up,
                              label: 'Move',
                              onPressed: (context) {
                                showMoveDialog(context, currentShelf);
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
