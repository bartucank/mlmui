import 'package:json_annotation/json_annotation.dart';
part 'RoomDTO.g.dart';
@JsonSerializable(includeIfNull: false)
class RoomDTO {
  int? id;
  int? imageId;
  String? name;

  RoomDTO(
      this.id,
      this.imageId,
      this.name);


  factory RoomDTO.fromJson(Map<String,dynamic> data) => _$RoomDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$RoomDTOToJson(this);
}
