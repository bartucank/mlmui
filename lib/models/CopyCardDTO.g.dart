// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CopyCardDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CopyCardDTO _$CopyCardDTOFromJson(Map<String, dynamic> json) => CopyCardDTO(
      (json['balance'] as num).toDouble(),
      json['nfcCode'] as String,
    );

Map<String, dynamic> _$CopyCardDTOToJson(CopyCardDTO instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'nfcCode': instance.nfcCode,
    };
