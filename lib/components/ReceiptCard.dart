import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mlmui/service/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ReceiptHistoryDTO.dart';

class ReceiptCard extends StatelessWidget {
  final ReceiptHistoryDTO receipt;

  ReceiptCard({required this.receipt});

  static Future<String> getImageBase64(int imageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString(imageId.toString());

    if (base64Image != null) {
      return base64Image;
    } else {
      final response = await http.get(Uri.parse(
          '${Constants.apiBaseUrl}/api/user/getImageBase64ById?id=$imageId'));

      if (response.statusCode == 200) {
        String base64 = base64Encode(response.bodyBytes);
        prefs.setString(imageId.toString(), base64);
        return base64;
      } else {
        return "1";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getImageBase64(receipt.imgId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return CircularProgressIndicator();
        } else {
          String base64Image = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                title: Text("Receipt ${receipt.id.toString()!}",overflow: TextOverflow.ellipsis,),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(receipt.approved == true?Icons.done:Icons.flaky
                      ,color: receipt.approved == true?Colors.green:Constants.mainRedColor,),
                    SizedBox(width: 4),
                    Text(receipt.approved == true?"Approved":"Not Approved"),
                  ],
                ),
                ///subtitle: Text(receipt.approved == true?"Approved":"Not Approved"),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0), //or 15.0
                  child: Container(
                    color: Colors.white,
                    child: Icon(Icons.receipt, color: Constants.mainDarkColor,),
                    /*Image(

                      image: MemoryImage(
                        base64Decode(base64Image),
                      ),
                    ),*/
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
