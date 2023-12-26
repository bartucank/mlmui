import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:lazy_data_table_plus/lazy_data_table_plus.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:mlmui/models/BookDTO.dart';
import '../../components/MenuDrawer.dart';
import '../../components/OutlinedButtonsCopyCardPage.dart';
import '../../models/ReceiptHistoryDTO.dart';
import '../../models/ReceiptHistoryDTOListResponse.dart';
import '../../models/UserDTO.dart';
import '../../service/ApiService.dart';
import '../../components/OutlinedButtons.dart';
import '../../models/BookDTOListResponse.dart';
import 'dart:convert';
import 'package:mlmui/components/BookCard.dart';
import 'dart:ui' as ui;

class CopyCard extends StatefulWidget {
  const CopyCard({Key? key}) : super(key: key);

  @override
  State<CopyCard> createState() => _CopyCardState();
}

class _CopyCardState extends State<CopyCard> {
  final ApiService apiService = ApiService();
  late Future<UserDTO> userFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _textController = TextEditingController();
  GlobalKey<ArtDialogState> _artDialogKey = GlobalKey<ArtDialogState>();
  List<ReceiptHistoryDTO> history = [];
   var imgController = MultiImagePickerController(
      maxImages: 1,
      allowedImageTypes: ['png', 'jpg', 'jpeg'],
      withData: true,
      withReadStream: true,
      images: <ImageFile>[] // array of pre/default selected images
      );


  @override
  void initState() {
    super.initState();
    userFuture = apiService.getUserDetails();
  }

  void fetchHistory() async {
    ReceiptHistoryDTOListResponse response = await apiService.getReceiptsofUser();
    setState(() {
      history.addAll(response.receiptHistoryDTOList);
    });
  }
  Future<void> copyCardShowDialog(BuildContext context) async {
    ArtDialogResponse response = await ArtSweetAlert.show(
        artDialogKey: _artDialogKey,
        context: context,
        artDialogArgs: ArtDialogArgs(
          title: "Please Upload Receipt",
          customColumns: [
            Stack(children: [
              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: MultiImagePickerView(
                  addButtonTitle: "Click to Add Receipt",
                  controller: imgController,
                  padding: const EdgeInsets.all(10),
                ),
              ),

            ])
          ],
          confirmButtonText: "Send to confirmation",
          confirmButtonColor: Color(0xFFD2232A),
          onConfirm: () async {
            if (imgController.images.length == 0) {
              showTopSnackBar(
                Overlay.of(context),
                const CustomSnackBar.info(
                  message: "Please add a receipt",
                  textAlign: TextAlign.left,
                ),
              );
              return;
            }
            _artDialogKey.currentState?.showLoader();

            int value =
                await apiService.uploadImage(imgController.images.first);
            if (value == -1) {

              _artDialogKey.currentState?.hideLoader();
              showTopSnackBar(
                Overlay.of(context),
                const CustomSnackBar.info(
                  message:
                      "Image did not uploaded. Please upload image again. ",
                  textAlign: TextAlign.left,
                ),
              );
            }
            Map<String, dynamic> result = await apiService.createReceipt(value);

            _artDialogKey.currentState?.hideLoader();
            if (result['statusCode'].toString().toUpperCase() == "S") {
              showTopSnackBar(
                Overlay.of(context),
                const CustomSnackBar.success(
                  message: "Success!",
                  textAlign: TextAlign.left,
                ),
              );

              _artDialogKey.currentState?.closeDialog();
              imgController = MultiImagePickerController(
                  maxImages: 1,
                  allowedImageTypes: ['png', 'jpg', 'jpeg'],
                  withData: true,
                  withReadStream: true,
                  images: <ImageFile>[] // array of pre/default selected images
              );

            } else {
              String msg = result['msg'].toString();
              showTopSnackBar(
                Overlay.of(context),
                CustomSnackBar.success(
                  message: msg.toString(),
                  textAlign: TextAlign.left,
                ),
              );
            }
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

  Future<void> showReceiptHistoryPopup(BuildContext context) async {
    ArtDialogResponse response = await ArtSweetAlert.show(
        artDialogKey: _artDialogKey,
        context: context,
        artDialogArgs: ArtDialogArgs(
          title: "Receipt History",
          customColumns: [
            Container(child: Text('sdf'),)
          ],
          confirmButtonText: "Close",
          confirmButtonColor: Color(0xFFD2232A),
          onConfirm: () async {

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
      drawer: const MenuDrawer(),
      appBar: AppBar(
        backgroundColor: Color(0xffd2232a),
        title: Text(
          'CopyCard',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
            child: Align(
              alignment: Alignment.topCenter,
              child: FutureBuilder<UserDTO>(
                future: userFuture,
                builder: (context2, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    if (snapshot.error is CustomException) {
                      CustomException customException =
                          snapshot.error as CustomException;
                      if (customException.message == 'NEED_LOGIN') {
                        WidgetsBinding.instance!.addPostFrameCallback((_) {
                          showTopSnackBar(
                            Overlay.of(context),
                            CustomSnackBar.error(
                              message: "Session experied.",
                              textAlign: TextAlign.center,
                            ),
                          );
                          Navigator.pushReplacementNamed(context2, '/login');
                        });
                        return Text('');
                      } else {
                        return Text('');
                      }
                    } else {
                      return Text('');
                    }
                  } else {
                    final user = snapshot.data;
                    if(user != null && user!.copyCardDTO != null ){
                      if(user!.copyCardDTO!.nfcCode == null || user!.copyCardDTO!.nfcCode == ""){
                        WidgetsBinding.instance!.addPostFrameCallback((_) {
                          showTopSnackBar(
                            Overlay.of(context),
                            CustomSnackBar.error(
                              textStyle:  const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              maxLines:10,
                              message: "You have not yet obtained a physical card. To use copy card privileges, please contact the library and obtain a physical card.",
                              textAlign: TextAlign.left,
                            ),
                          );

                        });
                    }


                      }else{
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
                            maxLines:3,
                            message: "We cannot fetch your copy card informations. Please contact administrator. ",
                            textAlign: TextAlign.left,
                          ),
                        );

                      });
                    }
                    if(user != null && user!.copyCardDTO != null ){
                      return Container(
                        width: 300,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/images/loog_large.png',
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Copy Card / Kopikart',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              user!.fullName.toUpperCase() +
                                  " / " +
                                  user!.username,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Balance: "+user!.copyCardDTO!.balance.toString()+" ₺",
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Text("");

                  }
                },
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                OutlinedButtonsCopyCardPage(
                  buttonLabel: 'Access Bank Accounts',
                  buttonIcon: Icons.account_balance,
                  onPressed: () {},
                  color: Colors.black,
                  textColor: Color(0xffd2232a),
                ),
                SizedBox(height: 20),
                OutlinedButtonsCopyCardPage(
                  buttonLabel: 'Upload Receipt',
                  buttonIcon: Icons.upload_file,
                  onPressed: () {
                    copyCardShowDialog(context);
                  },
                  color: Colors.black,
                  textColor: Color(0xffd2232a),
                ),
                SizedBox(height: 20),
                OutlinedButtonsCopyCardPage(
                  buttonLabel: 'Transaction History',
                  buttonIcon: Icons.timeline,
                  onPressed: () {
                    showReceiptHistoryPopup(context);
                  },
                  color: Colors.black,
                  textColor: Color(0xffd2232a),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
