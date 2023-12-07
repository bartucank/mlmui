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

  Future<String> _getImageBase64(int imageId) async {
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
        throw Exception('Resim alınamadı: HTTP ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getImageBase64(book.imageId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('');
        } else {
          String base64Image = snapshot.data!;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
            title: Text(book.name),
            subtitle: Text(book.category),
            leading: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white,
              backgroundImage: MemoryImage(
                base64Decode(base64Image),
              ),
            ),
          );
        }
      },
    );



  }
}
