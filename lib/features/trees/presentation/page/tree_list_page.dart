import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../widgets/custom_image_view.dart';
import '../../../../widgets/custom_scaffold.dart';
import '../../../projects/data/model/project_list_model.dart';
import '../../data/model/tree_model.dart';
import '../controller/tree_list_controller.dart';

class TreeDetailsPage extends StatefulWidget {
  const TreeDetailsPage({super.key});

  @override
  State<TreeDetailsPage> createState() => _TreeDetailsPageState();
}

class _TreeDetailsPageState extends State<TreeDetailsPage> {
  ProjectListModel? project;
  final TreeListController controller = Get.find<TreeListController>();

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments is Map && Get.arguments['project'] != null) {
      project = Get.arguments['project'];
      if (project != null) {
        controller.fetchTreesByProject(project!.id.toString());
      }
    }
  }

  Future<void> _launchMaps(String? lat, String? lng) async {
    if (lat == null || lng == null || lat.isEmpty || lng.isEmpty) {
      Get.snackbar("Error", "Location coordinates not available");
      return;
    }
    
    final googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    final uri = Uri.parse(googleMapsUrl);
    final geoUri = Uri.parse("geo:$lat,$lng");

    try {
      // Try Google Maps Link
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Try Geo Intent
        launched = await launchUrl(geoUri);
      }
      
      if (!launched) {
         Get.snackbar("Error", "Could not open Maps or Browser");
      }
    } catch (e) {
      print("Launch Error: $e");
      // Fallback: Just try launch regardless of check
       try {
         await launchUrl(uri, mode: LaunchMode.platformDefault);
       } catch (e2) {
         Get.snackbar("Error", "Could not open maps");
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectName = project?.projectName ?? "Tree Details";

    return CustomScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          projectName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () {
               _showFilterBottomSheet(context);
            },
            icon: const Icon(Icons.filter_list),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (controller.trees.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forest_outlined, size: 60, color: Colors.grey.shade300),
                SizedBox(height: 16),
                Text("No trees found in this project", style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.trees.length,
          itemBuilder: (context, index) {
            return _buildTreeCard(context, controller.trees[index]);
          },
        );
      }),
    );
  }

  Widget _buildTreeCard(BuildContext context, TreeModel tree) {
    return GestureDetector(
      onTap: () => _showTreeDetails(context, tree),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Image
            if (tree.imageUrl != null && tree.imageUrl!.isNotEmpty)
              CustomImageView(
                url: tree.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: Icon(Icons.park, size: 40, color: Colors.grey.shade400),
                ),
              ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       // Navigation Icon (Left)
                       if (tree.latitude != null && tree.longitude != null && tree.latitude!.isNotEmpty)
                        GestureDetector(
                          onTap: () => _launchMaps(tree.latitude, tree.longitude),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.directions, size: 16, color: Theme.of(context).primaryColor),
                          ),
                        )
                       else 
                        SizedBox(), // Spacer
                       
                       // Condition Badge (Right)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getConditionColor(tree.condition),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tree.condition,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tree.treeNo,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        tree.commonName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        tree.scientificName,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'good': return Colors.green;
      case 'poor': return Colors.red;
      case 'medium': return Colors.orange;
      case 'dead': return Colors.black54;
      default: return Colors.blue;
    }
  }

  void _showTreeDetails(BuildContext context, TreeModel tree) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
             // Handle bar
             Container(
               margin: EdgeInsets.symmetric(vertical: 12),
               width: 50,
               height: 5,
               decoration: BoxDecoration(
                 color: Colors.grey.shade300,
                 borderRadius: BorderRadius.circular(10),
               ),
             ),
             
             Expanded(
               child: SingleChildScrollView(
                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // Image
                     Container(
                       height: 200,
                       width: double.infinity,
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(16),
                         color: Colors.grey.shade200,
                       ),
                       clipBehavior: Clip.hardEdge,
                       child: (tree.imageUrl != null && tree.imageUrl!.isNotEmpty)
                        ? CustomImageView(url: tree.imageUrl, fit: BoxFit.cover)
                        : Icon(Icons.park, size: 80, color: Colors.grey.shade400),
                     ),
                     SizedBox(height: 20),
                     
                     // Helper for Grid Items
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 tree.commonName,
                                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                               ),
                               if (tree.scientificName.isNotEmpty)
                                 Text(
                                   tree.scientificName,
                                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                     fontStyle: FontStyle.italic,
                                     color: Colors.grey.shade600
                                   ),
                                 ),
                             ],
                           ),
                         ),
                         Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getConditionColor(tree.condition).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _getConditionColor(tree.condition)),
                            ),
                            child: Text(
                              tree.condition,
                              style: TextStyle(
                                color: _getConditionColor(tree.condition),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                       ],
                     ),
                     
                     SizedBox(height: 24),
                     
                     // Attributes Grid
                     GridView.count(
                       shrinkWrap: true,
                       physics: NeverScrollableScrollPhysics(),
                       crossAxisCount: 3,
                       childAspectRatio: 1.5,
                       mainAxisSpacing: 16,
                       crossAxisSpacing: 16,
                       children: [
                         _buildAttributeItem(context, "Tree No", tree.treeNo),
                         _buildAttributeItem(context, "Family", tree.family),
                         _buildAttributeItem(context, "Ownership", tree.ownership ?? "N/A"),
                         _buildAttributeItem(context, "Girth (cm)", tree.girth ?? "N/A"),
                         _buildAttributeItem(context, "Height", tree.height == null ? "N/A" : "${tree.height}"),
                         _buildAttributeItem(context, "Age (Yrs)", "N/A"), // Age not in model yet, placeholder
                       ],
                     ),
                     
                     SizedBox(height: 24),
                     
                     if (tree.latitude != null && tree.longitude != null) ...[
                       Text("Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                       SizedBox(height: 8),
                       Container(
                         padding: EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: Colors.blue.withOpacity(0.05),
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: Colors.blue.withOpacity(0.2)),
                         ),
                         child: Row(
                           children: [
                             Icon(Icons.location_on, color: Colors.blue),
                             SizedBox(width: 12),
                             Expanded(
                               child: Text(
                                 "${tree.latitude}, ${tree.longitude}",
                                 style: TextStyle(fontWeight: FontWeight.w500),
                               ),
                             ),
                           ],
                         ),
                       ),
                       SizedBox(height: 24),
                     ],
                     
                     SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                           backgroundColor: Theme.of(context).primaryColor,
                           foregroundColor: Colors.white,
                           padding: EdgeInsets.symmetric(vertical: 14),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: (tree.latitude != null && tree.longitude != null) 
                          ? () {
                              Get.back(); // Close sheet first
                              _launchMaps(tree.latitude, tree.longitude);
                            } 
                          : null,
                        icon: Icon(Icons.directions),
                        label: Text("Navigate to Tree"),
                      ),
                     ),
                     SizedBox(height: 20),
                   ],
                 ),
               ),
             ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildAttributeItem(BuildContext context, String label, String value) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    // ... (Existing implementation kept same)
    final conditions = ['Good', 'Medium', 'Poor', 'Disease', 'Dead'];
    final ownerships = ['Pvt', 'Gov', 'Park', 'Road', 'Open Space', 'Riverside'];

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text("Filters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   TextButton(
                     onPressed: () {
                       controller.resetFilters();
                       Get.back();
                     },
                     child: Text("Reset", style: TextStyle(color: Colors.red)),
                   )
                ],
              ),
              Divider(),
              SizedBox(height: 10),
              
              Text("Condition", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                children: conditions.map((c) {
                  final isSelected = controller.selectedCondition.value == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: isSelected,
                    onSelected: (val) => controller.filterByCondition(c),
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              )),
              
              SizedBox(height: 16),
              Text("Ownership", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                children: ownerships.map((o) {
                  final isSelected = controller.selectedOwnership.value == o;
                  return ChoiceChip(
                    label: Text(o),
                    selected: isSelected,
                    onSelected: (val) => controller.filterByOwnership(o),
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              )),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text("Apply"),
                ),
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
