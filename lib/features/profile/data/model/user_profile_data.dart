class UserProfileModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? designation;
  final String? profileImage;
  final String? status;
  final String? createdAt;
  final String? aadhaarNumber;
  final String? address;
  final String? gender;
  final int? isVerified;
  final int? roleId;
  final int? districtId;
  final String? wardNumber;
  final String? projects;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.designation,
    this.profileImage,
    this.status,
    this.createdAt,
    this.aadhaarNumber,
    this.address,
    this.gender,
    this.isVerified,
    this.roleId,
    this.districtId,
    this.wardNumber,
    this.projects,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      designation: json['designation'],
      profileImage: json['profile_image'],
      status: json['status'],
      createdAt: json['created_at'],
      aadhaarNumber: json['aadhaar_number'],
      address: json['address'],
      gender: json['gender'],
      isVerified: json['is_verified'],
      roleId: json['role_id'],
      districtId: json['district_id'],
      wardNumber: json['ward_number'],
      projects: json['projects'],
    );
  }
}
