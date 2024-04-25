// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BookReviewDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookReviewDTO _$BookReviewDTOFromJson(Map<String, dynamic> json) =>
    BookReviewDTO(
      json['userId'] as int?,
      json['star'] as int?,
      json['comment'] as String?,
    );

Map<String, dynamic> _$BookReviewDTOToJson(BookReviewDTO instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('userId', instance.userId);
  writeNotNull('star', instance.star);
  writeNotNull('comment', instance.comment);
  return val;
}
