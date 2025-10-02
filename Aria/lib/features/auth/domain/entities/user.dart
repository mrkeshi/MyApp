
class User {
  final int id;
  final String username;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final int? province;
  final Map<String, dynamic> provinceDetail;

  const User({
    required this.id,
    required this.username,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.province,
    required this.provinceDetail,
  });

  User copyWith({
    int? id,
    String? username,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? profileImage,
    int? province,
    Map<String, dynamic>? provinceDetail,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImage: profileImage ?? this.profileImage,
      province: province ?? this.province,
      provinceDetail: provinceDetail ?? this.provinceDetail,
    );
  }
}
