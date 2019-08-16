part of 'response_body.dart';

ResponseBody _$ResponseBodyFromJson(Map<String, dynamic> json) {
  var list = json['data'] as List;
  List<UserInfo> usersList;
  if (list != null) usersList = list.map((i) => UserInfo.fromJson(i)).toList();
  return ResponseBody(
      success: json['success'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      data: usersList);
}

Map<String, dynamic> _$ResponseBodyToJson(ResponseBody instance) =>
    <String, dynamic>{
      'success': instance.success,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
