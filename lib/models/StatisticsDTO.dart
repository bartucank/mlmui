import 'package:json_annotation/json_annotation.dart';
part 'StatisticsDTO.g.dart';
//includeIfNull: false
@JsonSerializable(explicitToJson: true)
class StatisticsDTO{
  int totalUserCount;
  int totalBookCount;
  int availableBookCount;
  int unavailableBookCount;
  double sumOfBalance;
  double sumOfDebt;
  int queueCount;
  String? day;
  String? dayDesc;
  int dayInt;
  int id;

  StatisticsDTO(
      this.totalUserCount,
      this.totalBookCount,
      this.availableBookCount,
      this.unavailableBookCount,
      this.sumOfBalance,
      this.sumOfDebt,
      this.queueCount,
      this.day,
      this.dayDesc,
      this.dayInt,
      this.id
      );

  factory StatisticsDTO.fromJson(Map<String,dynamic> data) => _$StatisticsDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$StatisticsDTOToJson(this);
}