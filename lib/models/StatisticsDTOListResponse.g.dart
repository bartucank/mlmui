// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'StatisticsDTOListResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatisticsDTOListResponse _$StatisticsDTOListResponseFromJson(
        Map<String, dynamic> json) =>
    StatisticsDTOListResponse(
      (json['statisticsDTOList'] as List<dynamic>)
          .map((e) => StatisticsDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StatisticsDTOListResponseToJson(
        StatisticsDTOListResponse instance) =>
    <String, dynamic>{
      'statisticsDTOList':
          instance.statisticsDTOList.map((e) => e.toJson()).toList(),
    };
