import 'package:json_annotation/json_annotation.dart';
part 'RoomSlotDTO.g.dart';
@JsonSerializable(includeIfNull: false)
class RoomSlotDTO {
  int? id;
  String? startHour;
  String? endHour;
  String? day;
  bool? available;
  int? dayInt;

  RoomSlotDTO(
      this.id,
      this.startHour,
      this.endHour,
      this.day,
      this.available,
      this.dayInt);


  factory RoomSlotDTO.fromJson(Map<String,dynamic> data) => _$RoomSlotDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$RoomSlotDTOToJson(this);
}
