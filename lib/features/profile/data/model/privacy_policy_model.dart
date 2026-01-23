class PrivacyPolicyModel {
  final int id;
  final String title;
  final String content;

  PrivacyPolicyModel({
    required this.id,
    required this.title,
    required this.content,
  });

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
