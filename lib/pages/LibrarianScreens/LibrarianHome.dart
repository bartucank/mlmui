import 'package:flutter/material.dart';
import 'package:mlmui/components/MenuDrawerLibrarian.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/UserDTO.dart';
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
                  return Text('Error: ${customException.message}');
                }
              } else {
                return Text('Error: ${snapshot.error}');
              }
            } else {
              final user = snapshot.data;
              //return Text('User lıb: ${user?.username}');
              // Return the Information Cards for the Librarian
              // Titles, Values, and the TopColor can be changed
              // ,and the data of them can be taken from somewhere else
              return Padding(padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      InfoCard(
                        title: "Total Users:",
                        value: 54,
                        onTap: () {},
                        topColor: Colors.orange,
                      ),
                      const SizedBox( width: 10,), // Space b/w Cards
                      InfoCard(
                        title: "Total Books:",
                        value: 1024,
                        topColor: Colors.lightGreen,
                        onTap: () {},
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      InfoCard(
                        title: "Total Librarians:",
                        value: 3,
                        topColor: Colors.redAccent,
                        onTap: () {},
                      ),
                      const SizedBox( width: 10,), // Space b/w Cards
                      InfoCard(
                        title: "Total :",
                        value: 0,
                        onTap: () {},
                      ),
                    ],
                  )
                ],
              ),
              );
            }
          },
        ),
      ),
    );
  }
}