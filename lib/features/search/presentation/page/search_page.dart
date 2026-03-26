import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../dashboard/presentation/widgets/api_project_card.dart';
import '../controller/search_controller.dart';

class SearchPage extends GetView<ProjectSearchController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller.searchInputController,
            autofocus: true,
            onChanged: controller.searchProjects,
            decoration: InputDecoration(
              hintText: "Search projects...",
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              prefixIcon: Icon(CupertinoIcons.search, color: Colors.grey.shade600, size: 18),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              suffixIcon: GestureDetector(
                onTap: () {
                  controller.searchInputController.clear();
                  controller.searchProjects('');
                },
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.filteredProjects.isEmpty) {
          if (controller.searchInputController.text.isNotEmpty) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.search, size: 60, color: Colors.grey.shade300),
                  SizedBox(height: 16),
                  Text("No results found", style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }
           return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.youtube_searched_for, size: 60, color: Colors.grey.shade300),
                  SizedBox(height: 16),
                  Text("Search for projects", style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
        }
        
        return ListView.builder(
          itemCount: controller.filteredProjects.length,
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ApiProjectCard(
                project: controller.filteredProjects[index],
              ),
            );
          },
        );
      }),
    );
  }
}
