import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/RoomDTO.dart';

class RoomItem extends StatelessWidget {
  final String base64Image;
  RoomDTO roomDTO;

  RoomItem({required this.base64Image, required this.roomDTO});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.memory(
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.width / 2,
                base64Decode(base64Image),
              ),
          ),

          Container(
            margin: const EdgeInsets.all(0),
            padding: const EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width/2,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: const Color(0x6e000000),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          Text(
            roomDTO.name!,
            textAlign: TextAlign.center,
            overflow: TextOverflow.clip,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              fontSize: 22,
              color: Color(0xffffffff),
            ),
          ),
        ],
      ),
    );
  }
}