class UserProfile {
  final String id;
  final String name;
  final int age;
  final String imageUrl;
  final double distanceKm;
  final String bio;
  final List<String> interests;
  final String location;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.distanceKm,
    required this.bio,
    required this.interests,
    required this.location,
  });
}