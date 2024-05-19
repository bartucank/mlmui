
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../service/ApiService.dart';
import '../../service/constants.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({Key? key}) : super(key: key);

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {

  final ApiService apiService = ApiService();
  void ok(){
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: "Your account verified!",
        textAlign: TextAlign.left,
      ),
    );
    Navigator.pushReplacementNamed(context, "/login");
  }
  Future<void> _verify(String code) async {

    apiService.verifyRequest(code).then((value) => {
      if (value['message'] == "Success")
        {
          ok()
        }
      else if (value['error'] == "Unauthorized")
        {
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.info(
              message: "Unauthorized user. Please restart application.",
              textAlign: TextAlign.left,
            ),
          )
        }
      else
        {
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(
              message: value['message'],
              textAlign: TextAlign.left,
            ),
          )
        }
    });
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
                      "Verify your account",
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
                    child:

                    Image(
                      image: AssetImage(
                          'assets/images/mail.png'),
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
                "To verify your account, please enter the code that is sent your metu mail account.",
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
            Padding(
              padding: EdgeInsets.fromLTRB(30, 16, 30, 50),
              child: OtpTextField(
                numberOfFields: 4,
                showFieldAsBox: true,
                fieldWidth: 50,
                filled: true,
                fillColor: Constants.mainDarkColor,
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
                onCodeChanged: (String code) {},
                onSubmit: (String verificationCode){
                  _verify(verificationCode);
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
