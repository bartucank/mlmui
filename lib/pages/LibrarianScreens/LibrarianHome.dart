import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mlmui/components/MenuDrawerLibrarian.dart';
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

  @override
  void initState() {
    super.initState();
    userFuture = apiService.getUserDetails();
    statisticsFuture = apiService.getStatistics();
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
                            return Text('');
                          } else {
                            return Text('');
                          }
                        } else {
                          return Text('');
                        }
                      } else{
                        final statistics = snapshot.data;
                        return Padding(padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  InfoCard(
                                    title: "Total Users:",
                                    value: statistics!.totalUserCount,
                                    onTap: () {},
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
                                  const SizedBox( width: 10,), // Space b/w Cards
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
}
