import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/custom_app_bar.dart';
import '../controller/profile_controller.dart';
import '../../data/model/contact_model.dart';

class ContactPage extends GetView<ProfileController> {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.contacts.isEmpty) {
        controller.fetchContacts();
    }
    
    return Scaffold(
      appBar: buildAppBar(title: "Contacts"),
      body: Obx(() {
        if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
        }
        if (controller.contacts.isEmpty) {
            return const Center(child: Text("No contacts found"));
        }
        return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.contacts.length,
            itemBuilder: (context, index) {
                return _buildContactCard(context, controller.contacts[index]);
            },
        );
      }),
    );
  }

  Widget _buildContactCard(BuildContext context, ContactModel contact) {
      return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => controller.openUrl("mailto:${contact.email}"),
                        child: Text(
                          contact.email, 
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => controller.openUrl("tel:${contact.phone}"),
                        child: Text(
                          "Phone: ${contact.phone}", 
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      if (contact.details.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(contact.details),
                      ],
                      const SizedBox(height: 12),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                             if (contact.whatsapp != null && contact.whatsapp!.isNotEmpty)
                                 IconButton(
                                   icon: const Icon(Icons.mark_chat_unread_outlined, color: Colors.green), 
                                   onPressed: () => controller.openUrl("https://wa.me/${contact.whatsapp}"),
                                 ),
                             if (contact.instagram != null && contact.instagram!.isNotEmpty)
                                 IconButton(
                                   icon: const Icon(Icons.camera_alt_outlined, color: Colors.purple), 
                                   onPressed: () => controller.openUrl(contact.instagram!),
                                 ),
                             if (contact.facebook != null && contact.facebook!.isNotEmpty)
                                 IconButton(
                                   icon: const Icon(Icons.facebook, color: Colors.blue), 
                                   onPressed: () => controller.openUrl(contact.facebook!),
                                 ),
                             if (contact.linkedin != null && contact.linkedin!.isNotEmpty)
                                 IconButton(
                                   icon: const Icon(Icons.business_center, color: Colors.blueAccent), 
                                   onPressed: () => controller.openUrl(contact.linkedin!),
                                 ),
                             if (contact.youtube != null && contact.youtube!.isNotEmpty)
                                 IconButton(
                                   icon: const Icon(Icons.video_library, color: Colors.red), 
                                   onPressed: () => controller.openUrl(contact.youtube!),
                                 ),
                          ],
                      )
                  ],
              ),
          ),
      );
  }
}
