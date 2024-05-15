import 'package:flutter/material.dart';
import 'package:mlmui/models/CourseMaterialDTO.dart';
import 'package:mlmui/models/UserDTO.dart';

class MaterialCard extends StatelessWidget {
  final CourseMaterialDTO item;

  MaterialCard({required this.item});

  @override
  Widget build(BuildContext context) {

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      title: Text(item.name!),
      leading: Icon(Icons.book),
    );

  }
}