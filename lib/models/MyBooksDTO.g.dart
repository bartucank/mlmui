// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MyBooksDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyBooksDTO _$MyBooksDTOFromJson(Map<String, dynamic> json) => MyBooksDTO(
      BookDTO.fromJson(json['book'] as Map<String, dynamic>),
      json['days'] as int,
      json['isLate'] as bool,
    );

Map<String, dynamic> _$MyBooksDTOToJson(MyBooksDTO instance) =>
    <String, dynamic>{
      'book': instance.book,
      'days': instance.days,
      'isLate': instance.isLate,
    };
