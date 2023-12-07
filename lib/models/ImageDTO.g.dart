// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ImageDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageDTO _$ImageDTOFromJson(Map<String, dynamic> json) => ImageDTO(
      json['imageData'] as String,
      json['name'] as String,
      json['type'] as String,
      json['id'] as int,
    );

Map<String, dynamic> _$ImageDTOToJson(ImageDTO instance) => <String, dynamic>{
      'imageData': instance.imageData,
      'name': instance.name,
      'type': instance.type,
      'id': instance.id,
    };
