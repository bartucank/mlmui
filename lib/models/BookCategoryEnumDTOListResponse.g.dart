// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BookCategoryEnumDTOListResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookCategoryEnumDTOListResponse _$BookCategoryEnumDTOListResponseFromJson(
        Map<String, dynamic> json) =>
    BookCategoryEnumDTOListResponse(
      (json['list'] as List<dynamic>)
          .map((e) => BookCategoryEnumDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BookCategoryEnumDTOListResponseToJson(
        BookCategoryEnumDTOListResponse instance) =>
    <String, dynamic>{
      'list': instance.list.map((e) => e.toJson()).toList(),
    };
