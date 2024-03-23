import 'package:json_annotation/json_annotation.dart';
part 'RoomDTO.g.dart';

@JsonSerializable(includeIfNull: false)
class RoomDTO{
  int? id;
  String? name;
  int? imageId;

  RoomDTO(
      this.id,
      this.name,
      this.imageId
      );

  factory RoomDTO.fromJson(Map<String,dynamic> data) => _$RoomDTOFromJson(data);

  Map<String,dynamic> toJson() => _$RoomDTOToJson(this);
}
