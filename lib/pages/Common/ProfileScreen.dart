import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:mlmui/models/UserDTO.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../service/ApiService.dart';
import '../../service/constants.dart';

class ProfileScreen extends StatefulWidget {
  final UserDTO userDTO;
  final String role;
  const ProfileScreen({Key? key,required this.userDTO, required this.role}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _nameSurnameController = TextEditingController();
  TextEditingController _depController = TextEditingController();
  TextEditingController _oldpasswordController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String _selectedValue = "User";
  String _selectedValueTemp = "User";
  List<String> _dropdownItems = ["USER","LIB","LEC"];

  final ApiService apiService = ApiService();

  bool changePass = false;



  Future<void> changePassword(BuildContext context,String newPass, String oldPass) async {
    Map<String, dynamic> request = {
      "newPassword": newPass,
      "oldPassword": oldPass,
    };
    ArtDialogResponse response = await ArtSweetAlert.show(
        barrierDismissible: false,
        context: context,
        artDialogArgs: ArtDialogArgs(
            denyButtonText: "Cancel",
            title: "Are you sure?",
            text: "Your password will be changed.",
            confirmButtonText: "Yes",
            type: ArtSweetAlertType.warning
        )
    );

    if(response==null) {
      return;
    }

    if(response.isTapConfirmButton) {
      String result = await apiService.changePass(request);
      print(result);
      if (result == "ok") {
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "Password Updated!"
            )
        );
        setState(() {
          changePass = false;
          _oldpasswordController.text="";
          _passwordController.text="";
        });
      } else {
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Password Couldn't Updated!",
              text: "Please contact admin."
            )
        );
        setState(() {
          _selectedValue=_selectedValueTemp;
        });
      }

      return;
    }
  }



  Future<void> showRoleUpdatePopup(BuildContext context,String newValue) async {
    ArtDialogResponse response = await ArtSweetAlert.show(
        barrierDismissible: false,
        context: context,
        artDialogArgs: ArtDialogArgs(
            denyButtonText: "Cancel",
            title: "Are you sure?",
            text: "User's role will updated as "+newValue,
            confirmButtonText: "Yes",
            type: ArtSweetAlertType.warning
        )
    );

    if(response==null) {
      return;
    }

    if(response.isTapConfirmButton) {
      String result = await apiService.updateRoleOfUser(widget.userDTO.id,newValue);
      print(result);
      if (result == "S") {
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "Role Updated!"
            )
        );
        setState(() {
          _selectedValue = newValue;
          _selectedValueTemp = newValue;
        });
      } else {
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Role Couldn't Updated!"
            )
        );
        setState(() {
          _selectedValue=_selectedValueTemp;
        });
      }

      return;
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    _nameSurnameController.text = widget.userDTO.fullName;
    _usernameController.text = widget.userDTO.username;
    _depController.text=widget.userDTO.department;
    _selectedValue=widget.userDTO.role;
    _selectedValueTemp = widget.userDTO.role;
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
              image: AssetImage('assets/images/students.png'),
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.8,
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
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: TextField(
                            readOnly: true,
                            controller: _nameSurnameController,
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
                              labelText: "Name Surname",
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
                              prefixIcon: Icon(Icons.abc,
                                  color: Constants.mainDarkColor, size: 18),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: TextField(
                            readOnly: true,
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
                            controller: _depController,

                            readOnly: true,
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
                              labelText: "Department",
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
                              prefixIcon: Icon(Icons.collections_bookmark_rounded,
                                  color: Constants.mainDarkColor, size: 18),
                            ),
                          ),
                        ),
                        if(widget.role=='user' && changePass)
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: TextField(
                              controller: _oldpasswordController,
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
                                labelText: "Old Password",
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
                        if(widget.role=='user' && changePass)
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: TextField(
                              controller: _passwordController,
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
                                labelText: "New Password",
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
                        if(widget.role=='user')
                          Padding(
                          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: MaterialButton(
                            onPressed: () async {
                              setState(() {
                                if(!changePass){
                                  changePass = true;
                                }else{
                                  changePassword(context,_passwordController.text,_oldpasswordController.text);
                                }
                              });
                            },
                            color: Constants.mainRedColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text(
                              changePass ? "Save":"Change Password",
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
                        if(widget.role=='lib')
                          DropdownButtonFormField<String>(
                            value: _selectedValue,
                            items: _dropdownItems.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    color: Constants.mainDarkColor,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                                showRoleUpdatePopup(context,newValue.toString());
                            },
                            decoration: InputDecoration(
                              disabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                  color: Constants.mainDarkColor,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                  color: Constants.mainDarkColor,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                  color: Constants.mainDarkColor,
                                  width: 1,
                                ),
                              ),
                              labelText: "Role of User",
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
                                vertical: 8,
                                horizontal: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.emoji_people,
                                color: Constants.mainDarkColor,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_loading)
              Container(
                color: Constants.mainDarkColor.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
