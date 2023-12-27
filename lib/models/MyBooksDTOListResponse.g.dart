// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MyBooksDTOListResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyBooksDTOListResponse _$MyBooksDTOListResponseFromJson(
        Map<String, dynamic> json) =>
    MyBooksDTOListResponse(
      (json['myBooksDTOList'] as List<dynamic>)
          .map((e) => MyBooksDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MyBooksDTOListResponseToJson(
        MyBooksDTOListResponse instance) =>
    <String, dynamic>{
      'myBooksDTOList': instance.myBooksDTOList.map((e) => e.toJson()).toList(),
    };
