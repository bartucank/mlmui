// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BookDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookDTO _$BookDTOFromJson(Map<String, dynamic> json) => BookDTO(
      json['id'] as int,
      json['shelfId'] as int,
      json['imageId'] as int,
      json['isbn'] as String,
      json['publisher'] as String,
      json['name'] as String,
      json['description'] as String,
      json['author'] as String,
      json['publicationDateStr'] as String,
      json['edition'] as String,
      json['category'] as String,
      json['categoryStr'] as String,
      json['status'] as String,
      json['statusStr'] as String,
    );

Map<String, dynamic> _$BookDTOToJson(BookDTO instance) => <String, dynamic>{
      'id': instance.id,
      'shelfId': instance.shelfId,
      'imageId': instance.imageId,
      'isbn': instance.isbn,
      'publisher': instance.publisher,
      'name': instance.name,
      'description': instance.description,
      'author': instance.author,
      'publicationDateStr': instance.publicationDateStr,
      'edition': instance.edition,
      'category': instance.category,
      'categoryStr': instance.categoryStr,
      'status': instance.status,
      'statusStr': instance.statusStr,
    };
