
class RequestCodeDto {
  final String phoneNumber;
  const RequestCodeDto({required this.phoneNumber});

  Map<String, dynamic> toJson() => {
    'phone_number': phoneNumber,
  };
}

