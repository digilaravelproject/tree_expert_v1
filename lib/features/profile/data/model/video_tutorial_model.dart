class VideoModel {
  final int id;
  final String title;
  final String videoUrl;
  final String? description;
  final String? thumbnail;
  final String? createdAt;

  VideoModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    this.description,
    this.thumbnail,
    this.createdAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      videoUrl: json['video_url'] ?? '',
      description: json['description'],
      thumbnail: json['thumbnail'],
      createdAt: json['created_at'],
    );
  }
}
