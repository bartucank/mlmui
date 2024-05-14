import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mlmui/service/constants.dart';
import '../models/ShelfDTO.dart';

class ShelfCard extends StatelessWidget {
  final ShelfDTO shelf;

  ShelfCard({required this.shelf});


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
                    Text(book.averagePoint != null?book.averagePoint.toString():"--"'/10'),
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
