// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BookDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookDTO _$BookDTOFromJson(Map<String, dynamic> json) => BookDTO(
      json['id'] as int?,
      json['shelfId'] as int?,
      json['imageId'] as int?,
      json['isbn'] as String?,
      json['publisher'] as String?,
      json['name'] as String?,
      json['description'] as String?,
      json['author'] as String?,
      json['publicationDateStr'] as String?,
      json['edition'] as String?,
      json['category'] as String?,
      json['categoryStr'] as String?,
      json['status'] as String?,
      json['statusStr'] as String?,
    );

Map<String, dynamic> _$BookDTOToJson(BookDTO instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('shelfId', instance.shelfId);
  writeNotNull('imageId', instance.imageId);
  writeNotNull('isbn', instance.isbn);
  writeNotNull('publisher', instance.publisher);
  writeNotNull('name', instance.name);
  writeNotNull('description', instance.description);
  writeNotNull('author', instance.author);
  writeNotNull('publicationDateStr', instance.publicationDateStr);
  writeNotNull('edition', instance.edition);
  writeNotNull('category', instance.category);
  writeNotNull('categoryStr', instance.categoryStr);
  writeNotNull('status', instance.status);
  writeNotNull('statusStr', instance.statusStr);
  return val;
}