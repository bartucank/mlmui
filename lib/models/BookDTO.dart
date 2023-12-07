import 'package:json_annotation/json_annotation.dart';
part 'BookDTO.g.dart';
@JsonSerializable()
class BookDTO {
  int id;
  int shelfId;
  int imageId;
  String isbn;
  String publisher;
  String name;
  String description;
  String author;
  String publicationDateStr;
  String edition;
  String category;
  String categoryStr;
  String status;
  String statusStr;

  BookDTO(
      this.id,
      this.shelfId,
      this.imageId,
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
      this.statusStr);


  factory BookDTO.fromJson(Map<String,dynamic> data) => _$BookDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$BookDTOToJson(this);
}
