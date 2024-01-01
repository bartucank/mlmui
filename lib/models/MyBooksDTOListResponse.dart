import 'package:json_annotation/json_annotation.dart';
import 'MyBooksDTO.dart';

part 'MyBooksDTOListResponse.g.dart';

@JsonSerializable(explicitToJson: true)
class MyBooksDTOListResponse{

  List<MyBooksDTO> myBooksDTOList;

  MyBooksDTOListResponse(this.myBooksDTOList);

  factory MyBooksDTOListResponse.fromJson(Map<String,dynamic> data) => _$MyBooksDTOListResponseFromJson(data);

  Map<String,dynamic> toJson()=>_$MyBooksDTOListResponseToJson(this);
}