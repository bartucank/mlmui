import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../service/ApiService.dart';
import '../../service/constants.dart';
import 'LoginScreen.dart';

class ForgotPasswordVerifyScreen extends StatefulWidget {
  const ForgotPasswordVerifyScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordVerifyScreen> createState() =>
      _ForgotPasswordVerifyScreenState();
}

class _ForgotPasswordVerifyScreenState
    extends State<ForgotPasswordVerifyScreen> {
  bool codeConf = false;
  final ApiService apiService = ApiService();

  TextEditingController passwordcontroller = TextEditingController();
   String code = "";

  void _handleSuccess() {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: "Verification successful! You can now reset your password.",
        textAlign: TextAlign.left,
      ),
    );
    setState(() {
      codeConf = true;
    });
  }

  void _changePasswordSuccess() {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: "Password is changed.",
        textAlign: TextAlign.left,
      ),
    );
  }

  Future<void> _verifyCode(String code2) async {
    try {
      final response = await apiService.checkCodeForResetPassword(code2);
      if (response) {
        setState(() {
          code = code2;
        });
        _handleSuccess();
      } else {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: "Unexpected error!!!",
            textAlign: TextAlign.left,
          ),
        );
      }
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: e.toString(),
          textAlign: TextAlign.left,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    if (passwordcontroller.text.isNotEmpty) {
      final response = await apiService.completeCodeForResetPassword({
        'code': code,
        'newPassword': passwordcontroller.text,
      });
      if (response['message'] == "Success") {
        _changePasswordSuccess();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      } else {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: response['message'] ?? "Unexpected error!!!",
            textAlign: TextAlign.left,
          ),
        );
      }
    } else {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Please enter a new password!",
          textAlign: TextAlign.left,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Stack(
              alignment: Alignment.topLeft,
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.all(0),
                  padding: EdgeInsets.all(0),
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Constants.mainRedColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
                    child: Text(
                      codeConf == false
                          ? "Verify your reset code"
                          : "Enter new password",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 20,
                        color: Color(0xffffffff),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 80, 0, 0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Image(
                      image: AssetImage('assets/images/mail.png'),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                codeConf == false
                    ? "To reset your password, please enter the code sent to your email."
                    : "Please enter new password.",
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 16,
                  color: Constants.mainDarkColor,
                ),
              ),
            ),
            if (codeConf == false)
              Text(
                "Enter Code here",
                textAlign: TextAlign.start,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  color: Color(0xff545454),
                ),
              ),
            if (codeConf == false)
              Padding(
                padding: EdgeInsets.fromLTRB(30, 16, 30, 50),
                child: OtpTextField(
                  numberOfFields: 4,
                  showFieldAsBox: true,
                  fieldWidth: 50,
                  filled: true,
                  fillColor: Constants.whiteColor,
                  enabledBorderColor: Color(0xffaaaaaa),
                  focusedBorderColor: Constants.mainRedColor,
                  borderWidth: 2,
                  margin: EdgeInsets.all(0),
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  obscureText: false,
                  borderRadius: BorderRadius.circular(8.0),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 20,
                    color: Constants.mainDarkColor,
                  ),
                  onCodeChanged: (String code) {
                    this.code = code;
                  },
                  onSubmit: (String verificationCode) {
                    _verifyCode(verificationCode);
                  },
                ),
              ),
            if (codeConf)
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  controller: passwordcontroller,
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
            if (codeConf)
              Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: MaterialButton(
                  onPressed: () async {
                    await _changePassword();
                  },
                  color: Constants.mainRedColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Change Password",
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
          ],
        ),
      ),
    );
  }
}
