import 'package:json_annotation/json_annotation.dart';
part 'ImageDTO.g.dart';
@JsonSerializable()
class ImageDTO {
  String imageData;
  String name;
  String type;
  int id;

  ImageDTO(this.imageData,
      this.name,
      this.type,
      this.id);

  factory ImageDTO.fromJson(Map<String,dynamic> data) => _$ImageDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$ImageDTOToJson(this);
}
