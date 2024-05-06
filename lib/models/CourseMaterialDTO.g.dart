// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CourseMaterialDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseMaterialDTO _$CourseMaterialDTOFromJson(Map<String, dynamic> json) =>
    CourseMaterialDTO(
      json['id'] as int?,
      json['name'] as String?,
      json['data'] as String?,
      json['fileName'] as String?,
      json['extension'] as String?,
    );

Map<String, dynamic> _$CourseMaterialDTOToJson(CourseMaterialDTO instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('data', instance.data);
  writeNotNull('fileName', instance.fileName);
  writeNotNull('extension', instance.extension);
  return val;
}
