part of 'response_body.dart';

ResponseBody _$ResponseBodyFromJson(Map<String, dynamic> json) {
  return ResponseBody(
      success: json['success'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      data: json['data']);
}

Map<String, dynamic> _$ResponseBodyToJson(ResponseBody instance) =>
    <String, dynamic>{
      'success': instance.success,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
