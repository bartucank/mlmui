// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ReceiptHistoryDTOListResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiptHistoryDTOListResponse _$ReceiptHistoryDTOListResponseFromJson(
        Map<String, dynamic> json) =>
    ReceiptHistoryDTOListResponse(
      (json['receiptHistoryDTOList'] as List<dynamic>)
          .map((e) => ReceiptHistoryDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['totalPage'] as int,
      json['totalResult'] as int,
    );

Map<String, dynamic> _$ReceiptHistoryDTOListResponseToJson(
        ReceiptHistoryDTOListResponse instance) =>
    <String, dynamic>{
      'receiptHistoryDTOList':
          instance.receiptHistoryDTOList.map((e) => e.toJson()).toList(),
      'totalPage': instance.totalPage,
      'totalResult': instance.totalResult,
    };
