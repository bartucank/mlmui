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

  StatisticsDTO(
      this.totalUserCount,
      this.totalBookCount,
      this.availableBookCount,
      this.unavailableBookCount,
      this.sumOfBalance,
      this.sumOfDebt,
      this.queueCount
      );

  factory StatisticsDTO.fromJson(Map<String,dynamic> data) => _$StatisticsDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$StatisticsDTOToJson(this);
}