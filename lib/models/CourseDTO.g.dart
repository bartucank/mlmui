// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CourseDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseDTO _$CourseDTOFromJson(Map<String, dynamic> json) => CourseDTO(
      json['id'] as int?,
      json['name'] as String?,
      json['lecturerId'] as int?,
      json['lecturerName'] as String?,
      json['isPublic'] as bool?,
      json['imageId'] as int?,
      (json['courseMaterialDTOList'] as List<dynamic>?)
          ?.map((e) => CourseMaterialDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['courseStudentDTOList'] as List<dynamic>?)
          ?.map((e) => CourseStudentDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CourseDTOToJson(CourseDTO instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('lecturerId', instance.lecturerId);
  writeNotNull('lecturerName', instance.lecturerName);
  writeNotNull('isPublic', instance.isPublic);
  writeNotNull('imageId', instance.imageId);
  writeNotNull('courseMaterialDTOList', instance.courseMaterialDTOList);
  writeNotNull('courseStudentDTOList', instance.courseStudentDTOList);
  return val;
}
