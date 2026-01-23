import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/project_list_model.dart';

class AddProjectController extends GetxController {
  // Form controllers
  final projectNameController = TextEditingController();
  final stateController = TextEditingController();
  final districtController = TextEditingController();
  final clientNameController = TextEditingController();
  final companyNameController = TextEditingController();

  // Observable
  final RxBool isEditMode = false.obs;
  final RxBool isLoading = false.obs;
  ProjectListModel? editingProject;

  @override
  void onInit() {
    super.onInit();
    _checkEditMode();
  }

  void _checkEditMode() {
    // Check if project data is passed for editing
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('project')) {
      isEditMode.value = true;
      editingProject = args['project'] as ProjectListModel;
      _loadProjectData();
    }
  }

  void _loadProjectData() {
    if (editingProject != null) {
      projectNameController.text = editingProject!.projectName;
      stateController.text = editingProject!.state?.stateName ?? '';
      clientNameController.text = editingProject!.clientName;
      companyNameController.text = editingProject!.companyName;
      // District would need to be added to the model or fetched separately
    }
  }

  void saveProject() {
    if (projectNameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Project name is required");
      return;
    }

    isLoading.value = true;

    // TODO: Implement API call to save/update project
    Future.delayed(Duration(seconds: 1), () {
      isLoading.value = false;
      Get.snackbar(
        "Success",
        isEditMode.value
            ? "Project updated successfully!"
            : "Project created successfully!",
      );
      Get.back(result: true); // Return true to indicate success
    });
  }

  @override
  void onClose() {
    projectNameController.dispose();
    stateController.dispose();
    districtController.dispose();
    clientNameController.dispose();
    companyNameController.dispose();
    super.onClose();
  }
}