import 'package:json_annotation/json_annotation.dart';
part 'CourseMaterialDTO.g.dart';

@JsonSerializable(includeIfNull: false)
class CourseMaterialDTO {
  int? id;
  String? name;
  String? data;
  String? fileName;
  String? extension;


  CourseMaterialDTO(
      this.id,
      this.name,
      this.data,
      this.fileName,
      this.extension,
      );


  factory CourseMaterialDTO.fromJson(Map<String,dynamic> data) => _$CourseMaterialDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$CourseMaterialDTOToJson(this);
}