// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DepartmentDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepartmentDTO _$DepartmentDTOFromJson(Map<String, dynamic> json) =>
    DepartmentDTO(
      json['department'] as String?,
      json['departmentString'] as String?,
    );

Map<String, dynamic> _$DepartmentDTOToJson(DepartmentDTO instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('department', instance.department);
  writeNotNull('departmentString', instance.departmentString);
  return val;
}
