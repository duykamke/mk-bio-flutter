import 'package:json_annotation/json_annotation.dart';
part 'response_body.g.dart';

@JsonSerializable()
class ResponseBody {
  final bool success;
  final String code;
  final String message;
  final data;
  
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
