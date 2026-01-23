import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tree_expert/core/routes/app_routes.dart';
import '../../../projects/data/model/project_list_model.dart';
import 'download_options_bottom_sheet.dart';

class ApiProjectCard extends StatelessWidget {
  final ProjectListModel project;

  const ApiProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.projectDetails, arguments: {'project': project});
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Name and Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    project.projectName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Circular Progress Indicator
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          value: _getProgressValue(),
                          strokeWidth: 4,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(),
                          ),
                        ),
                      ),
                      Text(
                        "${(_getProgressValue() * 100).toInt()}%",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            
            // Client and Company
            Row(
              children: [
                Icon(Icons.business, size: 14, color: Colors.grey.shade600),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "${project.clientName} • ${project.companyName}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            
            // State
            if (project.state != null)
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                  SizedBox(width: 4),
                  Text(
                    project.state!.stateName,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            
            SizedBox(height: 12),
            
            // Field Officer and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Field Officer
                if (project.fieldOfficer != null)
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: context.theme.primaryColor.withOpacity(0.1),
                          child: Text(
                            project.fieldOfficer!.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: context.theme.primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            project.fieldOfficer!.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Created Date
                Text(
                  _formatDate(project.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade200),
            SizedBox(height: 8),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.edit_outlined,
                  label: "Edit",
                  color: Colors.blue,
                  onTap: () {
                    // Navigate to edit project page with project data
                    Get.toNamed('/addProjects', arguments: {'project': project});
                  },
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey.shade200,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.download_outlined,
                  label: "Download",
                  color: Colors.green,
                  onTap: () {
                    // Show download options bottom sheet
                    Get.bottomSheet(
                      DownloadOptionsBottomSheet(
                        projectName: project.projectName,
                        projectId: project.id,
                      ),
                      isScrollControlled: true,
                    );
                  },
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey.shade200,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: "Add Tree",
                  color: context.theme.primaryColor,
                  onTap: () {
                    // Navigate to add tree page with project ID
                    Get.toNamed('/addTrees', arguments: {'projectId': project.id});
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  // Calculate progress value (0.0 to 1.0)
  // TODO: Replace with actual progress from API when available
  double _getProgressValue() {
    // For now, calculate based on project ID (demo purposes)
    // In real app, this should come from API
    final progress = (project.id % 10) * 0.1;
    return progress.clamp(0.0, 1.0);
  }

  // Get progress color based on completion percentage
  Color _getProgressColor() {
    final progress = _getProgressValue();
    if (progress < 0.3) {
      return Colors.red;
    } else if (progress < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
