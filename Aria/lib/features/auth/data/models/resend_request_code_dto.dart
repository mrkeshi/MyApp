// lib/features/auth/data/models/request_code_dto.dart

class ResendRequestCodeDto {
  final String phoneNumber;
  const ResendRequestCodeDto({required this.phoneNumber});

  Map<String, dynamic> toJson() => {
    'phone_number': phoneNumber,
  };
}

