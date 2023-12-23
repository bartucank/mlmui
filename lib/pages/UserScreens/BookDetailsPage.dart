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
      final response = await http.get(Uri.parse('${Constants.apiBaseUrl}/api/user/getImageBase64ById?id=$imageId'));

      if (response.statusCode == 200) {
        String base64 = base64Encode(response.bodyBytes);
        prefs.setString(imageId.toString(), base64);
        return base64;
      } else {
        return"1";
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Image.memory(
              base64Decode(_base64Image),
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: widget.book.name),
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Name",
                prefixIcon: Icon(Icons.book, color: Color(0xff212435), size: 18),
              ),
            ),
            TextField(
              controller: TextEditingController(text: widget.book.description),
              readOnly: true,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description",
                prefixIcon: Icon(Icons.book, color: Color(0xff212435), size: 18),
              ),
            ),
            TextField(
              controller: TextEditingController(text: widget.book.publisher),
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Publisher",
                prefixIcon: Icon(Icons.publish, color: Color(0xff212435), size: 18),
              ),
            ),
            TextField(
              controller: TextEditingController(text: widget.book.author),
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Author",
                prefixIcon: Icon(Icons.person, color: Color(0xff212435), size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Book {
  final String name;
  final String author;
  final String description;
  final String publisher;
  final String isbn;
  final String publishDate;
  final ShelfDTO shelf;
  final BookCategoryEnumDTO category;

  Book({
    required this.name,
    required this.author,
    required this.description,
    required this.publisher,
    required this.isbn,
    required this.publishDate,
    required this.shelf,
    required this.category,
  });
}
