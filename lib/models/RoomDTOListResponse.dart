import 'package:json_annotation/json_annotation.dart';
import 'package:mlmui/models/RoomDTO.dart';

part 'RoomDTOListResponse.g.dart';
@JsonSerializable(explicitToJson: true)
class RoomDTOListResponse {

  List<RoomDTO> roomDTOList;

  RoomDTOListResponse(this.roomDTOList);

  factory RoomDTOListResponse.fromJson(Map<String,dynamic> data) => _$RoomDTOListResponseFromJson(data);

  Map<String,dynamic> toJson()=>_$RoomDTOListResponseToJson(this);
}
