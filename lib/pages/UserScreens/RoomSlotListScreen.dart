import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mlmui/models/RoomDTOListResponse.dart';
import 'package:mlmui/models/RoomSlotDTO.dart';
import 'package:mlmui/pages/LibrarianScreens/BookQueueDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:mlmui/components/BookCard.dart';
import '../../components/MenuDrawerLibrarian.dart';

import '../../components/RoomItem.dart';
import '../../models/BookCategoryEnumDTO.dart';

import '../../models/RoomDTO.dart';
import '../../models/RoomSlotDTOListResponse.dart';
import '../../service/ApiService.dart';
import 'package:we_slide/we_slide.dart';

import '../../service/constants.dart';
import 'package:dynamic_tabbar/dynamic_tabbar.dart';

class RoomSlotListScreen extends StatefulWidget {
  final int roomId;

  const RoomSlotListScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  State<RoomSlotListScreen> createState() => _RoomSlotListScreenState();
}

class _RoomSlotListScreenState extends State<RoomSlotListScreen>
    with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<RoomSlotDTO> roomSlotDTOList = [];

  GlobalKey<ArtDialogState> _artDialogKey = GlobalKey<ArtDialogState>();

  List<List<RoomSlotDTO>> slotsForEachDay = [];
  List<String> dayOrder = [];

  void removeTab(int id) {
    setState(() {
      tabs.removeAt(id);
    });
  }

  List<TabData> tabs = [];
  Future<void> reserveTimeSlot(BuildContext context,int id) async {
    ArtDialogResponse response = await ArtSweetAlert.show(
        barrierDismissible: false,
        context: context,
        artDialogArgs: ArtDialogArgs(
            title: "Are you sure?",
            denyButtonText: "Yes, reserve it!",
            denyButtonColor: Constants.mainRedColor,
            confirmButtonText: "Cancel",
            confirmButtonColor: Constants.mainDarkColor,
            type: ArtSweetAlertType.question,
        )
    );

    if (response == null) {
      return;
    }

    if (response.isTapDenyButton) {
      //todo: apicall!!!
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "Reserved!"
          )
      );
      return;
    }
  }
  void fetchSlots() async {
    try {
      RoomSlotDTOListResponse response =
          await apiService.getroomslots(widget.roomId);
      setState(() {
        roomSlotDTOList.clear();
        roomSlotDTOList.addAll(response.roomSlotDTOList);

        List<RoomSlotDTO> first = [];
        List<RoomSlotDTO> second = [];
        List<RoomSlotDTO> third = [];
        slotsForEachDay.add(first);
        slotsForEachDay.add(second);
        slotsForEachDay.add(third);
        for (var value in roomSlotDTOList) {
          int order = dayOrder.indexOf(value.day!);
          if (order == -1) {
            dayOrder.add(value.day!);
          }
          slotsForEachDay[dayOrder.indexOf(value.day!)].add(value);
        }
      });
    } catch (e) {}
    for (var value1 in dayOrder) {
      setState(() {
        var tabNumber = tabs.length + 1;
          tabs.add(
            TabData(
              index: tabNumber,
              title: Tab(child: Text(value1)),
              content: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const ClampingScrollPhysics(),
                  itemCount: slotsForEachDay[dayOrder.indexOf(value1)].length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                        onTap: () {
                          reserveTimeSlot(context,slotsForEachDay[dayOrder.indexOf(value1)][index].id!);
                        },
                        child: RoomSlotItem(
                            slotDTO:slotsForEachDay[dayOrder.indexOf(value1)][index])
                    );
                  }),
            ),
          );


      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSlots();
  }

  void addTab() {
    setState(() {
      var tabNumber = tabs.length + 1;
      tabs.add(
        TabData(
          index: tabNumber,
          title: Tab(
            child: Text('Tab $tabNumber'),
          ),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Dynamic Tab $tabNumber'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constants.mainBackgroundColor,
      drawer: const MenuDrawerLibrarian(),
      appBar: AppBar(
        backgroundColor: Constants.mainRedColor,
        title: Text(
          'Room Slots',
          style: TextStyle(color: Constants.whiteColor),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Constants.whiteColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: DynamicTabBarWidget(
              indicatorColor:Constants.mainDarkColor,
              labelColor:Constants.mainDarkColor,
              tabAlignment:TabAlignment.center,
              dynamicTabs: tabs,
              isScrollable: true,
              onTabControllerUpdated: (controller) {},
              onTabChanged: (index) {},
              onAddTabMoveTo: MoveToTab.last,
              showBackIcon: false,
              showNextIcon: false,
            ),
          ),
        ],
      ),
    );
  }
}

class RoomSlotItem extends StatelessWidget {
  RoomSlotDTO slotDTO;

  RoomSlotItem({required this.slotDTO});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Constants.mainDarkColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            "${slotDTO.startHour!} - ${slotDTO.endHour!}",
            textAlign: TextAlign.center,
            overflow: TextOverflow.clip,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              fontSize: 22,
              color: Color(0xffffffff),
            ),
          ),
        ],
      ),
    );
  }
}
