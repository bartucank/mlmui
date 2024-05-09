import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:mlmui/models/ReceiptHistoryDTO.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../service/ApiService.dart';
import '../../service/constants.dart';

class ReceiptPopUp extends StatefulWidget {
  final ReceiptHistoryDTO receipt; // Receipt object

  const ReceiptPopUp({Key? key, required this.receipt}) : super(key: key);


  @override
  State<ReceiptPopUp> createState() => _ReceiptPopUpState();
}

class _ReceiptPopUpState extends State<ReceiptPopUp> {

  final ApiService apiService = ApiService();
  bool isLoading = false;
  late String _base64Image;

  final TextEditingController _balanceController = TextEditingController();
  bool _isBalanceValid = true;

  @override
  void initState() {
    super.initState();
    _fetchImage();
    _balanceController.addListener(_validateBalance);
    if(widget.receipt.approved!){
      _balanceController.text=widget.receipt.balance.toString()+" ₺";
    }
  }
  bool isExpanded = false;


  Future<void> _fetchImage() async {
    try {
      String base64Image = await getImageBase64(widget.receipt.imgId);

      if (base64Image != "1") {
        setState(() {
          _base64Image = base64Image;
        });
      } else {
        print("Image not found");
      }
    } catch (error) {
      print("Error fetching image: $error");
    }
  }

  static Future<String> getImageBase64(int? imageId) async {
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
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  void _validateBalance() {
    final enteredValue = _balanceController.text;
    setState(() {
      _isBalanceValid = double.tryParse(enteredValue) != null && double.parse(enteredValue) > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context); // Close the popup
            },
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 100,
            height: 140,
            child: InstaImageViewer(
              child: Image(
                image: Image.memory(base64Decode(_base64Image)).image,
              ),
            ),
          ),
          Center(child: Text("You can click to zoom",style: TextStyle(fontSize: 10),)),
          if(widget.receipt.approved!)
            TextField(
              controller: _balanceController,
              readOnly: widget.receipt.approved!,
              decoration: InputDecoration(
                labelText: widget.receipt.approved!?"Approved Balance":"",
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              ///keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          if(!widget.receipt.approved!)
            TextField(
              controller: _balanceController,
              readOnly: widget.receipt.approved!,

              decoration: InputDecoration(
                hintText: 'Enter balance',
                errorText: _isBalanceValid ? null : 'Please enter a positive integer',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              ///keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),

            SizedBox(height: 16),

          if(!widget.receipt.approved!)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _isBalanceValid
                    ? () async {
                  // Accept button pressed
                  final double balance = double.parse(_balanceController.text);
                  String result =  await apiService.approveReceipt(balance, widget.receipt.id as int);
                  print(result);
                  if (result == "S") {
                    Navigator.pop(context); // Close the popup
                    ArtSweetAlert.show(
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.success,
                            title: "Balance Added!"
                        )
                    );
                  } else {
                    Navigator.pop(context); // Close the popup
                    ArtSweetAlert.show(
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.danger,
                            title: "Balance Couldn't Added!"
                        )
                    );
                    /*setState(() {
                  _selectedValue=_selectedValueTemp;
                  });*/
                  }
                  }
                : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('Accept'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Reject button pressed
                  String result =  await apiService.rejectReceipt(widget.receipt.id as int);
                  print(result);
                  if (result == "S") {
                    Navigator.pop(context); // Close the popup
                    ArtSweetAlert.show(
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.success,
                            title: "Receipt Rejected and Deleted Successfully!"
                        )
                    );
                  } else {
                    Navigator.pop(context); // Close the popup
                    ArtSweetAlert.show(
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.danger,
                            title: "Problem Occurred, Receipt Couldn't Rejected!"
                        )
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
