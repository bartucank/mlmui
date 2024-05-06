// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CourseStudentDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseStudentDTO _$CourseStudentDTOFromJson(Map<String, dynamic> json) =>
    CourseStudentDTO(
      json['id'] as int?,
      json['studentNumber'] as String?,
      json['studentId'] as String?,
      json['studentNmae'] as String?,
    );

Map<String, dynamic> _$CourseStudentDTOToJson(CourseStudentDTO instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('studentNumber', instance.studentNumber);
  writeNotNull('studentId', instance.studentId);
  writeNotNull('studentNmae', instance.studentNmae);
  return val;
}
