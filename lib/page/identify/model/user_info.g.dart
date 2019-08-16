part of 'user_info.dart';

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) {
  return UserInfo(
    subjectId: json['subjectId'] as String,
    birthDate: json['birthDate'] as String,
    gender: json['gender'] as String,
    name: json['name'] as String,
    image: json['image'] as String,
    fap: json['fap'] as double
  );
}

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) =>
    <String, dynamic>{
      'subjectId': instance.subjectId,
      'birthDate': instance.birthDate,
      'gender': instance.gender,
      'name': instance.name,
      'image': instance.image,
      'fap': instance.fap
    };
