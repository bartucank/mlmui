import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../components/MenuDrawerLibrarian.dart';
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

  late Future<QueueDetailDTO> queueDetailDTO;

  void fetchDetails() async {
    try {
      queueDetailDTO =
          apiService.getQueueStatusBasedOnBookForLibrarian(widget.id!);
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "ERROR",
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
        print("Image not found");
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

  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Color(0xffd2232a),
          title: Text('Queue Detail'),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: FutureBuilder<QueueDetailDTO?>(
            future: queueDetailDTO,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasError) {
                return Text("");
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
                              future: _fetchImage(detail!.bookDTO!.imageId!),
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
                                    fit: BoxFit.cover,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                                color: Color(0xff000000),
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
                                            color: Color(0xff000000),
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
                                            color: Color(0xff3a57e8),
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
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color: Color(0xff212435),
                                                    size: 18,
                                                  ),
                                                  Padding(
                                                    padding:
                                                    EdgeInsets.fromLTRB(
                                                        4, 0, 0, 0),
                                                    child: Text(
                                                      "Status: " +
                                                          detail!.statusDesc!,
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
                                                        Color(0xff000000),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            if(detail!.startDate! != null &&
                                                detail!.startDate! != "")
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      8, 0, 0, 0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                    mainAxisSize:
                                                    MainAxisSize.max,
                                                    children: [
                                                      Icon(
                                                        Icons.date_range,
                                                        color: Color(
                                                            0xff212435),
                                                        size: 18,
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Padding(
                                                          padding:
                                                          EdgeInsets.fromLTRB(
                                                              4, 0, 0, 0),
                                                          child: Text(
                                                            "Start Date: ",
                                                            textAlign:
                                                            TextAlign.start,
                                                            overflow:
                                                            TextOverflow.clip,
                                                            style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w400,
                                                              fontStyle: FontStyle
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

                                            if(detail!.startDate! != null &&
                                                detail!.startDate! != "")
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 0, 0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.center,
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
                                                          Color(0xff000000),
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
                                            color: Color(0xff3a57e8),
                                          ),
                                        ),
                                      ),
                                      ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          padding:
                                          EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: detail!.members!.length,
                                          itemBuilder: (context2, index) {
                                            QueueMembersDTO dto = detail!.members![index];
                                            return Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.max,
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
                                                      padding: EdgeInsets
                                                          .fromLTRB(
                                                          16, 0, 0, 0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        mainAxisSize:
                                                        MainAxisSize.max,
                                                        children: [
                                                          Text(
                                                            dto.userDTO!.fullName!,
                                                            textAlign:
                                                            TextAlign.start,
                                                            overflow:
                                                            TextOverflow.clip,
                                                            style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w700,
                                                              fontStyle:
                                                              FontStyle.normal,
                                                              fontSize: 14,
                                                              color:
                                                              Color(0xff000000),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 4, 0, 0),
                                                            child: Text(
                                                              dto.userDTO!.email,
                                                              textAlign:
                                                              TextAlign.start,
                                                              overflow:
                                                              TextOverflow.clip,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                FontWeight.w400,
                                                                fontStyle: FontStyle
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
                                                      padding: EdgeInsets
                                                          .fromLTRB(
                                                          16, 0, 0, 0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        mainAxisSize:
                                                        MainAxisSize.max,
                                                        children: [
                                                          Text(
                                                            dto.statusDesc!,
                                                            textAlign:
                                                            TextAlign.start,
                                                            overflow:
                                                            TextOverflow.clip,
                                                            style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w700,
                                                              fontStyle:
                                                              FontStyle.normal,
                                                              fontSize: 14,
                                                              color:
                                                              Color(0xff000000),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 4, 0, 0),
                                                            child: Text(
                                                              "Click to view full detail!",
                                                              textAlign:
                                                              TextAlign.start,
                                                              overflow:
                                                              TextOverflow.clip,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                FontWeight.w400,
                                                                fontStyle: FontStyle
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

                                                  SizedBox(height: 20,)
                                                ],
                                              ),
                                            );

                                          }
                                      ),
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
        ));
  }
}
