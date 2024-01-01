import 'package:json_annotation/json_annotation.dart';
import 'package:mlmui/models/BookDTO.dart';
part 'MyBooksDTO.g.dart';

@JsonSerializable(includeIfNull: true)
class MyBooksDTO{
  BookDTO book;
  int days;
  bool isLate;

  MyBooksDTO(this.book, this.days, this.isLate);

  factory MyBooksDTO.fromJson(Map<String,dynamic> data) => _$MyBooksDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$MyBooksDTOToJson(this);

}