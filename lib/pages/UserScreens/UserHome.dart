import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../components/MenuDrawer.dart';
import '../../models/UserDTO.dart';
import '../../service/ApiService.dart';

class UserHome extends StatefulWidget {
  const UserHome({Key? key}) : super(key: key);

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {

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
                  return Text('Error: ${customException.message}');
                }
              } else {
                return Text('Error: ${snapshot.error}');
              }
            } else {
              final user = snapshot.data;
              return Text('Student Username: ${user?.username}');
            }
          },
        ),
      ),
    );
  }
}

