import 'package:get/get.dart';

import '../../../../core/network/api_response.dart';
import '../../data/model/tree_model.dart';
import '../../data/repository/trees_repository.dart';

class TreeListController extends GetxController {
  final TreesRepository _repository = Get.find<TreesRepository>();
  
  final RxList<TreeModel> allTrees = <TreeModel>[].obs; // Store original list
  final RxList<TreeModel> trees = <TreeModel>[].obs;    // Displayed list
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Filter States
  final RxString selectedCondition = ''.obs;
  final RxString selectedOwnership = ''.obs;

  void fetchTreesByProject(String projectId) async {
    isLoading.value = true;
    errorMessage.value = '';
    allTrees.clear();
    trees.clear();
    
    final response = await _repository.getTreesByProject(projectId);
    
    isLoading.value = false;
    
    if (response.success && response.data != null) {
      allTrees.assignAll(response.data!);
      applyFilters(); // Initial populate
    } else {
      errorMessage.value = response.message ?? "Failed to load trees";
      Get.snackbar("Error", errorMessage.value);
    }
  }
  
  void applyFilters() {
    List<TreeModel> temp = List.from(allTrees);
    
    if (selectedCondition.value.isNotEmpty) {
      temp = temp.where((t) => t.condition == selectedCondition.value).toList();
    }
    
    if (selectedOwnership.value.isNotEmpty) {
      temp = temp.where((t) => t.ownership == selectedOwnership.value).toList();
    }
    
    trees.assignAll(temp);
  }
  
  void filterByCondition(String condition) {
    if (selectedCondition.value == condition) {
      selectedCondition.value = ''; // Toggle off
    } else {
      selectedCondition.value = condition;
    }
    applyFilters();
  }
  
  void filterByOwnership(String ownership) {
    if (selectedOwnership.value == ownership) {
      selectedOwnership.value = ''; // Toggle off
    } else {
      selectedOwnership.value = ownership;
    }
    applyFilters();
  }
  
  void resetFilters() {
    selectedCondition.value = '';
    selectedOwnership.value = '';
    applyFilters();
  }
}