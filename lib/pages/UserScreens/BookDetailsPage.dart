import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'package:mlmui/pages/UserScreens/Queue.dart';
import 'package:mlmui/service/ApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/BookCategoryEnumDTO.dart';
import '../../models/ShelfDTO.dart';
import 'package:http/http.dart' as http;

import '../../service/constants.dart';

class BookDetailsPage extends StatefulWidget {
  final BookDTO book;

  const BookDetailsPage({Key? key, required this.book}) : super(key: key);

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final ApiService apiService = ApiService();
  bool isLoading = false;
  late String _base64Image;
  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  Future<void> _fetchImage() async {
    try {
      String base64Image = await getImageBase64(widget.book.imageId);

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffd2232a),
        title: Text('Book Details'),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        top: true,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 200.0,
              color: Color(0xffd2232a),
            ),
            Positioned(
              bottom: -25.0,
              left: 15,
              width: 150,
              height: 200.0,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.memory(
                      base64Decode(_base64Image),
                       fit: BoxFit.cover,
                    ),
                  ),

                ],
              ),
            ),
            Positioned(
              top: 55,
              left: 170,
              width: MediaQuery.of(context).size.width /2 +10,
              height: 100.0,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5,0,0,0),
                    child: Text(
                      widget.book.name??'N/A',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Adjust the number of lines as needed
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0,0),
                    child: Text(
                      'by ${widget.book.author?.toUpperCase()}'??'',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2, // Adjust the number of lines as needed
                    ),
                  ),

                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: widget.book.status=='AVAILABLE'?(MediaQuery.of(context).size.width/2):(MediaQuery.of(context).size.width/2)-10,
              width: 200.0,
              height: 50.0,
              child: Row(
                children: [
                  MaterialButton(
                    onPressed: () {
                      if(widget.book.status=='AVAILABLE'){
                        //popup
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.success(
                            message: "You can borrow the book by going to the librarian :)",
                            textAlign: TextAlign.left,
                          ),
                        );
                      }else{
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QueueUser(
                                book: widget.book),
                          ),
                        );
                      }
                    },
                    color: Color(0xfffafafa),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(22.0)),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Text(
                      widget.book.status=='AVAILABLE'?'Book is Available!':'Click To View Queue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    textColor: Color(0xffd2232a),
                    height: 50,
                  ),

                ],
              ),
            ),
            Positioned(
              bottom: -120.0,
              left: 20,
              width: 200.0,
              height: 65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Description ' ,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              ),
            ),
            Positioned(
              bottom: -240.0,
              left: 20,
              width: MediaQuery.of(context).size.width-40,
              height: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    readOnly: true,
                    textAlign: TextAlign.start,
                    maxLines: 9,
                    controller: TextEditingController(
                        text:
                        (widget.book.author!= null &&
                            widget.book.publisher!=null &&
                            widget.book.name != null &&
                            widget.book.description != null)
                            ?
                        widget.book.name! + ' is written by '+widget.book.author! + ' and published by '+ widget.book.publisher! + '.\n\n' + widget.book.description!
                            :''
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    decoration: InputDecoration(
                      disabledBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: BorderSide(color: Color(0xff000000), width: 1),
                      ),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 16,
                        color: Color(0xff000000),
                      ),
                      filled: true,
                      fillColor: Color(0x00ffffff),
                      isDense: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      prefixIcon: Icon(Icons.book, color: Color(0xff212435), size: 12),
                    ),
                  ),

                ],
              ),
            ),
          ],
        )
      )
    );
  }
}


