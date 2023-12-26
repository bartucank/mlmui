import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'package:mlmui/service/ApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      body: Column(
        children: <Widget>[
          Stack(children: [
            Container(
              height: MediaQuery.of(context).size.height / 4,
              color: Color(0xffd2232a),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15,15,0,0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.memory(
                  base64Decode(_base64Image),
                  width: 150,
                  height: 200,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(180,25,0,0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (widget.book.name!.length < 22
                            ? widget.book.name
                            : widget.book.name!.substring(0, 22) +
                            "...") ??
                            'N/A',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Author
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,7,0,0),
                        child: Text(
                          'by ${(widget.book.author!.length < 20 ? widget.book.author : widget.book.author!.substring(0, 17) + "...") ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Publisher
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,7,0,0),
                        child: Text(
                          (widget.book.publisher!.length < 20
                              ? widget.book.publisher
                              : widget.book.publisher!
                              .substring(0, 17) +
                              "...") ??
                              'N/A',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,7,0,0),
                        child: Text(
                          (widget.book.category!.length < 20
                              ? widget.book.category
                              : widget.book.category!
                              .substring(0, 17) +
                              "...") ??
                              'N/A',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            )

          ],),
          Padding(
            padding: const EdgeInsets.fromLTRB(16,15,0,0),
            child: Column(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(

                      'Description ' + (widget.book.name! != null ? 'of '+widget.book.name! : '') ,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      widget.book.description ?? 'N/A',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )


        ],
      ),
    );
  }
}


