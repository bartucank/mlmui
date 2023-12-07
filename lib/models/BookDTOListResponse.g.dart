// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BookDTOListResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookDTOListResponse _$BookDTOListResponseFromJson(Map<String, dynamic> json) =>
    BookDTOListResponse(
      (json['bookDTOList'] as List<dynamic>)
          .map((e) => BookDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['totalPage'] as int,
    );

Map<String, dynamic> _$BookDTOListResponseToJson(
        BookDTOListResponse instance) =>
    <String, dynamic>{
      'bookDTOList': instance.bookDTOList.map((e) => e.toJson()).toList(),
      'totalPage': instance.totalPage,
    };
