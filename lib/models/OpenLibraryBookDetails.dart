import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

import 'OpenLibraryBookAuthor.dart';
part 'OpenLibraryBookDetails.g.dart';

@JsonSerializable(explicitToJson: true,includeIfNull: false)
class OpenLibraryBookDetails {
  String? title;
  String? full_title;
  String? subtitle;
  String? notes;
  List<String>? publishers;
  String? publish_date;
  List<String>? subjects;
  List<OpenLibraryBookAuthor>? authors;
  String? img;

  OpenLibraryBookDetails(this.title, this.full_title, this.subtitle, this.notes,
      this.publishers, this.publish_date, this.subjects, this.authors,this.img);


  factory OpenLibraryBookDetails.fromJson(Map<String,dynamic> data) => _$OpenLibraryBookDetailsFromJson(data);

  Map<String,dynamic> toJson()=>_$OpenLibraryBookDetailsToJson(this);
}
