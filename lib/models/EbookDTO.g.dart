// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'EbookDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EbookDTO _$EbookDTOFromJson(Map<String, dynamic> json) => EbookDTO(
      json['id'] as int?,
      json['data'] as String?,
      json['name'] as String?,
      json['type'] as String?,
    );

Map<String, dynamic> _$EbookDTOToJson(EbookDTO instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('data', instance.data);
  writeNotNull('name', instance.name);
  writeNotNull('type', instance.type);
  return val;
}
