import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:clipboard/clipboard.dart';
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

import '../../service/constants.dart';

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
      allowedImageTypes: ['png', 'jpg', 'jpeg','heic','HEIC'],
      withData: true,
      withReadStream: true,
      images: <ImageFile>[] // array of pre/default selected images
      );


  @override
  void initState() {
    super.initState();
    userFuture = apiService.getUserDetails();
    fetchHistory();
  }

  void fetchHistory() async {
    ReceiptHistoryDTOListResponse response = await apiService.getReceiptsofUser();
    print(response.receiptHistoryDTOList.length);
    print(response.receiptHistoryDTOList);

    setState(() {
      history.addAll(response.receiptHistoryDTOList);
    });
  }
  Future<void> copyCardShowDialog(BuildContext context) async {
    ArtDialogResponse response = await ArtSweetAlert.show(
        artDialogKey: _artDialogKey,
        context: context,
        artDialogArgs: ArtDialogArgs(
          barrierColor: Constants.mainBarrierColor,
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
              fetchHistory();
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
                  allowedImageTypes: ['png', 'jpg', 'jpeg','heic','HEIC'],
                  withData: true,
                  withReadStream: true,
                  images: <ImageFile>[] // array of pre/default selected images
              );

            } else {
              fetchHistory();
              String msg = result['msg'].toString();
              showTopSnackBar(
                Overlay.of(context),
                CustomSnackBar.info(
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
    List<Widget> receiptHistoryWidgets = [];

    if (history.isNotEmpty) {
      int itemCount = history.length > 3 ? 3 : history.length;
      if(history.length>4){
        for (int i = history.length-1; i > history.length-4; i--) {
          ReceiptHistoryDTO entry = history[i];
          String approve = "Not approved yet.";
          if(entry.approved!){
            approve = "Approved!";
          }

          receiptHistoryWidgets.add(
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receipt ID: ${entry.id}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Approve Status: $approve',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  if(entry.approved!)
                    Text(
                      'Amount: ${entry.balance} ₺',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  Divider(color: Colors.grey),
                ],
              ),
            ),
          );
        }
      }else{
        for (int i = 0; i <=history.length-1; i++) {
          ReceiptHistoryDTO entry = history[i];
          String approve = "Not approved yet.";
          if(entry.approved!){
            approve = "Approved!";
          }

          receiptHistoryWidgets.add(
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receipt ID: ${entry.id}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Approve Status: $approve',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  if(entry.approved!)
                    Text(
                      'Amount: ${entry.balance} ₺',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  Divider(color: Colors.grey),
                ],
              ),
            ),
          );
        }
      }

    } else {
      receiptHistoryWidgets.add(
        Text(
          'No transaction history available.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    ArtDialogResponse response = await ArtSweetAlert.show(
      artDialogKey: _artDialogKey,
      context: context,
      artDialogArgs: ArtDialogArgs(
        barrierColor: Constants.mainBarrierColor,
        title: "Receipt History",
        confirmButtonText: "Close",
        confirmButtonColor: Color(0xFFD2232A),
        customColumns: receiptHistoryWidgets,
        onConfirm: () async {

          _artDialogKey.currentState?.closeDialog();
        },

        onDispose: () {
          _artDialogKey = GlobalKey<ArtDialogState>();
        },

      ),
    );

    if (response == null) {
      return;
    }

    if (response.isTapConfirmButton) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          customColumns: [
            Container(
              margin: EdgeInsets.only(bottom: 12.0),
              child: Image.network(response.data["image"]),
            ),
          ],
        ),
      );
      return;
    }
  }

  Future<void> showBankAccounts(BuildContext context) async {
    ArtDialogResponse response = await ArtSweetAlert.show(
      artDialogKey: _artDialogKey,
      context: context,
      artDialogArgs: ArtDialogArgs(
        barrierColor: Constants.mainBarrierColor,
        title: "",
        confirmButtonText: "Copy Iban and Close",
        confirmButtonColor: Color(0xFFD2232A),
        customColumns: [
          Container(
            child: Center(
              child: Column(
                children: [
                  Image.asset("assets/images/isbank.png"),
                  SizedBox(height: 20,),
                  Text("ODTÜ KKK / O.D.T.Ü K.K.T.C"),
                  Text("Branch 6822 / Account Number 2002"),
                  Text("IBAN: TR91 0006 4000 0016 8220 0020 02"),

                  SizedBox(height: 20,),
                ],
              ),
            ),
          )
        ],
        onConfirm: () async {
          FlutterClipboard.copy('TR91 0006 4000 0016 8220 0020 02').then(( value ) => {

              _artDialogKey.currentState?.closeDialog()
          });

        },

        onDispose: () {
          _artDialogKey = GlobalKey<ArtDialogState>();
        },

      ),
    );

    if (response == null) {
      return;
    }

    if (response.isTapConfirmButton) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          message: "IBAN copied!",
          textAlign: TextAlign.center,
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuDrawer(),
      appBar: AppBar(
        backgroundColor: Constants.mainRedColor,
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
                            color: Constants.mainDarkColor,
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
                  onPressed: () {
                    showBankAccounts(context);
                  },
                  color: Constants.mainDarkColor,
                  textColor: Constants.mainRedColor,
                ),
                SizedBox(height: 20),
                OutlinedButtonsCopyCardPage(
                  buttonLabel: 'Upload Receipt',
                  buttonIcon: Icons.upload_file,
                  onPressed: () {
                    copyCardShowDialog(context);
                  },
                  color: Constants.mainDarkColor,
                  textColor: Constants.mainRedColor,
                ),
                SizedBox(height: 20),
                OutlinedButtonsCopyCardPage(
                  buttonLabel: 'Transaction History',
                  buttonIcon: Icons.timeline,
                  onPressed: () {
                    showReceiptHistoryPopup(context);
                  },
                  color: Constants.mainDarkColor,
                  textColor: Constants.mainRedColor,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
