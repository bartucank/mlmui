import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:mlmui/models/BookDTO.dart';
import '../../components/MenuDrawer.dart';
import '../../components/OutlinedButtonsCopyCardPage.dart';
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

  @override
  void initState() {
    super.initState();
    userFuture = apiService.getUserDetails();
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
            padding: const EdgeInsets.fromLTRB(0,25,0,0),
            child: Align(alignment:Alignment.topCenter,
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
                      return Text('Error: ${customException.message}');
                    }
                  } else {
                    return Text('Error: ${snapshot.error}');
                  }
                } else {
                  final user = snapshot.data;
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
                          child: Image.asset(
                              'assets/images/loog_large.png',
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover
                          ),
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
                          user!.fullName.toUpperCase() + " / "+ user!.username,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
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
                  onPressed: (){
                  },
                  color: Colors.black,
                  textColor: Color(0xffd2232a),
                ),
                SizedBox(height: 20),
                OutlinedButtonsCopyCardPage(
                  buttonLabel: 'Upload Receipt',
                  buttonIcon: Icons.upload_file,
                  onPressed: (){
                  },
                  color: Colors.black,
                  textColor: Color(0xffd2232a),
                ),
                SizedBox(height: 20),
                OutlinedButtonsCopyCardPage(
                  buttonLabel: 'Transaction History',
                  buttonIcon: Icons.timeline,
                  onPressed: (){
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

