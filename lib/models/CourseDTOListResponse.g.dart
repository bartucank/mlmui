// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CourseDTOListResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseDTOListResponse _$CourseDTOListResponseFromJson(
        Map<String, dynamic> json) =>
    CourseDTOListResponse(
      (json['courseDTOList'] as List<dynamic>)
          .map((e) => CourseDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CourseDTOListResponseToJson(
        CourseDTOListResponse instance) =>
    <String, dynamic>{
      'courseDTOList': instance.courseDTOList.map((e) => e.toJson()).toList(),
    };
