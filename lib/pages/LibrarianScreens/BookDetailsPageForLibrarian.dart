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

import '../../models/UserDTO.dart';
import '../../service/CacheManager.dart';
import '../../service/constants.dart';
import '../../mlm_icons_icons.dart';
class BookDetailsPageForLibrarian extends StatefulWidget {
  final BookDTO book;

  const BookDetailsPageForLibrarian({Key? key, required this.book}) : super(key: key);

  @override
  State<BookDetailsPageForLibrarian> createState() => _BookDetailsPageForLibrarianState();
}

class _BookDetailsPageForLibrarianState extends State<BookDetailsPageForLibrarian> {

  final ApiService apiService = ApiService();
  bool isLoading = false;
  late String _base64Image;
  @override
  void initState() {
    super.initState();
    _fetchImage();
  }
  bool isExpanded = false;


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

        backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: MediaQuery.of(context).size.height/2.3,
              color: Constants.whiteColor,
            ),
            Center(
              child: Column(
                children: [

                  Image.memory(
                    height: (MediaQuery.of(context).size.height/2.3)/1.4,
                    base64Decode(_base64Image),
                  ),
                  SizedBox(height: 5,),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15,0,15,0),
                    child: Text(
                      widget.book.name??'N/A',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15,2,15,0),
                    child: Text(
                      'by ${widget.book.author?.toUpperCase()}'??'',
                      style: TextStyle(
                        fontSize: 15,
                        color: Constants.greyColor,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Adjust the number of lines as needed
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Constants.yellowColor,
                      ),
                      if(widget.book.averagePoint != null)
                        Text(
                          widget.book.averagePoint!.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            color: Constants.mainDarkColor,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1, // Adjust the number of lines as needed
                        ),
                      if(widget.book.averagePoint == null)
                        Text(
                          "-",
                          style: TextStyle(
                            fontSize: 15,
                            color: Constants.mainDarkColor,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1, // Adjust the number of lines as needed
                        ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Text(
                                  widget.book.description ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                  maxLines: isExpanded ? null : 4, // Toggle maxLines based on isExpanded
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        print("za");
                                        isExpanded = !isExpanded;
                                      });
                                    },
                                    child: Text(
                                      isExpanded ? 'Less' : 'More',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red, // Use the theme's primary color
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),


          ],
        ),
      )
    );
  }
}


