import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../projects/data/repository/projects_repository.dart';

class DownloadOptionsBottomSheet extends StatefulWidget {
  final String projectName;
  final int projectId;
  final List<int>? selectedTreeIds;

  const DownloadOptionsBottomSheet({
    super.key,
    required this.projectName,
    required this.projectId,
    this.selectedTreeIds,
  });
  @override
  State<DownloadOptionsBottomSheet> createState() => _DownloadOptionsBottomSheetState();
}

class _DownloadOptionsBottomSheetState extends State<DownloadOptionsBottomSheet> {
  final ProjectsRepository _repository = Get.find<ProjectsRepository>();
  bool _isLoading = true;
  Map<String, String>? _links;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLinks();
  }

  Future<void> _fetchLinks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _repository.getProjectExportLinks(
      widget.projectId.toString(),
      treeIds: widget.selectedTreeIds,
    );

    if (response.success && response.data != null) {
      final linksData = response.data!['links'];
      if (linksData != null && linksData is Map) {
        setState(() {
          _links = Map<String, String>.from(linksData.map((key, value) => MapEntry(key.toString(), value.toString())));
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "No download links available";
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _error = response.message ?? "Failed to fetch links";
        _isLoading = false;
      });
    }
  }

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
                        widget.projectName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.selectedTreeIds != null && widget.selectedTreeIds!.isNotEmpty) ...[
                        SizedBox(height: 2),
                        Text(
                          "Selected Trees: ${widget.selectedTreeIds!.length}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

          // Content
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 150),
            child: _buildContent(),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 40),
              SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Colors.grey.shade700)),
              TextButton(onPressed: _fetchLinks, child: Text("Retry")),
            ],
          ),
        ),
      );
    }

    if (_links == null || _links!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text("No files available for download"),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 8),
      children: [
        if (_links!.containsKey('pdf'))
          _buildDownloadOption(
            icon: Icons.picture_as_pdf,
            title: "PDF Report",
            subtitle: "Download project as PDF",
            color: Colors.red,
            onTap: () => _handleLaunch(_links!['pdf']!),
          ),
        if (_links!.containsKey('excel'))
          _buildDownloadOption(
            icon: Icons.table_chart,
            title: "Excel",
            subtitle: "Download as Excel spreadsheet",
            color: Colors.green,
            onTap: () => _handleLaunch(_links!['excel']!),
          ),
        if (_links!.containsKey('kml'))
          _buildDownloadOption(
            icon: Icons.map,
            title: "KML",
            subtitle: "Download KML file",
            color: Colors.blue,
            onTap: () => _handleLaunch(_links!['kml']!),
          ),
        if (_links!.containsKey('imgs_zip'))
          _buildDownloadOption(
            icon: Icons.map,
            title: "Images",
            subtitle: "Download Image file",
            color: Colors.blue,
            onTap: () => _handleLaunch(_links!['imgs_zip']!),
          ),
      ],
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

  Future<void> _handleLaunch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        "Error",
        "Could not open download link",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
