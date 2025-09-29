import 'package:aria/features/auth/domain/entities/user.dart';

class UserDto {
  final int id;
  final String phoneNumber;
  final String? fullName;
  final String? token;

  const UserDto({
    required this.id,
    required this.phoneNumber,
    this.fullName,
    this.token,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] ?? 0,
      phoneNumber: json['phone_number']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'token': token,
    };
  }

  User toEntity() => User(
    id: id,
    phoneNumber: phoneNumber,
    fullName: fullName,
    token: token,
  );

  factory UserDto.fromEntity(User u) => UserDto(
    id: u.id,
    phoneNumber: u.phoneNumber,
    fullName: u.fullName,
    token: u.token,
  );
}
