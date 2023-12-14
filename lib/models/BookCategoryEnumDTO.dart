import 'package:json_annotation/json_annotation.dart';
part 'BookCategoryEnumDTO.g.dart';
@JsonSerializable()
class BookCategoryEnumDTO {

  String str;
  String enumValue;

  BookCategoryEnumDTO(this.str, this.enumValue);

  factory BookCategoryEnumDTO.fromJson(Map<String,dynamic> data) => _$BookCategoryEnumDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$BookCategoryEnumDTOToJson(this);
}
