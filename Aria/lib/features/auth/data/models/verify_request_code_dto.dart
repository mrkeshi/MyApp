
class VerifyRequestCodeDto {
  final String phoneNumber;
  final String code;
  const VerifyRequestCodeDto({required this.phoneNumber,required this.code});

  Map<String, dynamic> toJson() => {
    'phone_number': phoneNumber,
    'code': code,
  };
}

