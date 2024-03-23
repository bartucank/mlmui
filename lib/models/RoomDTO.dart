import 'package:json_annotation/json_annotation.dart';
part 'RoomDTO.g.dart';
@JsonSerializable(includeIfNull: false)
class RoomDTO {
  int? id;
  int? imageId;
  String? name;
  String? nfc_no;
  int? qrImage;

  RoomDTO(
      this.id,
      this.imageId,
      this.name,this.nfc_no, this.qrImage);


  factory RoomDTO.fromJson(Map<String,dynamic> data) => _$RoomDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$RoomDTOToJson(this);
}
