import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mlmui/service/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/BookDTO.dart';

class BookCard extends StatelessWidget {
  final BookDTO book;

  BookCard({required this.book});

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
      future: getImageBase64(book.imageId!),
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
                title: Text(book.name!,overflow: TextOverflow.ellipsis,),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star,color: Constants.yellowColor,),
                    SizedBox(width: 4),
                    Text(book.averagePoint != null?book.averagePoint!.toStringAsFixed(2).toString():"--"'/10'),
                  ],
                ),
                subtitle: Text(book.category!),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0), //or 15.0
                  child: Container(
                    color: Colors.white,
                    child: Image(

                      image: MemoryImage(
                        base64Decode(base64Image),
                      ),
                    ),
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
