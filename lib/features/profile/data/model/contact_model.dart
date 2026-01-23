class ContactModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String details;
  final String? instagram;
  final String? facebook;
  final String? whatsapp;
  final String? youtube;
  final String? linkedin;

  ContactModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.details,
    this.instagram,
    this.facebook,
    this.whatsapp,
    this.youtube,
    this.linkedin,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      details: json['details'] ?? '',
      instagram: json['instagram'],
      facebook: json['facebook'],
      whatsapp: json['whatsapp'],
      youtube: json['youtube'],
      linkedin: json['linkedin'],
    );
  }
}
