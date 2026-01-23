class DashboardStatsModel {
  final int projectCount;
  final int treeCount;
  final int districtCount;

  DashboardStatsModel({
    required this.projectCount,
    required this.treeCount,
    required this.districtCount,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      projectCount: json['project_count'] ?? 0,
      treeCount: json['tree_count'] ?? 0,
      districtCount: json['district_count'] ?? 0,
    );
  }
}
