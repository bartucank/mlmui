import 'package:json_annotation/json_annotation.dart';
part 'BookReviewDTO.g.dart';
@JsonSerializable(includeIfNull: false)

class BookReviewDTO{
  int? userId;
  int? star;
  String? comment;

  BookReviewDTO(
      this.userId,
      this.star,
      this.comment
      );

  factory BookReviewDTO.fromJson(Map<String,dynamic> data) => _$BookReviewDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$BookReviewDTOToJson(this);
}
