// lib/features/auth/data/models/user_dto.dart
import 'package:aria/features/auth/domain/entities/user.dart';

class UserDto {
  final int id;
  final String username;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final int? province;
  final Map<String, dynamic> provinceDetail;

  const UserDto({
    required this.id,
    required this.username,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.province,
    required this.provinceDetail,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      username: (json['username'] ?? '').toString(),
      phoneNumber: json['phone_number']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      profileImage: json['profile_image']?.toString(),
      province: json['province'] is int ? json['province'] as int : null,
      provinceDetail: (json['province_detail'] is Map<String, dynamic>)
          ? (json['province_detail'] as Map<String, dynamic>)
          : <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'profile_image': profileImage,
      'province': province,
      'province_detail': provinceDetail,
    };
  }

  User toEntity() {
    return User(
      id: id,
      username: username,
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
      profileImage: profileImage,
      province: province,
      provinceDetail: provinceDetail,
    );
  }
}
