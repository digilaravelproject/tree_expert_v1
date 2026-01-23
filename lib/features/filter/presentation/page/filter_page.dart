import 'package:tree_expert/common/widgets/bg_gradient_border.dart';
import 'package:tree_expert/widgets/basic_text_field.dart';
import 'package:tree_expert/widgets/custom_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/styles/app_decoration.dart';
import '../controller/filter_controller.dart';

class FilterBottomSheet extends GetWidget<FilterController> {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: AppDecorations.bottomSheetDecoration(context),
        height: Get.height * 0.9,
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                height: 4,
                width: 60,
                decoration: BoxDecoration(
                  color: context.theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ).marginOnly(bottom: 16),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Filters", style: context.textTheme.headlineSmall),
                TextButton(
                  onPressed: controller.resetFilters,
                  child: Text(
                    "Reset",
                    style: TextStyle(color: context.theme.primaryColor),
                  ),
                ),
              ],
            ).marginSymmetric(horizontal: 8),

            PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: context.theme.colorScheme.surface.withValues(
                    alpha: 0.12,
                  ),
                ),
                child: TabBar(
                  dividerHeight: 0,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  tabAlignment: TabAlignment.fill,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: context.theme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: context.theme.colorScheme.primary,
                  unselectedLabelColor: context.theme.colorScheme.onSurface,
                  tabs: const [
                    Tab(text: "By Criteria"),
                    Tab(text: "By Profile Id"),
                    Tab(text: "Saved Search"),
                  ],
                ),
              ),
            ),

            // Scrollable content
            Expanded(
              child: TabBarView(
                children: [
                  _buildCriteriaSection(context),
                  _buildByProfileIdSection(),
                  _buildSaveSearchSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static show() {
    Get.bottomSheet(
      const FilterBottomSheet(),
      isScrollControlled: true,
      persistent: false,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildCriteriaSection(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: Column(
            children: [

            ],
          ),
        ),
        SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: controller.applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Apply Filters",
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildByProfileIdSection() {
    return Column(
      spacing: 16,
      children: [
        AppInputTextField(
          hintText: "Eg. MMS939290",
          label: "Matrimony Id",
          iconData: CupertinoIcons.search,
        ),

        CustomButton(title: "View Profile", onPressed: () {}),
      ],
    ).marginAll(12);
  }

  Widget _buildSaveSearchSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Saved Search...",
                style: context.textTheme.titleMedium,
              ),
              Text(
                "Total (75)",
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView.separated(
            itemCount: 8,
            separatorBuilder: (context, index) {
              return SizedBox(height: 14);
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: AppDecorations.cardDecoration(context),
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Search Title",
                          style: context.textTheme.labelMedium,
                        ),
                        Icon(
                          Icons.delete,
                          size: 20,
                          color: context.theme.primaryColor,
                        ),
                      ],
                    ),
                    Text(
                      "${index * 7} Matches",
                      style: context.textTheme.titleLarge,
                    ),
                    Center(
                      child: BgGradientBorder(
                        child:
                            Text(
                              "Show Matches",
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: context.theme.primaryColor,
                              ),
                            ).marginSymmetric(
                              horizontal: Get.width * 0.1,
                              vertical: 8,
                            ),
                      ),
                    ).marginOnly(top: 12),
                  ],
                ),
              ).marginSymmetric(horizontal: 4);
            },
          ),
        ),
      ],
    );
  }
}
