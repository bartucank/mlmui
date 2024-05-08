// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DepartmentDTOListResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepartmentDTOListResponse _$DepartmentDTOListResponseFromJson(
        Map<String, dynamic> json) =>
    DepartmentDTOListResponse(
      (json['departmentDTOList'] as List<dynamic>)
          .map((e) => DepartmentDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DepartmentDTOListResponseToJson(
        DepartmentDTOListResponse instance) =>
    <String, dynamic>{
      'departmentDTOList':
          instance.departmentDTOList.map((e) => e.toJson()).toList(),
    };
