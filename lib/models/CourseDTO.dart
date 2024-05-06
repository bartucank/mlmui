import 'package:json_annotation/json_annotation.dart';
import 'package:mlmui/models/CourseMaterialDTO.dart';
import 'package:mlmui/models/CourseStudentDTO.dart';
part 'CourseDTO.g.dart';

@JsonSerializable(includeIfNull: false)
class CourseDTO {
  int? id;
  String? name;
  int? lecturerId;
  String? lecturerName;
  bool? isPublic;
  int? imageId;
  List<CourseMaterialDTO>? courseMaterialDTOList;
  List<CourseStudentDTO>? courseStudentDTOList;


  CourseDTO(
      this.id,
      this.name,
      this.lecturerId,
      this.lecturerName,
      this.isPublic,
      this.imageId,
      this.courseMaterialDTOList,
      this.courseStudentDTOList
      );


  factory CourseDTO.fromJson(Map<String,dynamic> data) => _$CourseDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$CourseDTOToJson(this);
}