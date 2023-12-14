import 'package:json_annotation/json_annotation.dart';

import 'BookCategoryEnumDTO.dart';
part 'BookCategoryEnumDTOListResponse.g.dart';
@JsonSerializable(explicitToJson: true)
class BookCategoryEnumDTOListResponse {

  List<BookCategoryEnumDTO> list;

  BookCategoryEnumDTOListResponse(this.list);

  factory BookCategoryEnumDTOListResponse.fromJson(Map<String,dynamic> data) => _$BookCategoryEnumDTOListResponseFromJson(data);

  Map<String,dynamic> toJson()=>_$BookCategoryEnumDTOListResponseToJson(this);
}
