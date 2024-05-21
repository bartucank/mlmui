import 'dart:async';
import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../models/BookDTO.dart';
import '../../models/QueueDetailDTO.dart';
import '../../models/QueueMembersDTO.dart';
import '../../service/ApiService.dart';
import '../../service/constants.dart';

import 'package:http/http.dart' as http;

class BookQueueDetail extends StatefulWidget {
  final int? id;

  const BookQueueDetail({Key? key, required this.id}) : super(key: key);

  @override
  State<BookQueueDetail> createState() => _BookQueueDetailState();
}

class _BookQueueDetailState extends State<BookQueueDetail> {
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _base64Image;
  bool isLoading = false;

  late Future<QueueDetailDTO> queueDetailDTO;

  GlobalKey<ArtDialogState> _artDialogKey = GlobalKey<ArtDialogState>();

  void fetchDetails() async {
    try {
      setState(() {
        queueDetailDTO =
            apiService.getQueueStatusBasedOnBookForLibrarian(widget.id!);
      });
    } catch (e) {

        String err = e!=null && e.toString()!=null ? e.toString():"Unexpected error!";
        showTopSnackBar(
          Overlay.of(context),
           CustomSnackBar.error(
            message: err,
            textAlign: TextAlign.left,
          ),
        );
      print("Error! $e");
    }
  }

  Future<String> _fetchImage(int id) async {
    try {
      String base64Image = await getImageBase64(id);

      if (base64Image != "1") {
        return base64Image;
        setState(() {
          _base64Image = base64Image;
        });
      } else {
        return "";
        // print("Image not found");
      }
    } catch (error) {
      print("Error fetching image: $error");
    }
    return "";
  }

  static Future<String> getImageBase64(int? imageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString(imageId.toString());

    if (base64Image != null) {
      return base64Image;
    } else {
      final response = await http.get(Uri.parse(
          '${Constants.apiBaseUrl}/api/user/getImageBase64ById?id=$imageId'));

      if (response.statusCode == 200) {
        String base64 = base64Encode(response.bodyBytes);
        prefs.setString(imageId.toString(), base64);
        return base64;
      } else {
        return "1";
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> takeBack(BuildContext context, int id) async {
    Completer<String> completer2 = Completer<String>();
    _artDialogKey.currentState?.showLoader();
    Map<String, dynamic> result = await apiService.takeBackBook(id);
    _artDialogKey.currentState?.hideLoader();
    try {
      if (result['statusCode'].toString().toUpperCase() == "S") {
        _artDialogKey.currentState?.closeDialog();
        completer2.complete('success');
      } else {
        String msg = result['message'].toString();
        // print(msg);
        completer2.completeError(msg);
        _artDialogKey.currentState?.closeDialog();
      }
    } catch (e) {
      String msg = result['message'].toString();
      print(msg);
      completer2.completeError(msg);
      _artDialogKey.currentState?.closeDialog();
    }

    return completer2.future;
  }

  Future<String> borrowBook(BuildContext context, int bookId, int userId) async {
    Completer<String> completer2 = Completer<String>();
    _artDialogKey.currentState?.showLoader();
    Map<String, dynamic> result = await apiService.borrowBook(bookId,userId);
    _artDialogKey.currentState?.hideLoader();
    try {
      if (result['statusCode'].toString().toUpperCase() == "S") {
        _artDialogKey.currentState?.closeDialog();
        completer2.complete('success');
      } else {
        String msg = result['message'].toString();
        // print(msg);
        completer2.completeError(msg);
        _artDialogKey.currentState?.closeDialog();
      }
    } catch (e) {
      String msg = result['message'].toString();
      print(msg);
      completer2.completeError(msg);
      _artDialogKey.currentState?.closeDialog();
    }

    return completer2.future;
  }

  Future<void> showActions(BuildContext context, QueueMembersDTO dto,
      int bookId, bool heldFlag) async {
    ArtDialogResponse response = await ArtSweetAlert.show(
        artDialogKey: _artDialogKey,
        context: context,
        artDialogArgs: ArtDialogArgs(
          barrierColor: Constants.mainBarrierColor,
          dialogAlignment: Alignment.centerLeft,
          title: "Details and Actions for ${dto.userDTO!.fullName!} ",
          customColumns: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Enter date: '),
                      Text(dto.enterDate!),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Take date: '),
                      Text(dto.takeDate!),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Retun date: '),
                      Text(dto.returnDate!),
                    ],
                  ),
                ],
              ),
            )
          ],
          confirmButtonText: "Close",
          confirmButtonColor: Color(0xFFD2232A),
          onConfirm: () async {
            _artDialogKey.currentState?.closeDialog();
          },
          cancelButtonText: (dto!.status != null &&
              dto!.status! == "WAITING_RETURN") ? "Take Back!" : "Lend!",
          cancelButtonColor: Color(0xFFD2232A),
          showCancelBtn:
          dto!.status != null && (dto!.status! == "WAITING_RETURN" ||
              (dto!.status! == "WAITING_TAKE" && heldFlag)),
          onCancel: () async {
            setState(() {
              isLoading = true;
            });
            if(dto!.status!=null && dto!.status! == "WAITING_RETURN"){
              takeBack(context, bookId).then((s) {
                if (s != null) {
                  if (s == 'success') {
                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.success(
                        message: "Success!",
                        textAlign: TextAlign.left,
                      ),
                    );
                     fetchDetails();
                    setState(() {
                      isLoading = false;
                    });
                  } else {
                    showTopSnackBar(
                      Overlay.of(context),
                      CustomSnackBar.error(
                        message: s,
                        textAlign: TextAlign.left,
                      ),
                    );
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              }).catchError((e) {
                showTopSnackBar(
                  Overlay.of(context),
                  CustomSnackBar.error(
                    message: e.toString(),
                    textAlign: TextAlign.left,
                  ),
                );
                setState(() {
                  isLoading = false;
                });
              });
            }


            if (dto!.status!=null && dto!.status! == "WAITING_TAKE") {
              borrowBook(context, bookId,dto.userDTO!.id!).then((s) {
                if (s != null) {
                  if (s == 'success') {
                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.success(
                        message: "Success!",
                        textAlign: TextAlign.left,
                      ),
                    );

                    fetchDetails();
                    setState(() {
                      isLoading = false;
                    });
                  } else {
                    showTopSnackBar(
                      Overlay.of(context),
                      CustomSnackBar.error(
                        message: s,
                        textAlign: TextAlign.left,
                      ),
                    );
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              }).catchError((e) {
                showTopSnackBar(
                  Overlay.of(context),
                  CustomSnackBar.error(
                    message: e.toString(),
                    textAlign: TextAlign.left,
                  ),
                );
                setState(() {
                  isLoading = false;
                });
              });

            }
            // _artDialogKey.currentState?.closeDialog();
          },
          onDispose: () {
            _artDialogKey = GlobalKey<ArtDialogState>();
          },
        ));

    if (response == null) {
      return;
    }

    if (response.isTapConfirmButton) {
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(customColumns: [
            Container(
              margin: EdgeInsets.only(bottom: 12.0),
              child: Image.network(response.data["image"]),
            )
          ]));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Constants.mainRedColor,
          title: Text('Queue Detail'),
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
            if (isLoading)
              Container(
                color: Constants.mainDarkColor.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            SingleChildScrollView(
              child: FutureBuilder<QueueDetailDTO?>(
                future: queueDetailDTO,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.hasError) {
                    return Center(
                        child: Column(
                          children: [
                            CardLoading(
                              height: 10,
                              borderRadius: BorderRadius.all(Radius.circular(
                                  50)),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            ),
                            CardLoading(
                              height: 50,
                              borderRadius: BorderRadius.all(Radius.circular(
                                  100)),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            ),
                            CardLoading(
                              height: 10,
                              borderRadius: BorderRadius.all(Radius.circular(
                                  50)),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            ),
                            CardLoading(
                              height: 50,
                              borderRadius: BorderRadius.all(Radius.circular(
                                  100)),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            ),
                            CardLoading(
                              height: 10,
                              borderRadius: BorderRadius.all(Radius.circular(
                                  50)),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            ),
                            CardLoading(
                              height: 50,
                              borderRadius: BorderRadius.all(Radius.circular(
                                  100)),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            ),
                            CardLoading(
                              height: 10,
                              borderRadius: BorderRadius.all(Radius.circular(
                                  50)),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            ),
                            CardLoading(
                              height: 50,
                              borderRadius: BorderRadius.all(Radius.circular(
                                  100)),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            ),
                            CardLoading(
                              height: 10,
                              borderRadius: BorderRadius.all(Radius.circular(
                                  50)),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            ),
                            CardLoading(
                              height: 50,
                              borderRadius: BorderRadius.all(Radius.circular(
                                  100)),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            ),
                            CardLoading(
                              height: 10,
                              borderRadius: BorderRadius.all(Radius.circular(
                                  50)),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            ),
                            CardLoading(
                              height: 50,
                              borderRadius: BorderRadius.all(Radius.circular(
                                  100)),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            ),
                            CardLoading(
                              height: 10,
                              borderRadius: BorderRadius.all(Radius.circular(
                                  50)),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            ),
                          ],
                        ));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    QueueDetailDTO? detail = snapshot.data;

                    String holdOrOn = "";
                    if (detail!.holdFlag == true) {
                      String name = "";
                      detail!.members!.forEach((element) {
                        if (element.userDTO.id == detail.holdDTO!.userId) {
                          name = element.userDTO.fullName;
                        }
                      });
                      holdOrOn = "This book should be held for " + name + "!";
                    } else {
                      String name = "";
                      detail!.members!.forEach((element) {
                        if (element!.status! == "WAITING_RETURN") {
                          name = element.userDTO.fullName;
                        }
                      });
                      holdOrOn = "This book will be returned by " + name;
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          child: Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              FutureBuilder(
                                  future: _fetchImage(
                                      detail!.bookDTO!.imageId!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                        snapshot.hasError) {
                                      return Text("");
                                    } else if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      return Image.memory(
                                        base64Decode(snapshot.data!),
                                        height: 220,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        fit: BoxFit.contain,
                                      );
                                    } else {
                                      return Text("");
                                    }
                                  }),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  margin: EdgeInsets.all(0),
                                  padding: EdgeInsets.all(0),
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.75,
                                  decoration: BoxDecoration(
                                    color: Color(0xffffffff),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(
                                        color: Color(0x4d9e9e9e), width: 1),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "Queue for " +
                                                      detail!.bookDTO!.name!,
                                                  textAlign: TextAlign.start,
                                                  overflow: TextOverflow.clip,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 20,
                                                    color: Constants.mainDarkColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(
                                              detail!.members!.length > 1
                                                  ? "There are " +
                                                  detail!.members!.length
                                                      .toString() +
                                                  " people on the queue."
                                                  : "There is " +
                                                  detail!.members!.length
                                                      .toString() +
                                                  " people on the queue.",
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.clip,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 14,
                                                color: Constants.mainDarkColor,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(
                                              holdOrOn,
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.clip,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 14,
                                                color: Color(0xFFD2232A),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(0, 8, 0, 0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                    mainAxisSize: MainAxisSize
                                                        .max,
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        color: Color(
                                                            0xFFD2232A),
                                                        size: 18,
                                                      ),
                                                      Padding(
                                                        padding:
                                                        EdgeInsets.fromLTRB(
                                                            4, 0, 0, 0),
                                                        child: Text(
                                                          "Status: " +
                                                              detail!
                                                                  .statusDesc!,
                                                          textAlign:
                                                          TextAlign.start,
                                                          overflow:
                                                          TextOverflow.clip,
                                                          style: TextStyle(
                                                            fontWeight:
                                                            FontWeight.w400,
                                                            fontStyle:
                                                            FontStyle.normal,
                                                            fontSize: 14,
                                                            color:
                                                            Color(0xFFD2232A),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (detail!.startDate! !=
                                                    null &&
                                                    detail!.startDate! != "")
                                                  Expanded(
                                                    flex: 1,
                                                    child: Padding(
                                                      padding: EdgeInsets
                                                          .fromLTRB(
                                                          8, 0, 0, 0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        mainAxisSize:
                                                        MainAxisSize.max,
                                                        children: [
                                                          Icon(
                                                            Icons.date_range,
                                                            color:
                                                            Constants.mainDarkColor,
                                                            size: 18,
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .fromLTRB(
                                                                  4, 0, 0, 0),
                                                              child: Text(
                                                                "Start Date: ",
                                                                textAlign:
                                                                TextAlign.start,
                                                                overflow:
                                                                TextOverflow
                                                                    .clip,
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                                  fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                                  fontSize: 14,
                                                                  color: Color(
                                                                      0xff000000),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (detail!.startDate! !=
                                                    null &&
                                                    detail!.startDate! != "")
                                                  Expanded(
                                                    flex: 1,
                                                    child: Padding(
                                                      padding: EdgeInsets
                                                          .fromLTRB(
                                                          0, 0, 0, 0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        mainAxisSize:
                                                        MainAxisSize.max,
                                                        children: [
                                                          Text(
                                                            detail!.startDate!,
                                                            textAlign:
                                                            TextAlign.start,
                                                            overflow:
                                                            TextOverflow.clip,
                                                            style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w400,
                                                              fontStyle:
                                                              FontStyle.normal,
                                                              fontSize: 14,
                                                              color:
                                                              Constants.mainDarkColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(
                                              "Members On The Queue",
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.clip,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 16,
                                                color: Color(0xFFD2232A),
                                              ),
                                            ),
                                          ),
                                          ListView.builder(
                                              scrollDirection: Axis.vertical,
                                              padding:
                                              EdgeInsets.fromLTRB(0, 16, 0, 0),
                                              shrinkWrap: true,
                                              physics:
                                              NeverScrollableScrollPhysics(),
                                              itemCount: detail!.members!
                                                  .length,
                                              itemBuilder: (context2, index) {
                                                QueueMembersDTO dto =
                                                detail!.members![index];
                                                return InkWell(
                                                  onTap: () {
                                                    bool heldFlag = false;
                                                    if (detail!.holdFlag! &&
                                                        detail!.holdDTO!
                                                            .userId! ==
                                                            dto.userDTO.id!) {
                                                      heldFlag = true;
                                                    }
                                                    showActions(context, dto,
                                                        detail!.bookDTO.id!,
                                                        heldFlag
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      mainAxisSize:
                                                      MainAxisSize.max,
                                                      children: [
                                                        Image(
                                                          image: AssetImage(
                                                              "assets/images/default.png"),
                                                          height: 40,
                                                          width: 40,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Padding(
                                                            padding:
                                                            EdgeInsets.fromLTRB(
                                                                16, 0, 0, 0),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              mainAxisSize:
                                                              MainAxisSize.max,
                                                              children: [
                                                                Text(
                                                                  dto.userDTO!
                                                                      .fullName!,
                                                                  textAlign:
                                                                  TextAlign
                                                                      .start,
                                                                  overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                    fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                    fontSize: 14,
                                                                    color: Color(
                                                                        0xff000000),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                      0,
                                                                      4,
                                                                      0,
                                                                      0),
                                                                  child: Text(
                                                                    dto.userDTO!
                                                                        .email,
                                                                    textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                    overflow:
                                                                    TextOverflow
                                                                        .clip,
                                                                    style:
                                                                    TextStyle(
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                      fontStyle:
                                                                      FontStyle
                                                                          .normal,
                                                                      fontSize: 12,
                                                                      color: Color(
                                                                          0xff000000),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Padding(
                                                            padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 0, 0),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              mainAxisSize:
                                                              MainAxisSize.max,
                                                              children: [
                                                                Text(
                                                                  dto
                                                                      .statusDesc!,
                                                                  textAlign:
                                                                  TextAlign
                                                                      .start,
                                                                  overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                    fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                    fontSize: 14,
                                                                    color: Color(
                                                                        0xff000000),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                      0,
                                                                      4,
                                                                      0,
                                                                      0),
                                                                  child: Text(
                                                                    "Click to view details and actions!",
                                                                    textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                    overflow:
                                                                    TextOverflow
                                                                        .clip,
                                                                    style:
                                                                    TextStyle(
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                      fontStyle:
                                                                      FontStyle
                                                                          .normal,
                                                                      fontSize: 12,
                                                                      color: Color(
                                                                          0xff000000),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Text("");
                  }
                },
              ),
            ),
          ],
        ));
  }
}
