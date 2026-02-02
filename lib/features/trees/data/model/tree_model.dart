class TreeModel {
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
}
