import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/features/projects/presentation/controller/add_project_controller.dart';
import 'package:tree_expert/widgets/basic_text_field.dart';
import 'package:tree_expert/widgets/custom_buttons.dart';

class AddProjectPage extends GetWidget<AddProjectController> {
  const AddProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isEditMode.value ? "Edit Project" : "Add New Project",
          style: TextStyle(fontWeight: FontWeight.w800),
        )),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.theme.primaryColor,
                          context.theme.primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.theme.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.folder_special,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Project Details",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Fill in the information below",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Form Section
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          icon: Icons.business_center,
                          title: "Basic Information",
                        ),
                        SizedBox(height: 16),
                        
                        _buildEnhancedTextField(
                          controller: controller.projectNameController,
                          label: "Project Name",
                          hint: "Enter project name",
                          icon: Icons.folder_outlined,
                        ),
                        SizedBox(height: 16),
                        
                        _buildEnhancedTextField(
                          controller: controller.clientNameController,
                          label: "Client Name",
                          hint: "Enter client name",
                          icon: Icons.person_outline,
                        ),
                        SizedBox(height: 16),
                        
                        _buildEnhancedTextField(
                          controller: controller.companyNameController,
                          label: "Company Name",
                          hint: "Enter company name",
                          icon: Icons.business_outlined,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Location Section
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          icon: Icons.location_on,
                          title: "Location Details",
                        ),
                        SizedBox(height: 16),
                        
                        _buildEnhancedTextField(
                          controller: controller.stateController,
                          label: "State",
                          hint: "Select state",
                          icon: Icons.map_outlined,
                          readOnly: true,
                          onTap: () => _showStateSelectionBottomSheet(context),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 100), // Space for button
                ],
              ),
            ),
          ),

          // Bottom Button
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.saveProject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            controller.isEditMode.value ? Icons.check_circle : Icons.add_circle,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            controller.isEditMode.value ? "Update Project" : "Create Project",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              )),
            ),
          ),
        ],
      ),
    );
  }

  void _showStateSelectionBottomSheet(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Select State",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search state...",
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) {
                  // Trigger rebuild using GetX typically, or use StatefulBuilder.
                  // Since we are inside Get.bottomSheet and accessing controller.statesList which is Obx,
                  // we can use a local RxString for search query
                  controller.update(); // Just to trigger update if we used GetBuilder, but here we can't easily.
                  // Let's use a nested Obx or StatefulBuilder for the list
                  // Actually, modifying a reactive variable in controller is better.
                  // But let's use StatefulBuilder inside the list part to keep it simple without adding search var to controller
                  // Wait, modifying controller is cleaner. let's add filtering logic in the Obx below
                },
              ),
            ),
            
            SizedBox(height: 10),
            
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, child) {
                  final query = value.text.toLowerCase();
                  
                  return Obx(() {
                    if (controller.statesList.isEmpty) {
                       return Center(child: CircularProgressIndicator());
                    }

                    final filteredStates = controller.statesList.where((state) {
                      return state.stateName.toLowerCase().contains(query);
                    }).toList();
                    
                    if (filteredStates.isEmpty) {
                      return Center(child: Text("No states found"));
                    }

                    return ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredStates.length,
                      separatorBuilder: (c, i) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final state = filteredStates[index];
                        // Access selectedState.value inside Obx to trigger rebuild on selection change
                        final isSelected = controller.selectedState.value?.id == state.id;
                        
                        return InkWell(
                          onTap: () {
                            controller.selectState(state);
                            Get.back();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            color: isSelected ? context.theme.primaryColor.withOpacity(0.05) : null,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    state.stateName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? context.theme.primaryColor : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check, color: context.theme.primaryColor, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  });
                }
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Get.theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Get.theme.primaryColor),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
            suffixIcon: readOnly ? Icon(Icons.arrow_drop_down, color: Colors.grey.shade600) : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Get.theme.primaryColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
