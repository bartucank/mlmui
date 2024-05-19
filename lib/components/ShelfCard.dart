import 'package:flutter/material.dart';
import '../models/ShelfDTO.dart';

class ShelfCard extends StatelessWidget {
  final ShelfDTO shelf;

  ShelfCard({required this.shelf});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        title: Text('Shelf ID: ${shelf.id}', overflow: TextOverflow.ellipsis,),
        subtitle: Text('Floor: ${shelf.floor}'),
      ),
    );
  }
}
