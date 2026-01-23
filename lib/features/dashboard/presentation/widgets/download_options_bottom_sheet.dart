import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadOptionsBottomSheet extends StatelessWidget {
  final String projectName;
  final int projectId;

  const DownloadOptionsBottomSheet({
    super.key,
    required this.projectName,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.download,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Download Options",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        projectName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Download Options
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildDownloadOption(
                icon: Icons.map,
                title: "KML",
                subtitle: "Download KML file",
                color: Colors.blue,
                onTap: () {
                  Get.back();
                  _handleDownload("KML", projectId);
                },
              ),
              _buildDownloadOption(
                icon: Icons.photo_library,
                title: "KML (along with Photo)",
                subtitle: "KML file with photos included",
                color: Colors.purple,
                onTap: () {
                  Get.back();
                  _handleDownload("KML_WITH_PHOTO", projectId);
                },
              ),
              _buildDownloadOption(
                icon: Icons.table_chart,
                title: "Excel",
                subtitle: "Download as Excel spreadsheet",
                color: Colors.green,
                onTap: () {
                  Get.back();
                  _handleDownload("EXCEL", projectId);
                },
              ),
              _buildDownloadOption(
                icon: Icons.photo_camera,
                title: "Photo (Compress Rar File)",
                subtitle: "Download compressed photos",
                color: Colors.orange,
                onTap: () {
                  Get.back();
                  _handleDownload("PHOTO_RAR", projectId);
                },
              ),
              _buildDownloadOption(
                icon: Icons.description,
                title: "Report",
                subtitle: "Download project report",
                color: Colors.red,
                onTap: () {
                  Get.back();
                  _handleDownload("REPORT", projectId);
                },
              ),
            ],
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDownloadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _handleDownload(String type, int projectId) {
    // TODO: Implement actual download logic
    Get.snackbar(
      "Downloading",
      "Preparing $type download for project #$projectId...",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: Icon(Icons.download, color: Colors.white),
      duration: Duration(seconds: 2),
    );
  }
}
