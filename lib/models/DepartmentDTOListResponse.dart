import 'package:json_annotation/json_annotation.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'package:mlmui/models/DepartmentDTO.dart';
import 'UserDTO.dart';
part 'DepartmentDTOListResponse.g.dart';
@JsonSerializable(explicitToJson: true)
class DepartmentDTOListResponse {
  List<DepartmentDTO> departmentDTOList;

  DepartmentDTOListResponse(this.departmentDTOList);

  factory DepartmentDTOListResponse.fromJson(Map<String,dynamic> data) => _$DepartmentDTOListResponseFromJson(data);

  Map<String,dynamic> toJson()=>_$DepartmentDTOListResponseToJson(this);
}
