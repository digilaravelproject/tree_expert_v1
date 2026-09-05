import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_response.dart';
import '../../../dashboard/presentation/controller/home_controller.dart';
import '../../data/model/project_list_model.dart';
import '../../data/repository/projects_repository.dart';

class AddProjectController extends GetxController {
  final ProjectsRepository _repository = Get.find<ProjectsRepository>();
  
  // Form controllers
  final projectNameController = TextEditingController();
  final stateController = TextEditingController(); // Keep strictly for display if needed, but mainly use selectedState
  final clientNameController = TextEditingController();
  final companyNameController = TextEditingController();

  // Observable
  final RxBool isEditMode = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPhotoRequired = false.obs;
  final RxList<StateModel> statesList = <StateModel>[].obs;
  final Rx<StateModel?> selectedState = Rx<StateModel?>(null);
  
  ProjectListModel? editingProject;

  @override
  void onInit() {
    super.onInit();
    _fetchStates();
    _checkEditMode();
  }

  Future<void> _fetchStates() async {
    final response = await _repository.getStates();
    if (response.success && response.data != null) {
      statesList.assignAll(response.data!);
    } else {
      print("Failed to fetch states: ${response.message}");
    }
  }

  void _checkEditMode() {
    // Check if project data is passed for editing
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('project')) {
      isEditMode.value = true;
      editingProject = args['project'] as ProjectListModel;
      // Data loading will happen after states are fetched to ensure we can match the state ID
      // But since fetch is async, we might need to listen to statesList or just load basic data first
      _loadProjectData();
    }
  }

  void _loadProjectData() {
    if (editingProject != null) {
      projectNameController.text = editingProject!.projectName;
      
      // We will try to match the state once states are loaded, or if already loaded
      if (editingProject!.state != null) {
         stateController.text = editingProject!.state!.stateName;
         // Note: We'll set selectedState when we have the list, or we can just create a temporary object if ID matches
         // For now let's wait for matching in the UI or handling it here if we really needed tight binding
      }
      
      
      clientNameController.text = editingProject!.clientName;
      companyNameController.text = editingProject!.companyName;
      isPhotoRequired.value = editingProject!.photoRequired;
    }
  }
  
  void selectState(StateModel state) {
    selectedState.value = state;
    stateController.text = state.stateName;
  }

  Future<void> saveProject() async {
    if (projectNameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Project name is required");
      return;
    }
    
    if (selectedState.value == null && !isEditMode.value) {
       Get.snackbar("Error", "Please select a state");
       return;
    }

    isLoading.value = true;

    ApiResponse<Map<String, dynamic>> response;

    if (isEditMode.value) {
      // Use selected state if changed, otherwise use original state ID
      final stateId = selectedState.value?.id ?? editingProject?.stateId;
      
      if (stateId == null) {
         isLoading.value = false;
         Get.snackbar("Error", "State is required");
         return;
      }

      response = await _repository.updateProject(
        projectId: editingProject!.id,
        projectName: projectNameController.text.trim(),
        clientName: clientNameController.text.trim(),
        companyName: companyNameController.text.trim(),
        stateId: stateId,
        photoRequired: isPhotoRequired.value,
      );
    } else {
      print("DEBUG: Sending create request with: ${projectNameController.text}, ${clientNameController.text}, ${companyNameController.text}, ${selectedState.value!.id}");
      
      response = await _repository.createProject(
        projectName: projectNameController.text.trim(),
        clientName: clientNameController.text.trim(),
        companyName: companyNameController.text.trim(),
        stateId: selectedState.value!.id,
        photoRequired: isPhotoRequired.value,
      );
    }
    
    isLoading.value = false;

    if (response.success) {
      Get.snackbar("Success", response.message ?? (isEditMode.value ? "Project updated successfully!" : "Project created successfully!"));
      
      try {
        if (Get.isRegistered<HomeController>()) {
          print("DEBUG: Refreshing HomeController projects");
          final homeController = Get.find<HomeController>();
          homeController.fetchProjects(); 
        } else {
           print("DEBUG: HomeController not registered");
        }
      } catch (e) {
        print("DEBUG: Error refreshing home controller: $e");
      }
      
      print("DEBUG: Navigating back");
      FocusManager.instance.primaryFocus?.unfocus();
      await Future.delayed(Duration(milliseconds: 300));
      
      if (Get.context != null) {
        Navigator.of(Get.context!).pop(true);
      } else {
        Get.back(result: true);
      }
    } else {
      print("DEBUG: Failed to save project: ${response.message}");
      Get.snackbar("Error", response.message ?? "Failed to save project");
    }
  }

  @override
  void onClose() {
    projectNameController.dispose();
    stateController.dispose();
    clientNameController.dispose();
    companyNameController.dispose();
    super.onClose();
  }
}