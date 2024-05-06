import 'package:json_annotation/json_annotation.dart';
part 'CourseStudentDTO.g.dart';

@JsonSerializable(includeIfNull: false)
class CourseStudentDTO {
  int? id;
  String? studentNumber;
  String? studentId;
  String? studentNmae;


  CourseStudentDTO(
      this.id,
      this.studentNumber,
      this.studentId,
      this.studentNmae,
      );


  factory CourseStudentDTO.fromJson(Map<String,dynamic> data) => _$CourseStudentDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$CourseStudentDTOToJson(this);
}