import 'package:json_annotation/json_annotation.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'UserDTO.dart';
part 'BookDTOListResponse.g.dart';
@JsonSerializable(explicitToJson: true)
class BookDTOListResponse {
  List<BookDTO> bookDTOList;
  int totalPage;

  BookDTOListResponse(this.bookDTOList,this.totalPage);

  factory BookDTOListResponse.fromJson(Map<String,dynamic> data) => _$BookDTOListResponseFromJson(data);

  Map<String,dynamic> toJson()=>_$BookDTOListResponseToJson(this);
}
