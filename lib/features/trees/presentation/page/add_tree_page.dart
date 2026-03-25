import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../controller/add_tree_controller.dart';

class AddTreesPage extends GetWidget<AddTreeController> {
  const AddTreesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Obx(() => Text(
                "Add Tree (${controller.currentTreeIndex.value + 1})",
                style: TextStyle(fontWeight: FontWeight.w800),
              )),
          centerTitle: true,
          elevation: 0,
        ),
        body: Obx(() => Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // SECTION 1: Basic Information
                    _buildSectionCard(
                     // title: "Basic Information",
                     // icon: Icons.info_outline,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                textController: controller.wardPlotNoController,
                                label: "Ward No",
                                keyboardType: TextInputType.number,
                                reqKey: "ward_plot_no",
                                hint: "Enter ward number",
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                textController: controller.treeNoController,
                                label: "Tree No",
                                reqKey: "tree_no",
                                hint: "Auto",
                                enabled: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                        _buildTextField(
                            textController: controller.plotNoController,
                            label: "Plot No",
                            reqKey: "plot_no",
                            keyboardType: TextInputType.number,
                            hint: "Enter plot number",
                          ),


                        SizedBox(height: 8),
                    // SECTION 2: Tree Details
                    _buildSectionCard(
                     // title: "Tree Details",
                     // icon: Icons.park,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _showTreeSelectionSheet(context);
                                },
                                child: AbsorbPointer(
                                  child: _buildTextField(
                                    textController: controller.treeNameController,
                                    label: "Tree Name",
                                    reqKey: "tree_name",
                                    hint: "Select Tree",
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),

                            Container(
                              decoration: BoxDecoration(
                                color: context.theme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: context.theme.primaryColor,
                                  width: 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _showAddTreeSheet(context),
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  height: 45,
                                  width: 45,
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: context.theme.primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                       /*     Container(
                                decoration: BoxDecoration(
                                  color: context.theme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: context.theme.primaryColor,
                                    width: 1,
                                  ),
                                ),
                                child:
                                IconButton(
                                  onPressed: () => _showAddTreeSheet(context),
                                  icon: Icon(
                                    Icons.add,
                                    color: context.theme.primaryColor,
                                    size: 24,
                                  ),
                                  tooltip: "Add New Tree",
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(
                                    minHeight: 45,
                                    minWidth: 45,
                                  ),
                                ),
                              ),*/
                          ],
                        ),
                        // SizedBox(height: 12),
                        // _buildTextField(
                        //   textController: controller.scientificNameController,
                        //   label: "Scientific Name",
                        //   hint: "Auto-filled",
                        //   enabled: false,
                        // ),
                        // SizedBox(height: 12),
                        // _buildTextField(
                        //   textController: controller.familyController,
                        //   label: "Family",
                        //   hint: "Auto-filled",
                        //   enabled: false,
                        // ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // SECTION 3: Measurements
                    _buildSectionCard(
                     // title: "Measurements",
                     // icon: Icons.straighten,
                      children: [
                        // Unit Toggle
                        Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Unit: ", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                                /*ChoiceChip(
                                  label: Text("Meter"),
                                  selected:
                                      controller.selectedUnit.value == 'Meter',
                                  onSelected: (_) => controller.toggleUnit(),
                                ),
                                SizedBox(width: 10),*/
                                ChoiceChip(
                                  label: Text("Feet"),
                                  selected:
                                      controller.selectedUnit.value == 'Feet',
                                  onSelected: (_) => controller.toggleUnit(),
                                ),
                              ],
                            )),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                textController: controller.girthController,
                                label: "Girth (cm)",
                                reqKey: "girth",
                                hint: "0.0",
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Obx(() => _buildTextField(
                                    textController: controller.heightController,
                                    label:
                                        "Height (${controller.selectedUnit.value == 'Meter' ? 'm' : 'ft'})",
                                    reqKey: "height",
                                    hint: controller.isCalculating.value
                                        ? "Calculating..."
                                        : "0.0",
                                    keyboardType: TextInputType.number,
                                    enabled: !controller.isCalculating.value,
                                  )),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Obx(() => _buildTextField(
                                textController: controller.canopyController,
                                label:
                                "Canopy (${controller.selectedUnit.value == 'Meter' ? 'm' : 'ft'})",
                                reqKey: "canopy",
                                hint: controller.isCalculating.value
                                    ? "Calculating..."
                                    : "0.0",
                                keyboardType: TextInputType.number,
                                enabled: !controller.isCalculating.value,
                              )),
                            ),
                          ],
                        ),

                      ],
                    ),

                    SizedBox(height: 8),

                    // SECTION 4: Tree Status
                    _buildSectionCard(
                      //title: "Tree Status",
                     // icon: Icons.health_and_safety,
                      children: [
                        _buildTextField(
                          textController: controller.ageController,
                          label: "Age (years)",
                          reqKey: "age",
                          hint: "Enter age",
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 8),
                        _buildDropdown(
                          label: "Condition",
                          reqKey: "condition",
                          value: controller.selectedCondition,
                          items: controller.conditions,
                        ),
                        SizedBox(height: 8),
                        _buildDropdown(
                          label: "Proposed For",
                          value: controller.selectedProposedFor,
                          items: controller.proposedForOptions,
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    // SECTION 5: Location Details
                    _buildSectionCard(
                     // title: "Location Details",
                     // icon: Icons.location_on,
                      children: [
                        // _buildTextField(
                        //   textController: controller.addressController,
                        //   label: "Address",
                        //   reqKey: "address",
                        //   hint: "Auto-captured from GPS",
                        //   maxLines: 2,
                        //   enabled: false,
                        // ),
                       // SizedBox(height: 8),
                        _buildTextField(
                          textController: controller.landmarkController,
                          label: "Landmark",
                          reqKey: "landmark",
                          hint: "Enter nearby landmark",
                        ),
                        SizedBox(height: 8),
                        _buildDropdown(
                          label: "Ownership",
                          reqKey: "ownership",
                          value: controller.selectedOwnership,
                          items: controller.ownershipOptions,
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    // SECTION 6: Additional Information
                    _buildSectionCard(
                     // title: "Additional Information",
                     // icon: Icons.note,
                      children: [
                        _buildTextField(
                          textController: controller.concernPersonController,
                          label: "Concern Person Name",
                          hint: "Enter name",
                        ),
                        SizedBox(height: 8),
                        _buildTextField(
                          textController: controller.remarkController,
                          label: "Remark",
                          hint: "Any additional notes",
                          maxLines: 2,
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    // SECTION 7: GPS & Photo
                    _buildSectionCard(
                     // title: "Add Photo",
                     // icon: Icons.camera_alt,
                      children: [
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: _buildTextField(
                        //         textController: controller.latitudeController,
                        //         label: "Latitude",
                        //         hint: "Auto",
                        //         enabled: false,
                        //       ),
                        //     ),
                        //     SizedBox(width: 12),
                        //     Expanded(
                        //       child: _buildTextField(
                        //         textController: controller.longitudeController,
                        //         label: "Longitude",
                        //         hint: "Auto",
                        //         enabled: false,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 12),
                        // _buildTextField(
                        //   textController: controller.accuracyController,
                        //   label: "Accuracy",
                        //   hint: "Auto",
                        //   enabled: false,
                        // ),
                        // SizedBox(height: 16),

                        // Photo Capture - Grid with Photos + Add Button
                        Obx(() {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Captured Photos ${controller.capturedPhotos.isNotEmpty ? '(${controller.capturedPhotos.length})' : ''}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  if (controller.fieldRequirements.containsKey('all_captured_images'))
                                    Obx(() {
                                      bool isRequired = false;
                                      final fieldData = controller.fieldRequirements['all_captured_images'];
                                      if (fieldData is Map && fieldData.containsKey('is_required')) {
                                          final rules = fieldData['is_required'];
                                          if (rules is Map) {
                                            isRequired = rules['is_required'] == true;
                                          }
                                      }
                                      if (isRequired) {
                                         return Text(" *",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold));
                                      }
                                      return SizedBox.shrink();
                                    }),
                                ],
                              ),
                              if (controller.capturedPhotos.isNotEmpty)
                                SizedBox(height: 12),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1,
                                ),
                                itemCount:
                                    controller.capturedPhotos.length + 1,
                                itemBuilder: (context, index) {
                                  // Add button as last item
                                  if (index == controller.capturedPhotos.length) {
                                    return GestureDetector(
                                      onTap: controller.capturePhoto,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: context.theme.primaryColor
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: context.theme.primaryColor,
                                            width: 2,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              color: context.theme.primaryColor,
                                              size: 32,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "Add Photo",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: context.theme.primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  // Photo item
                                  return GestureDetector(
                                    onTap: () => _showZoomedImage(context, index),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.file(
                                            File(controller.capturedPhotos[index]),
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => controller
                                                .removePhoto(index),
                                            child: Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                    //
                    // SizedBox(height: 8),
                    // InkWell(
                    //   onTap: () => controller.isAddMultiple.toggle(),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     children: [
                    //       Transform.scale(
                    //         scale: 1.1,
                    //         child: Checkbox(
                    //           value: controller.isAddMultiple.value,
                    //           activeColor: Colors.green.shade700,
                    //           onChanged: (val) => controller.isAddMultiple.value = val ?? false,
                    //         ),
                    //       ),
                    //       Text(
                    //         "Add Multiple Trees",
                    //         style: TextStyle(
                    //             fontWeight: FontWeight.w600,
                    //             fontSize: 15,
                    //             color: Colors.black87
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Buttons
            Container(
              padding: EdgeInsets.only(top: 8, bottom: 12, left: 16, right: 16),
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
                child: Obx(() => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // // Show tree count info
                    // if (controller.localTrees.isNotEmpty)
                    //   Container(
                    //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    //     margin: EdgeInsets.only(bottom: 12),
                    //     decoration: BoxDecoration(
                    //       color: Colors.blue[50],
                    //       borderRadius: BorderRadius.circular(8),
                    //       border: Border.all(color: Colors.blue[200]!),
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    //         SizedBox(width: 8),
                    //         Expanded(
                    //           child: Text(
                    //             "${controller.localTrees.length} tree(s) added. Current: Tree ${controller.currentTreeIndex.value + 1}",
                    //             style: TextStyle(
                    //               color: Colors.blue[700],
                    //               fontSize: 13,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),

                    // Navigation Buttons Row
                    Row(
                      children: [
                        // Previous Button
                        if (controller.currentTreeIndex.value > 0)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.onPrevious,
                              icon: Icon(Icons.arrow_back, size: 18),
                              label: Text("Previous"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                        if (controller.currentTreeIndex.value > 0)
                          SizedBox(width: 12),

                        // Add & Next Button
                        Expanded(
                          flex: controller.currentTreeIndex.value > 0 ? 1 : 2,
                          child: ElevatedButton.icon(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.onContinue,
                            icon: Icon(Icons.add, size: 18),
                            label: Text("Add & Next"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Final Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.handleSubmit,
                        icon: Icon(Icons.check_circle, size: 18),
                        label: Text(
                          controller.localTrees.isEmpty
                              ? "Submit"
                              : "Final Submit (${controller.localTrees.length + 1} trees)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
              ),
            ),
          ],
        ),
        
        // Loading Overlay
        if (controller.isLoading.value)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.green.shade700,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Submitting Tree Data...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Please wait while we process your data",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: Text("Discard Changes?"),
            content: Text(
                "Are you sure you want to discard your changes and go back?"),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false), // Stay
                child: Text("No"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () => Get.back(result: true), // Pop
                child: Text("Yes, Discard"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildSectionCard({
    // required String title,
    // required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(12),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.05),
      //       blurRadius: 10,
      //       offset: Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     Container(
          //       padding: EdgeInsets.all(8),
          //       decoration: BoxDecoration(
          //         color: Get.theme.primaryColor.withOpacity(0.1),
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       child: Icon(icon, size: 20, color: Get.theme.primaryColor),
          //     ),
          //     SizedBox(width: 12),
          //     Text(
          //       title,
          //       style: TextStyle(
          //         fontSize: 16,
          //         fontWeight: FontWeight.bold,
          //         color: Colors.black87,
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController textController,
    required String label,
    required String hint,
    String? reqKey,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    FocusNode? focusNode,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reqKey != null)
          Obx(() {
            bool isRequired = false;
            // Check if key exists
            if (controller.fieldRequirements.containsKey(reqKey)) {
               final fieldData = controller.fieldRequirements[reqKey];
               // Handle nested structure from API
               if (fieldData is Map && fieldData.containsKey('is_required')) {
                   final rules = fieldData['is_required'];
                   if (rules is Map) {
                     isRequired = rules['is_required'] == true;
                   } else if (rules is bool) {
                     isRequired = rules;
                   }
               }
            }
            return _buildRichLabel(label, isRequired);
          })
        else
          _buildRichLabel(label, false),
        SizedBox(height: 6),
        TextField(
          controller: textController,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          focusNode: focusNode,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Get.theme.primaryColor, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildRichLabel(String label, bool isRequired) {
    return RichText(
      text: TextSpan(
          text: label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              fontFamily: 'Inter'),
          children: [
            if (isRequired)
              TextSpan(
                  text: " *",
                  style: TextStyle(color: Colors.red, fontSize: 13)),
          ]),
    );
  }

  Widget _buildDropdown({
    required String label,
    required RxString value,
    required List<String> items,
    String? reqKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reqKey != null)
          Obx(() {
            bool isRequired = false;
            if (controller.fieldRequirements.containsKey(reqKey)) {
               final fieldData = controller.fieldRequirements[reqKey];
               if (fieldData is Map && fieldData.containsKey('is_required')) {
                  // Nested check
                   final rules = fieldData['is_required'];
                   if (rules is Map) {
                     isRequired = rules['is_required'] == true;
                   } else if (rules is bool) {
                     isRequired = rules;
                   }
               }
            }
            return _buildRichLabel(label, isRequired);
          })
        else
          _buildRichLabel(label, false),
        SizedBox(height: 6),
        Obx(() => DropdownButtonFormField<String>(
              value: value.value,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Get.theme.primaryColor, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  value.value = newValue;
                }
              },
            )),
      ],
    );
  }

  void _showZoomedImage(BuildContext context, int initialIndex) {
    final RxInt currentIndex = initialIndex.obs;
    final RxBool showControls = true.obs; // Toggle for immersive mode
    final PageController pageController =
        PageController(initialPage: initialIndex);

    Get.dialog(
      Material(
        color: Colors.black,
        child: Stack(
          children: [
            // 1. Main Image Viewer (PageView)
            Positioned.fill(
              child: PageView.builder(
                controller: pageController,
                itemCount: controller.capturedPhotos.length,
                onPageChanged: (index) => currentIndex.value = index,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => showControls.value =
                        !showControls.value, // Toggle controls
                    child: Container(
                      padding: EdgeInsets.only(
                          bottom: 100), // Space for bottom thumbnails
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Center(
                          child: Image.file(
                            File(controller.capturedPhotos[index]),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. Top Bar (Gradient + Close + Counter)
            Obx(() => AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: showControls.value ? 0 : -100, // Hide by moving up
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 40, 16, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Close Button
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close,
                                color: Colors.white, size: 24),
                          ),
                        ),

                        // Counter Pill
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            "${currentIndex.value + 1} / ${controller.capturedPhotos.length}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

            // 3. Bottom Thumbnail Strip (Gradient + List)
            Obx(() => AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  bottom: showControls.value ? 0 : -120, // Hide by moving down
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.9)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemCount: controller.capturedPhotos.length,
                      itemBuilder: (context, index) {
                        return Obx(() {
                          // Listen to currentIndex changes for selection style
                          final isSelected = currentIndex.value == index;
                          return GestureDetector(
                            onTap: () {
                              currentIndex.value = index;
                              pageController.animateToPage(
                                index,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              margin: EdgeInsets.only(right: 12),
                              width: isSelected
                                  ? 60
                                  : 50, // Active item is larger
                              height: isSelected ? 60 : 50,
                              decoration: BoxDecoration(
                                border: isSelected
                                    ? Border.all(
                                        color: context.theme.primaryColor,
                                        width: 2)
                                    : Border.all(
                                        color: Colors.white30, width: 1),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                            color: context.theme.primaryColor
                                                .withOpacity(0.5),
                                            blurRadius: 8)
                                      ]
                                    : [],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(
                                  File(controller.capturedPhotos[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                )),
          ],
        ),
      ),
      barrierColor: Colors.black,
      useSafeArea: false,
    );
  }

  void _showTreeSelectionSheet(BuildContext context) {
    // Local search controller for the sheet
    final searchController = TextEditingController();
    final RxString searchQuery = ''.obs;

    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Text(
              "Select Tree",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Search Bar
            TextField(
              controller: searchController,
              onChanged: (val) => searchQuery.value = val,
              decoration: InputDecoration(
                hintText: "Search trees...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            SizedBox(height: 12),

            // List
            Expanded(
              child: Obx(() {
                if (controller.isLoadingTrees.value) {
                  return Center(child: CircularProgressIndicator());
                }

                final trees = controller.trees.where((tree) {
                  final query = searchQuery.value.toLowerCase();
                  return tree.treeName.toLowerCase().contains(query) ||
                      tree.scientificName.toLowerCase().contains(query);
                }).toList();

                if (trees.isEmpty) {
                  return Center(
                    child: Text("No trees found"),
                  );
                }

                return ListView.separated(
                  itemCount: trees.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tree = trees[index];
                    return ListTile(
                      title: Text(
                        tree.treeName,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "${tree.scientificName} • ${tree.family}",
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      onTap: () {
                        controller.selectTree(tree);
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAddTreeSheet(BuildContext context) {
    final nameController = TextEditingController();
    final familyController = TextEditingController();
    final scientificController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 5,
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.park_rounded,
                      color: context.theme.primaryColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 14),
                  Text(
                    "Add New Tree",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              _buildSheetField("Tree Name", "Enter tree name", nameController,
                  Icons.label_rounded),
              SizedBox(height: 18),
              _buildSheetField("Family Name", "Enter family name",
                  familyController, Icons.category_rounded),
              SizedBox(height: 18),
              _buildSheetField("Scientific Name", "Enter scientific name",
                  scientificController, Icons.biotech_rounded),

              SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [
                        context.theme.primaryColor,
                        context.theme.primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.theme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      final family = familyController.text.trim();
                      final scientific = scientificController.text.trim();

                      if (name.isEmpty || family.isEmpty || scientific.isEmpty) {
                        Get.snackbar(
                          "Required",
                          "All fields are required",
                          backgroundColor: Colors.red.shade700,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                        return;
                      }

                      controller.addNewTree(
                        name: name,
                        scientificName: scientific,
                        familyName: family,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildSheetField(String label, String hint,
      TextEditingController textController, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        TextField(
          controller: textController,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon,
                size: 20,
                color: Get.theme.primaryColor.withValues(alpha: 0.6)),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Get.theme.primaryColor, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
