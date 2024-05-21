import 'dart:async';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mlmui/models/ReceiptHistoryDTO.dart';
import 'package:mlmui/models/UserNamesDTO.dart';
import 'package:mlmui/pages/LibrarianScreens/ReceiptPopUp.dart';
import 'package:mlmui/components/ReceiptCard.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../models/ReceiptHistoryDTOListResponse.dart';
import '../../service/ApiService.dart';
import 'package:we_slide/we_slide.dart';

import '../../service/constants.dart';

class CopyCardManagement extends StatefulWidget {
  const CopyCardManagement({Key? key}) : super(key: key);

  @override
  State<CopyCardManagement> createState() => _CopyCardManagementState();
}

class _CopyCardManagementState extends State<CopyCardManagement> {

  final listcontroller = ScrollController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _approvalController = TextEditingController();

  WeSlideController weSlideController = WeSlideController();
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int page = -1;
  int size =kIsWeb?15:15;
  int totalSize = 0;
  int totalPage = 1000;
  late Future<ReceiptHistoryDTOListResponse> receiptHistoryDTOListResponseFuture;
  List<ReceiptHistoryDTO> receiptHistoryDTOList = [];
  List<ReceiptHistoryDTO> lastList = [];
  ///List<BookCategoryEnumDTO> _dropdownItems = [];
  bool? _selectedValue;

  ///List<UserNamesDTO> _dropdownItemsForUsers = [];
  UserNamesDTO? _selectedValueForUsers;

  Map<String, dynamic> globalFilterRequest = {};

  GlobalKey<ArtDialogState> _artDialogKey = GlobalKey<ArtDialogState>();
  bool isLoading = false;
  bool approved = false;

  @override
  void initState() {
    super.initState();
    fetchFirstReceipts();

    listcontroller.addListener(() {
      if (listcontroller.position.maxScrollExtent == listcontroller.offset) {
        fetchMoreReceipt();
      }
    });

  }




  @override
  void dispose() {
    listcontroller.dispose();
    super.dispose();
  }

  Future refresh() async {
    if(isLoading){
      return;
    }
    setState(() {
      receiptHistoryDTOList.clear();
    });
    page = -1;
    size = 15;
    fetchFirstReceipts();
  }

  void fetchMoreReceipt() async {
    if (page - 1 > totalPage) {
      return;
    }
    if(totalSize<=receiptHistoryDTOList.length){
      return;
    }
    globalFilterRequest['page'] = globalFilterRequest['page'] + 1;
    globalFilterRequest['isApproved'] = approved;

    try {
      lastList.clear();
      ReceiptHistoryDTOListResponse response =
      await apiService.getReceiptsByStatus(globalFilterRequest);
      setState(() {
        receiptHistoryDTOList.addAll(response.receiptHistoryDTOList);
        lastList.addAll(response.receiptHistoryDTOList);
        totalPage = response.totalPage;
        page++;
      });
    } catch (e) {
    }
  }

  void fetchFirstReceipts() async {
    if(isLoading){
      return;
    }

    if (page - 1 > totalPage) {
      return;
    }

    Map<String, dynamic> request = {
      'isApproved': approved,
      "page": page + 1,
      "size": size,
    };
    setState(() {
      isLoading = true;
      globalFilterRequest = request;
    });

    try {
      lastList.clear();
      ReceiptHistoryDTOListResponse response =
      await apiService.getReceiptsByStatus(request);
      setState(() {
        receiptHistoryDTOList.addAll(response.receiptHistoryDTOList);
        lastList.addAll(response.receiptHistoryDTOList);
        totalPage = response.totalPage;
        totalSize = response.totalResult;
        page++;
      });
    } catch (e) {
    }
    setState(() {
      isLoading=false;
    });
  }

  void clear() async {
    setState(() {
      isLoading=true;
    });
    _idController.text = "";

    setState(() {
      lastList.clear();
      receiptHistoryDTOList.clear();
      page = -1;
      size = 7;
      weSlideController.hide();
      FocusScope.of(context).unfocus();
    });

    Map<String, dynamic> request = {
      'isApproved': approved,
      "page": page + 1, "size": size
    };

    setState(() {
      globalFilterRequest = request;
    });
    ReceiptHistoryDTOListResponse response =
    await apiService.getReceiptsByStatus(request);
    setState(() {
      receiptHistoryDTOList.addAll(response.receiptHistoryDTOList);
      lastList.addAll(response.receiptHistoryDTOList);
      totalPage = response.totalPage;
      page++;
    });
    setState(() {
      isLoading=false;
    });
  }

  void filter() async {
    String id = _idController.text ?? "";
    bool approved = _approvalController as bool;

    setState(() {
      isLoading=true;
      lastList.clear();
      receiptHistoryDTOList.clear();
      page = -1;
      size = 7;
      weSlideController.hide();
      FocusScope.of(context).unfocus();
    });

    Map<String, dynamic> request = {
      'isApproved': approved,
      'page': page + 1,
      'size': size,
    };

    setState(() {
      globalFilterRequest = request;
    });

    if (_selectedValue != null && (_selectedValue!.toString() == 'true' || _selectedValue!.toString() == 'false')) {
      request['isApproved'] = _selectedValue?.toString();
    }

    try {
      ReceiptHistoryDTOListResponse response =
      await apiService.getReceiptsByStatus(request);

      setState(() {
        receiptHistoryDTOList.addAll(response.receiptHistoryDTOList);
        lastList.addAll(response.receiptHistoryDTOList);
        totalPage = response.totalPage;
        page++;
        isLoading=false;
      });
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor:Constants.mainRedColor,
          onPressed: () async {
            setState(() {
              approved = !approved;
              refresh();
            });
          },
          child: Icon(approved?Icons.not_interested:Icons.check,color: Constants.whiteColor,),
        ),
        key: _scaffoldKey,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Constants.mainRedColor,
          title: Text('Copy Card Management', style: TextStyle(
              color: Constants.whiteColor
          ),),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Constants.whiteColor,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: WeSlide(
            controller: weSlideController,
            panelMinSize: MediaQuery.of(context).size.height/20,
            blur: false,
            panelMaxSize: MediaQuery.of(context).size.height / 2,
            overlayColor: Constants.mainDarkColor,
            blurColor: Constants.mainDarkColor,
            blurSigma: 2,
            backgroundColor: Colors.white,
            overlayOpacity: 0.7,
            overlay: true,
            panel: Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
            ),
            body: Container(
              color: Constants.mainBackgroundColor,
              child: Stack(children: [

                if (isLoading)
                  Container(
                    child: Center(
                      child: CircularProgressIndicator(backgroundColor: Colors.white,),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
                  child: receiptHistoryDTOList.isEmpty
                      ? Text("")
                      : ListView.builder(
                    itemExtent: 100,
                    controller: listcontroller,
                    itemCount: receiptHistoryDTOList.length + 1,
                    itemBuilder: (context2, index) {
                      if (index < receiptHistoryDTOList.length) {
                        ReceiptHistoryDTO currentreceipt = receiptHistoryDTOList[index];
                        return Slidable(
                            startActionPane: ActionPane(
                              motion: const StretchMotion(),
                              children: [
                                SlidableAction(
                                    backgroundColor: Colors.red,
                                    icon: Icons.search,
                                    label: 'Details',
                                    onPressed:
                                      (context) => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReceiptPopUp(receipt: currentreceipt),
                                    ),
                                  ).then((value) => refresh())
                                ),
                              ],
                            ),

                            child: ListTile(
                              title: ReceiptCard(receipt: currentreceipt),
                            ));
                      } else {
                        if (!lastList.isEmpty && totalSize<receiptHistoryDTOList.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      }
                    },
                  ),
                ),
              ],),
            )
        )
    );
  }
}

void dissmissed() {}
