// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ReceiptHistoryDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiptHistoryDTO _$ReceiptHistoryDTOFromJson(Map<String, dynamic> json) =>
    ReceiptHistoryDTO(
      json['id'] as int?,
      json['userId'] as int?,
      json['imgId'] as int?,
      json['approved'] as bool?,
      (json['balance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ReceiptHistoryDTOToJson(ReceiptHistoryDTO instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('userId', instance.userId);
  writeNotNull('imgId', instance.imgId);
  writeNotNull('approved', instance.approved);
  writeNotNull('balance', instance.balance);
  return val;
}
