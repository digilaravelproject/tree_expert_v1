import 'dart:convert';

class ProjectListModel {
  final int id;
  final int? extraUser;
  final String projectName;
  final int stateId;
  final String clientName;
  final String companyName;
  final dynamic fieldOfficerId; // JSON shows null, could be int or string
  final int? limit; // Null implies infinite
  final dynamic accuracy;
  final int addSecond;
  final dynamic requiredFields;
  final String createdAt;
  final String updatedAt;
  final int treesCount;
  final StateModel? state;
  final FieldOfficerModel? fieldOfficer;
  final bool photoRequired;

  ProjectListModel({
    required this.id,
    this.extraUser,
    required this.projectName,
    required this.stateId,
    required this.clientName,
    required this.companyName,
    this.fieldOfficerId,
    this.limit,
    this.accuracy,
    this.addSecond = 0,
    this.requiredFields,
    required this.createdAt,
    required this.updatedAt,
    this.treesCount = 0,
    this.state,
    this.fieldOfficer,
    this.photoRequired = false,
  });

  factory ProjectListModel.fromJson(Map<String, dynamic> json) {
    return ProjectListModel(
      id: json['id'] ?? 0,
      extraUser: json['extra_user'],
      projectName: json['project_name'] ?? '',
      stateId: json['state_id'] ?? 0,
      clientName: json['client_name'] ?? '',
      companyName: json['company_name'] ?? '',
      fieldOfficerId: json['field_officer_id'],
      limit: json['limit'] != null ? int.tryParse(json['limit'].toString()) : null,
      accuracy: json['accuracy'],
      addSecond: json['add_second'] != null ? int.tryParse(json['add_second'].toString()) ?? 0 : 0,
      requiredFields: json['required_fields'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      treesCount: json['trees_count'] != null ? int.tryParse(json['trees_count'].toString()) ?? 0 : 0,
      state: json['state'] != null ? StateModel.fromJson(json['state']) : null,
      fieldOfficer: json['field_officer'] != null
          ? FieldOfficerModel.fromJson(json['field_officer'])
          : null,
      photoRequired: json['photo_required'] ?? false,
    );
  }
}

class StateModel {
  final int id;
  final String stateName;
  final String? createdAt;
  final String? updatedAt;

  StateModel({
    required this.id,
    required this.stateName,
    this.createdAt,
    this.updatedAt,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] ?? 0,
      stateName: json['state_name'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
