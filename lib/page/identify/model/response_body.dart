import 'package:json_annotation/json_annotation.dart';
import 'package:mk_bio/page/identify/model/user_info.dart';
part 'response_body.g.dart';

@JsonSerializable()
class ResponseBody {
  final bool success;
  final String code;
  final String message;
  final List<UserInfo> data;
  
  ResponseBody(
      {this.success,
      this.code,
      this.message,
      this.data,
      });

  factory ResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ResponseBodyFromJson(json);
  Map<String, dynamic> toJson() => _$ResponseBodyToJson(this);
}
