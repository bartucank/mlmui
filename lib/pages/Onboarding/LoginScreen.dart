import 'package:flutter/material.dart';
import 'package:mlmui/service/constants.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/UserDTO.dart';
import '../../service/ApiService.dart';
import '../../service/CacheManager.dart';
import 'ForgotPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  late Future<UserDTO> userFuture;
  final ApiService apiService = ApiService();
  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    final username = _usernameController.text;
    final password = _passwordController.text;
    Map<String, dynamic> body = {
      'username': username,
      'pass': password,
    };
    apiService.loginRequest(body).then((value) => {
          if (value['message'] == "Success")
            {
              if (value['data']['needVerify'])
                {
                  Navigator.pushReplacementNamed(
                      context, '/verify')
                }
              else
                {
                  // Navigator.pushReplacementNamed(
                  //     context, '/splash')
                  fetchDetails()
                }
            }
          else if (value['error'] == "Unauthorized")
            {
              showTopSnackBar(
                Overlay.of(context),
                CustomSnackBar.error(
                  message: "Wrong username/password!",
                  textAlign: TextAlign.left,
                ),
              )
            }
          else
            {
              showTopSnackBar(
                Overlay.of(context),
                CustomSnackBar.error(
                  message: "Unexpected error!",
                  textAlign: TextAlign.left,
                ),
              )
            }
        });
  }
  void fetchDetails() async{
    userFuture = apiService.getUserDetails();
    userFuture.then((user) {
      CacheManager.saveUserDTOToCache(user);
      if(user.role=='LIB'){
        Navigator.pushReplacementNamed(context, '/libHome');
      }else {
        Navigator.pushReplacementNamed(context, '/userHome');
      }
    }).catchError((error) {
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Image(
              image: AssetImage('assets/images/bg.jpg'),
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.65,
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0)),
                  border: Border.all(color: Color(0x4d9e9e9e), width: 1),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "Welcome to MLM",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            fontSize: 20,
                            color: Constants.mainDarkColor,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Text(
                            "Sign in to continue",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff5e5e5e),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: TextField(
                            controller: _usernameController,
                            obscureText: false,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Constants.mainDarkColor,
                            ),
                            decoration: InputDecoration(
                              disabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                    color: Constants.mainDarkColor, width: 1),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                    color: Constants.mainDarkColor, width: 1),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                    color: Constants.mainDarkColor, width: 1),
                              ),
                              labelText: "Username",
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 16,
                                color: Constants.mainDarkColor,
                              ),
                              filled: true,
                              fillColor: Color(0x00ffffff),
                              isDense: false,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              prefixIcon: Icon(Icons.person,
                                  color: Constants.mainDarkColor, size: 18),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: TextField(
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            controller: _passwordController,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Constants.mainDarkColor,
                            ),
                            decoration: InputDecoration(
                              disabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                    color: Constants.mainDarkColor, width: 1),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                    color: Constants.mainDarkColor, width: 1),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                    color: Constants.mainDarkColor, width: 1),
                              ),
                              labelText: "Password",
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 16,
                                color: Constants.mainDarkColor,
                              ),
                              filled: true,
                              fillColor: Color(0xffffffff),
                              isDense: false,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              prefixIcon: Icon(Icons.lock,
                                  color: Constants.mainDarkColor, size: 18),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                              );
                            },
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Text("Forgot Password?",style: TextStyle(
                                color: Constants.mainRedColor,
                                fontWeight: FontWeight.w800
                              ),),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: MaterialButton(
                            onPressed: () async {
                              await _login();
                            },
                            color: Constants.mainRedColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                            textColor: Color(0xffffffff),
                            height: 45,
                            minWidth: MediaQuery.of(context).size.width,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/register');
                            },
                            color: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(
                                  color: Color(0xff808080), width: 1),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "Do you not have an account?",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                            textColor: Constants.mainRedColor,
                            height: 45,
                            minWidth: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
