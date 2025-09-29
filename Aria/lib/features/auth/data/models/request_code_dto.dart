// lib/features/auth/data/models/request_code_dto.dart

class RequestCodeDto {
  final String phoneNumber;
  const RequestCodeDto({required this.phoneNumber});

  Map<String, dynamic> toJson() => {
    'phone_number': phoneNumber,
  };
}

