class UserProfileModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? designation;
  final String? profileImage;
  final String? status;
  final String? createdAt;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.designation,
    this.profileImage,
    this.status,
    this.createdAt,
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
    );
  }
}
