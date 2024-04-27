// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'StatisticsDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatisticsDTO _$StatisticsDTOFromJson(Map<String, dynamic> json) =>
    StatisticsDTO(
      json['totalUserCount'] as int?,
      json['totalBookCount'] as int?,
      json['availableBookCount'] as int?,
      json['unavailableBookCount'] as int?,
      (json['sumOfBalance'] as num?)?.toDouble(),
      (json['sumOfDebt'] as num?)?.toDouble(),
      json['queueCount'] as int?,
      json['day'] as String?,
      json['dayDesc'] as String?,
      json['dayInt'] as int?,
      json['id'] as int?,
    );

Map<String, dynamic> _$StatisticsDTOToJson(StatisticsDTO instance) =>
    <String, dynamic>{
      'totalUserCount': instance.totalUserCount,
      'totalBookCount': instance.totalBookCount,
      'availableBookCount': instance.availableBookCount,
      'unavailableBookCount': instance.unavailableBookCount,
      'sumOfBalance': instance.sumOfBalance,
      'sumOfDebt': instance.sumOfDebt,
      'queueCount': instance.queueCount,
      'day': instance.day,
      'dayDesc': instance.dayDesc,
      'dayInt': instance.dayInt,
      'id': instance.id,
    };
