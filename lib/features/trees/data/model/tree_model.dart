/*class TreeModel {
  final int id;
  final String commonName;
  final int? scientificNameId;
  final String scientificName;
  final int? familyNameId;
  final String family;
  final String treeNo;
  final String condition;
  final String? imageUrl;
  final String? girth;
  final String? height;
  final String? ownership;
  final String? latitude;
  final String? longitude;

  TreeModel({
    required this.id,
    required this.commonName,
    this.scientificNameId,
    required this.scientificName,
    this.familyNameId,
    required this.family,
    required this.treeNo,
    required this.condition,
    this.imageUrl,
    this.girth,
    this.height,
    this.ownership,
    this.latitude,
    this.longitude,
  });

  factory TreeModel.fromJson(Map<String, dynamic> json) {
    return TreeModel(
      id: json['id'] ?? 0,
      commonName: json['name'] ?? json['tree_name'] ?? '',
      scientificNameId: json['scientific_name_id'],
      scientificName: json['scientific_name'] ?? '',
      familyNameId: json['family_name_id'],
      family: json['family_name'] ?? json['family'] ?? '',
      treeNo: json['tree_no'] ?? '',
      condition: json['condition'] ?? '',
      imageUrl: json['captured_image'] ?? json['tree_image_upload'],
      girth: json['girth']?.toString(),
      height: json['height']?.toString(),
      ownership: json['ownership']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }
}*/





class TreeModel {
  final int id;
  final int projectId;
  final int userId;
  final String wardPlotNo;
  final String treeNo;
  final String treeName;
  final String scientificName;
  final int? scientificNameId;
  final String family;
  final int? familyNameId;
  final String? girth;
  final String? height;
  final String? canopy;
  final int? age;
  final String condition;
  final String address;
  final String? landmark;
  final String? ownership;
  final String? concernPerson;
  final String? remark;
  final String? treeImageUpload;
  final String? capturedImage;
  final List<String>? allCapturedImages;
  final String? latitude;
  final String? longitude;
  final int? payment;
  final String? datetime;
  final String? createdAt;
  final String? updatedAt;
  final bool? isFree;
  final bool? isPaid;
  final bool? isAccessible;

  TreeModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.wardPlotNo,
    required this.treeNo,
    required this.treeName,
    required this.scientificName,
    this.scientificNameId,
    required this.family,
    this.familyNameId,
    this.girth,
    this.height,
    this.canopy,
    this.age,
    required this.condition,
    required this.address,
    this.landmark,
    this.ownership,
    this.concernPerson,
    this.remark,
    this.treeImageUpload,
    this.capturedImage,
    this.allCapturedImages,
    this.latitude,
    this.longitude,
    this.payment,
    this.datetime,
    this.createdAt,
    this.updatedAt,
    this.isFree,
    this.isPaid,
    this.isAccessible,
  });

  factory TreeModel.fromJson(Map<String, dynamic> json) {
    List<String>? capturedImages;
    if (json['all_captured_images'] != null) {
      capturedImages = List<String>.from(json['all_captured_images']);
    }

    return TreeModel(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      wardPlotNo: json['ward_plot_no'] ?? '',
      treeNo: json['tree_no'] ?? '',
      treeName: json['tree_name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
      scientificNameId: json['scientific_name_id'],
      family: json['family'] ?? '',
      familyNameId: json['family_name_id'],
      girth: json['girth']?.toString(),
      height: json['height']?.toString(),
      canopy: json['canopy']?.toString(),
      age: json['age'],
      condition: json['condition'] ?? '',
      address: json['address'] ?? '',
      landmark: json['landmark'],
      ownership: json['ownership'],
      concernPerson: json['concern_person'],
      remark: json['remark'],
      treeImageUpload: json['tree_image_upload'],
      capturedImage: json['captured_image'],
      allCapturedImages: capturedImages,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      payment: json['payment'],
      datetime: json['datetime'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isFree: json['is_free'] ?? false,
      isPaid: json['is_paid'] ?? false,
      isAccessible: json['is_accessible'] ?? false,
    );
  }
}

