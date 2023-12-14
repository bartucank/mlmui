import 'package:json_annotation/json_annotation.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'ShelfDTO.dart';
import 'UserDTO.dart';
part 'ShelfDTOListResponse.g.dart';
@JsonSerializable(explicitToJson: true)
class ShelfDTOListResponse {
  List<ShelfDTO> shelfDTOList;

  ShelfDTOListResponse(this.shelfDTOList);

  factory ShelfDTOListResponse.fromJson(Map<String,dynamic> data) => _$ShelfDTOListResponseFromJson(data);

  Map<String,dynamic> toJson()=>_$ShelfDTOListResponseToJson(this);
}
