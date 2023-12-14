// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'OpenLibraryBookDetails.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenLibraryBookDetails _$OpenLibraryBookDetailsFromJson(
        Map<String, dynamic> json) =>
    OpenLibraryBookDetails(
      json['title'] as String?,
      json['full_title'] as String?,
      json['subtitle'] as String?,
      json['notes'] as String?,
      (json['publishers'] as List<dynamic>?)?.map((e) => e as String).toList(),
      json['publish_date'] as String?,
      (json['subjects'] as List<dynamic>?)?.map((e) => e as String).toList(),
      (json['authors'] as List<dynamic>?)
          ?.map(
              (e) => OpenLibraryBookAuthor.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['img'] as String?,
    );

Map<String, dynamic> _$OpenLibraryBookDetailsToJson(
    OpenLibraryBookDetails instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('title', instance.title);
  writeNotNull('full_title', instance.full_title);
  writeNotNull('subtitle', instance.subtitle);
  writeNotNull('notes', instance.notes);
  writeNotNull('publishers', instance.publishers);
  writeNotNull('publish_date', instance.publish_date);
  writeNotNull('subjects', instance.subjects);
  writeNotNull('authors', instance.authors?.map((e) => e.toJson()).toList());
  writeNotNull('img', instance.img);
  return val;
}
