class TreeModel {
  final int id;
  final String commonName;
  final String scientificName;
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
    required this.scientificName,
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
      commonName: json['tree_name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
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
