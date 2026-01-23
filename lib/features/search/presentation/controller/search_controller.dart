import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../projects/data/model/project_list_model.dart';
import '../../../dashboard/presentation/controller/home_controller.dart';

class ProjectSearchController extends GetxController {
  final TextEditingController searchInputController = TextEditingController();
  
  // Lists
  final RxList<ProjectListModel> allProjects = <ProjectListModel>[].obs;
  final RxList<ProjectListModel> filteredProjects = <ProjectListModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadProjects();
  }

  void _loadProjects() {
    // Try to get projects from arguments first
    if (Get.arguments != null && Get.arguments['projects'] != null) {
      allProjects.value = Get.arguments['projects'] as List<ProjectListModel>;
      filteredProjects.value = allProjects;
    } else {
      // Fallback: try to find from HomeController
      try {
         if (Get.isRegistered<HomeController>()) {
           final homeController = Get.find<HomeController>();
           allProjects.value = homeController.projectsList;
           filteredProjects.value = allProjects;
         }
      } catch (e) {
        print("Error loading projects for search: $e");
      }
    }
  }

  void searchProjects(String query) {
    if (query.isEmpty) {
      filteredProjects.value = allProjects;
      return;
    }

    final lowerQuery = query.toLowerCase();
    filteredProjects.value = allProjects.where((project) {
      final name = project.projectName.toLowerCase();
      final client = project.clientName.toLowerCase();
      final company = project.companyName.toLowerCase();
      
      return name.contains(lowerQuery) || 
             client.contains(lowerQuery) || 
             company.contains(lowerQuery);
    }).toList();
  }

  @override
  void onClose() {
    searchInputController.dispose();
    super.onClose();
  }
}
