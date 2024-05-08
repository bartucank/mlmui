import 'package:json_annotation/json_annotation.dart';
import 'package:mlmui/models/BookReviewDTO.dart';
part 'DepartmentDTO.g.dart';
@JsonSerializable(includeIfNull: false)
class DepartmentDTO {
  String? department;
  String? departmentString;


  DepartmentDTO(
     this.department,
      this.departmentString
      );


  factory DepartmentDTO.fromJson(Map<String,dynamic> data) => _$DepartmentDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$DepartmentDTOToJson(this);
}
