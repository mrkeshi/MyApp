

class ResendRequestCodeDto {
  final String phoneNumber;

  const ResendRequestCodeDto({required this.phoneNumber});

  Map<String, dynamic> toJson() => {
    'phone_number': phoneNumber,
    'is_resend':true
  };
}

