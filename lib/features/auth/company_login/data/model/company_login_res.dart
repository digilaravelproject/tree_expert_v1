class CompanyLoginResponse {
  final String accessToken;
  final String tokenType;
  final UserModel user;

  CompanyLoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory CompanyLoginResponse.fromJson(Map<String, dynamic> json) {
    return CompanyLoginResponse(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      user: UserModel.fromJson(json['user']),
    );
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? designation;
  final int? roleId;
  final int? districtId;
  final String? emailVerifiedAt;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.designation,
    this.roleId,
    this.districtId,
    this.emailVerifiedAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      designation: json['designation'],
      roleId: json['role_id'],
      districtId: json['district_id'],
      emailVerifiedAt: json['email_verified_at'],
      status: json['status'] ?? '1',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'designation': designation,
      'role_id': roleId,
      'district_id': districtId,
      'email_verified_at': emailVerifiedAt,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'profile_image': profileImage,
    };
  }
}