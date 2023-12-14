// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'OpenLibraryBookAuthor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenLibraryBookAuthor _$OpenLibraryBookAuthorFromJson(
        Map<String, dynamic> json) =>
    OpenLibraryBookAuthor(
      json['key'] as String?,
    );

Map<String, dynamic> _$OpenLibraryBookAuthorToJson(
    OpenLibraryBookAuthor instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('key', instance.key);
  return val;
}
