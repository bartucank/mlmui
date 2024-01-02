import 'package:json_annotation/json_annotation.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'package:mlmui/models/StatisticsDTO.dart';
import 'ShelfDTO.dart';
import 'UserDTO.dart';
part 'StatisticsDTOListResponse.g.dart';
@JsonSerializable(explicitToJson: true)
class StatisticsDTOListResponse {
  List<StatisticsDTO> statisticsDTOList;

  StatisticsDTOListResponse(this.statisticsDTOList);

  factory StatisticsDTOListResponse.fromJson(Map<String,dynamic> data) => _$StatisticsDTOListResponseFromJson(data);

  Map<String,dynamic> toJson()=>_$StatisticsDTOListResponseToJson(this);
}
