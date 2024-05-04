import 'package:json_annotation/json_annotation.dart';
import 'package:mlmui/models/CourseDTO.dart';
part 'CourseDTOListResponse.g.dart';
@JsonSerializable(explicitToJson: true)
class CourseDTOListResponse {
  List<CourseDTO> courseDTOList;

  CourseDTOListResponse(this.courseDTOList);

  factory CourseDTOListResponse.fromJson(Map<String,dynamic> data) => _$CourseDTOListResponseFromJson(data);

  Map<String,dynamic> toJson()=>_$CourseDTOListResponseToJson(this);
}