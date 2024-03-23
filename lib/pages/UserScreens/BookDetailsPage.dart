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
      appBar: AppBar(
        backgroundColor: Constants.whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Constants.mainDarkColor,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              PopupMenuItem(
                value: 'about',
                child: Text('About'),
              ),
            ],
            onSelected: (value) {
              // Handle menu item selection ask
            },
          ),
        ],
      ),
      body: SafeArea(
        top: true,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 400.0,
              color: Constants.whiteColor,
            ),
            Positioned(
                top:0,
                left:75,
                right: 75,
                bottom: 120,
                child: Image.memory(
                  width: 150,
                  base64Decode(_base64Image),
                )
            ),
            Positioned(
                top: 300,
                left: 75,
                right: 75,
                height: 100.0,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5,0,0,0),
                      child: Text(
                        widget.book.name??'N/A',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,5,0,0),
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
                  ],
                ),
            ),

            FutureBuilder<UserDTO?>(
              future: CacheManager.getUserDTOFromCache(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.hasError) {
                  return Text("");
                } else if (snapshot.hasData && snapshot.data != null && snapshot.data!.role == "USER") {
                  return Positioned(
                    top: 420,
                    left: 30,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Icon(
                          Icons.star_border,
                          color: Colors.orange,
                        ),
                        Text(
                          'by ${widget.book.averagePoint}'??'',
                          style: TextStyle(
                            fontSize: 15,
                            color: Constants.mainDarkColor,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1, // Adjust the number of lines as needed
                        ),
                        SizedBox(width: 145),
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
                          color: Colors.pink.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Text(
                            widget.book.status=='AVAILABLE'?'Available!':'Click To View Queue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          textColor: Constants.mainRedColor,
                        ),
                        Icon(
                          Icons.favorite_border,
                          color: Colors.red,
                        )
                      ],
                    ),
                  );
                } else {
                  return Text("");
                }
              },
            ),
            Positioned(
                top:500,
                left: 20,
                right: 0,
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Stack(
                          children: [
                            Text(
                              widget.book.description ?? 'N/A',
                              style: TextStyle(
                                fontSize: 15,
                                color: Constants.greyColor,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              maxLines: isExpanded ? null : 4, // Toggle maxLines based on isExpanded
                            ),
                            Positioned(
                              bottom: 0,
                              left: 340,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
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
                      ),
                    ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}


