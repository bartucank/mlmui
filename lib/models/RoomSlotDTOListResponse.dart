import 'package:json_annotation/json_annotation.dart';
import 'package:mlmui/models/RoomDTO.dart';
import 'package:mlmui/models/RoomSlotDTO.dart';
import 'UserDTO.dart';
part 'RoomSlotDTOListResponse.g.dart';
@JsonSerializable(explicitToJson: true)
class RoomSlotDTOListResponse {
  List<RoomSlotDTO> roomSlotDTOList;

  RoomSlotDTOListResponse(this.roomSlotDTOList);

  factory RoomSlotDTOListResponse.fromJson(Map<String,dynamic> data) => _$RoomSlotDTOListResponseFromJson(data);

  Map<String,dynamic> toJson()=>_$RoomSlotDTOListResponseToJson(this);
}
