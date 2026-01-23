import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../../widgets/custom_app_bar.dart';
import '../controller/profile_controller.dart';

class PrivacyPolicyPage extends GetView<ProfileController> {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.privacyPolicy.value == null) {
        controller.fetchPrivacyPolicy();
    }

    return Scaffold(
      appBar: buildAppBar(title: "Privacy Policy"),
      body: Obx(() {
        if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
        }
        if (controller.privacyPolicy.value == null) {
            return const Center(child: Text("Failed to load policy"));
        }
        
        return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                        controller.privacyPolicy.value!.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Html(data: controller.privacyPolicy.value!.content),
                ],
            ),
        );
      }),
    );
  }
}
