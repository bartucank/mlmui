import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mlmui/components/MenuDrawerLibrarian.dart';
import 'package:mlmui/models/StatisticsDTOListResponse.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/UserDTO.dart';
import '../../models/StatisticsDTO.dart';
import '../../service/ApiService.dart';
import '../../components/LibrarianInfoCard.dart';

class LibrarianHome extends StatefulWidget {
  const LibrarianHome({Key? key}) : super(key: key);

  @override
  State<LibrarianHome> createState() => _LibrarianHomeState();
}

class _LibrarianHomeState extends State<LibrarianHome> {

  final ApiService apiService = ApiService();
  late Future<UserDTO> userFuture;
  late Future<StatisticsDTO> statisticsFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ArtDialogState> _artDialogKey = GlobalKey<ArtDialogState>();
  late Future<StatisticsDTOListResponse> statisticsDTOListResponse;
  // Future<void> showReceiptHistoryPopup(BuildContext context) async {
  //   ArtDialogResponse response = await ArtSweetAlert.show(
  //       artDialogKey: _artDialogKey,
  //       context: context,
  //       artDialogArgs: ArtDialogArgs(
  //         title: "Total Users",
  //         customColumns: [
  //           Container(
  //             width: 250,
  //             height: 200,
  //             child: FutureBuilder<StatisticsDTOListResponse>(
  //               future: statisticsDTOListResponse,
  //               builder: (BuildContext context, AsyncSnapshot<StatisticsDTOListResponse> snapshot) {
  //                 if (snapshot.connectionState == ConnectionState.waiting) {
  //                   return CircularProgressIndicator();
  //                 } else if (snapshot.hasError) {
  //                   if (snapshot.error is CustomException) {
  //                     CustomException customException = snapshot.error as CustomException;
  //                     if (customException.message == 'NEED_LOGIN') {
  //                       WidgetsBinding.instance!.addPostFrameCallback((_) {
  //                         showTopSnackBar(
  //                           Overlay.of(context),
  //                           CustomSnackBar.error(
  //                             message: "Session experied.",
  //                             textAlign: TextAlign.center,
  //                           ),
  //                         );
  //                         Navigator.pushReplacementNamed(context, '/login');
  //                       });
  //                       return Text('Statistics are not available for now.1');
  //                     } else {
  //                       return Text('Statistics are not available for now.2');
  //                     }
  //                   } else {
  //                     return Text('Statistics are not available for now.3');
  //                   }
  //                 } else{
  //                   List<FlSpot> spots = [];
  //                   List<StatisticsDTO> st = snapshot.data!.statisticsDTOList;
  //                   st.sort((a, b) => a.id.compareTo(b.id));
  //                   for (int i = st.length-1; i >0 ; i--) {
  //                     print("id: ${st[i].id} - data: ${st[i].dayInt.toDouble()} - ${st[i].sumOfDebt}");
  //                     spots.add(FlSpot(st[i].dayInt.toDouble(), st[i].sumOfDebt));
  //                   }
  //
  //                   return LineChart(
  //                     LineChartData(
  //                       lineBarsData: [
  //                         LineChartBarData(
  //                             spots: spots,
  //                             isCurved: false,
  //                             dotData: FlDotData(
  //                               show: true,
  //                             ),
  //                             color: Colors.red
  //                         ),
  //                       ],
  //                       borderData: FlBorderData(
  //                           border: const Border(bottom: BorderSide(), left: BorderSide())),
  //                       gridData: FlGridData(show: false),
  //                       titlesData: FlTitlesData(
  //                         bottomTitles: AxisTitles(sideTitles: _bottomTitles),
  //                         leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //                         topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //                         rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //                       ),
  //                     ),
  //                   );
  //                 }
  //               },
  //             )
  //             ),
  //
  //         ],
  //         confirmButtonText: "Close",
  //         confirmButtonColor: Color(0xFFD2232A),
  //         onConfirm: () async {
  //
  //         },
  //         onDispose: () {
  //           _artDialogKey = GlobalKey<ArtDialogState>();
  //         },
  //       ));
  //
  //   if (response == null) {
  //     return;
  //   }
  //
  //   if (response.isTapConfirmButton) {
  //     ArtSweetAlert.show(
  //         context: context,
  //         artDialogArgs: ArtDialogArgs(customColumns: [
  //           Container(
  //             margin: EdgeInsets.only(bottom: 12.0),
  //             child: Image.network(response.data["image"]),
  //           )
  //         ]));
  //     return;
  //   }
  // }


  @override
  void initState() {
    super.initState();
    userFuture = apiService.getUserDetails();
    statisticsFuture = apiService.getStatistics();

    // statisticsDTOListResponse = apiService.getStatisticsForChart();
  }


  Future<void> refresh()async {
    setState(() {

      statisticsFuture = apiService.getStatistics();
      // statisticsDTOListResponse = apiService.getStatisticsForChart();

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuDrawerLibrarian(),
      appBar: AppBar(
        backgroundColor: Color(0xffd2232a),
        title: Text('MLM'),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      body: Center(
        child: FutureBuilder<UserDTO>(
          future: userFuture,
          builder: (context2, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              if (snapshot.error is CustomException) {
                CustomException customException = snapshot.error as CustomException;
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
              //final user = snapshot.data;
              //return Text('User lıb: ${user?.username}');
              // Return the Information Cards for the Librarian
              // Titles, Values, and the TopColor can be changed
              // ,and the data of them can be taken from somewhere else
              return Padding(padding: EdgeInsets.all(16),
                  child: FutureBuilder<StatisticsDTO>(
                    future: statisticsFuture,
                    builder: (BuildContext context, AsyncSnapshot<StatisticsDTO> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        if (snapshot.error is CustomException) {
                          CustomException customException = snapshot.error as CustomException;
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
                            return Text('Statistics are not available for now.4');
                          } else {
                            return Text('Statistics are not available for now.5');
                          }
                        } else {
                          return Text('Statistics are not available for now.');
                        }
                      } else{
                        final statistics = snapshot.data;
                        return RefreshIndicator(
                          onRefresh: refresh,
                          child: SingleChildScrollView(
                            child: Padding(padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: <Widget>[
                                      InfoCard(
                                        title: "Total Users:",
                                        value: statistics!.totalUserCount,
                                        onTap: () {
                                          // showReceiptHistoryPopup(context);
                                        },
                                        topColor: Colors.orange,
                                      ),
                                      const SizedBox( width: 10,), // Space b/w Cards
                                      InfoCard(
                                        title: "Total Books:",
                                        value: statistics.totalBookCount,
                                        topColor: Colors.lightGreen,
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      InfoCard(
                                        title: "Total Books at the Library:",
                                        value: statistics.availableBookCount,
                                        //value: statistics['data']['availableBookCount'],
                                        topColor: Colors.redAccent,
                                        onTap: () {},
                                      ),
                                      const SizedBox( width: 10,), // Space b/w Cards
                                      InfoCard(
                                        title: "Total Books out of Library:",
                                        value: statistics.unavailableBookCount,
                                        //value: statistics['data']['unavailableBookCount'],
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      InfoCard(
                                        title: "Total CopyCard Balance:",
                                        value: statistics.sumOfBalance,
                                        onTap: () {},
                                        topColor: Colors.yellow,
                                      ),
                                      const SizedBox( width: 10,), // Space b/w Cards
                                      InfoCard(
                                        title: "Total Debt:",
                                        value: statistics.sumOfDebt,
                                        topColor: Colors.blue,
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      InfoCard(
                                        title: "Total Queue:",
                                        value: statistics.queueCount,
                                        onTap: () {},
                                        topColor: Colors.greenAccent,
                                      ),
                                      const SizedBox( width: 0,), // Space b/w Cards
                                      // InfoCard(
                                      //   title: "Total Books:",
                                      //   value: statistics.totalBookCount,
                                      //   topColor: Colors.lightGreen,
                                      //   onTap: () {},
                                      // ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  )
              );
            }
          },
        ),
      ),
    );
  }

  SideTitles get _bottomTitles => SideTitles(
    reservedSize:60,
    showTitles: true,
    getTitlesWidget: (value, meta) {
      String text = '';
      switch (value.toInt()) {
        case 1:
          text = 'Mon';
          break;
        case 2:
          text = 'Tue';
          break;
        case 3:
          text = 'Wed';
          break;
        case 4:
          text = 'Thur';
          break;
        case 5:
          text = 'Fri';
          break;
        case 6:
          text = 'Sat';
          break;
        case 7:
          text = 'Sun';
          break;
      }

      return Text(text);
    },
  );
}
