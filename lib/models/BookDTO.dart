import 'package:json_annotation/json_annotation.dart';
import 'package:mlmui/models/BookReviewDTO.dart';
part 'BookDTO.g.dart';
@JsonSerializable(includeIfNull: false)
class BookDTO {
  int? id;
  int? shelfId;
  int? imageId;
  int? ebookId;
  String? isbn;
  String? publisher;
  String? name;
  String? description;
  String? author;
  String? publicationDateStr;
  String? edition;
  String? category;
  String? categoryStr;
  String? status;
  String? statusStr;
  double? averagePoint;
  BookReviewDTO? reviewDTO;
  List<BookReviewDTO>? allReviews;


  BookDTO(
      this.id,
      this.shelfId,
      this.imageId,
      this.ebookId,
      this.isbn,
      this.publisher,
      this.name,
      this.description,
      this.author,
      this.publicationDateStr,
      this.edition,
      this.category,
      this.categoryStr,
      this.status,
      this.statusStr,
      this.averagePoint,
      this.reviewDTO,
      this.allReviews
      );


  factory BookDTO.fromJson(Map<String,dynamic> data) => _$BookDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$BookDTOToJson(this);
}
