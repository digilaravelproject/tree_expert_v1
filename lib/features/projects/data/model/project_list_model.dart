class ProjectListModel {
  final int id;
  final String projectName;
  final int stateId;
  final String clientName;
  final String companyName;
  final int fieldOfficerId;
  final String createdAt;
  final String updatedAt;
  final StateModel? state;
  final FieldOfficerModel? fieldOfficer;

  ProjectListModel({
    required this.id,
    required this.projectName,
    required this.stateId,
    required this.clientName,
    required this.companyName,
    required this.fieldOfficerId,
    required this.createdAt,
    required this.updatedAt,
    this.state,
    this.fieldOfficer,
  });

  factory ProjectListModel.fromJson(Map<String, dynamic> json) {
    return ProjectListModel(
      id: json['id'] ?? 0,
      projectName: json['project_name'] ?? '',
      stateId: json['state_id'] ?? 0,
      clientName: json['client_name'] ?? '',
      companyName: json['company_name'] ?? '',
      fieldOfficerId: json['field_officer_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      state: json['state'] != null ? StateModel.fromJson(json['state']) : null,
      fieldOfficer: json['field_officer'] != null
          ? FieldOfficerModel.fromJson(json['field_officer'])
          : null,
    );
  }
}

class StateModel {
  final int id;
  final String stateName;
  final String createdAt;
  final String updatedAt;

  StateModel({
    required this.id,
    required this.stateName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] ?? 0,
      stateName: json['state_name'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class FieldOfficerModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? designation;
  final int roleId;
  final int? districtId;
  final String? emailVerifiedAt;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? profileImage;

  FieldOfficerModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.designation,
    required this.roleId,
    this.districtId,
    this.emailVerifiedAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.profileImage,
  });

  factory FieldOfficerModel.fromJson(Map<String, dynamic> json) {
    return FieldOfficerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      designation: json['designation'],
      roleId: json['role_id'] ?? 0,
      districtId: json['district_id'],
      emailVerifiedAt: json['email_verified_at'],
      status: json['status'] ?? '0',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      profileImage: json['profile_image'],
    );
  }
}
