import 'package:flutter/material.dart';
import 'package:mlmui/models/UserDTO.dart';
import 'package:mlmui/models/UserDTOListResponse.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../components/MenuDrawerLibrarian.dart';
import '../../components/UserCard.dart';
import '../../service/ApiService.dart';
import 'package:we_slide/we_slide.dart';
class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}


class _UserListScreenState extends State<UserListScreen> {

  TextEditingController _nameSurnameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  WeSlideController weSlideController = WeSlideController();
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<UserDTOListResponse> UserDTOListResponseFuture;
  @override
  void initState() {
    super.initState();
    Map<String,dynamic> request = {
      "role":"USER",
    };
    UserDTOListResponseFuture = apiService.getUsersBySpecifications(request);
  }

  void clear() async{
    _nameSurnameController.text = "";
    _emailController.text = "";
    _usernameController.text = "";
    Map<String,dynamic> request = {
      "role":"USER",
    };
    setState(() {
      UserDTOListResponseFuture = apiService.getUsersBySpecifications(request);
      weSlideController.hide();
      FocusScope.of(context).unfocus();
    });
  }

  void filter() async{
    String namesurname = "";
    String username = "";
    String email = "";

    if(_nameSurnameController.text != null){
      namesurname = _nameSurnameController.text;
    }

    if(_usernameController.text != null){
      username = _usernameController.text;
    }

    if(_emailController.text != null){
      email = _emailController.text;
    }
    Map<String,dynamic> request = {
      "role":"USER",
      "fullName":namesurname,
      "username":username,
      "email":email,

    };
    setState(() {
      UserDTOListResponseFuture = apiService.getUsersBySpecifications(request);
      weSlideController.hide();
      FocusScope.of(context).unfocus();
    });
  }
  final double _panelMinSize = 70.0;
  final double _panelMaxSize = 200;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: const MenuDrawerLibrarian(),
        appBar: AppBar(
          backgroundColor: Color(0xffd2232a),
          title: Text('User List'),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body:FutureBuilder<UserDTOListResponse>(
          future: UserDTOListResponseFuture,
          builder: (context2, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
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
              List<UserDTO> users = snapshot.data!.userDTOList;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context2, index) {
                  return UserCard(user: users[index]);
                },
              );
            }
          },
        )
    );
  }


}

