// lib/features/auth/domain/entities/user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String phoneNumber;
  final String? fullName;
  final String? token;

  const User({
    required this.id,
    required this.phoneNumber,
    this.fullName,
    this.token,
  });

  @override
  List<Object?> get props => [id, phoneNumber, fullName, token];

  User copyWith({
    int? id,
    String? phoneNumber,
    String? fullName,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      token: token ?? this.token,
    );
  }
}
