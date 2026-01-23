import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/custom_app_bar.dart';
import '../controller/profile_controller.dart';
import '../../data/model/note_model.dart';
import 'package:intl/intl.dart';

class NotePage extends GetView<ProfileController> {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.notes.isEmpty) {
        controller.fetchNotes();
    }
    
    return Scaffold(
      appBar: buildAppBar(title: "Notes"),
      body: Obx(() {
        if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
        }
        if (controller.notes.isEmpty) {
            return const Center(child: Text("No notes available"));
        }
        return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notes.length,
            itemBuilder: (context, index) {
                return _buildNoteCard(controller.notes[index]);
            },
        );
      }),
    );
  }

  Widget _buildNoteCard(NoteModel note) {
      return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(note.content, style: const TextStyle(color: Colors.black87)),
                       const SizedBox(height: 12),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                              _formatDate(note.createdAt),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                      )
                  ],
              ),
          ),
      );
  }

  String _formatDate(String dateStr) {
      try {
          return DateFormat.yMMMd().format(DateTime.parse(dateStr));
      } catch (e) {
          return dateStr;
      }
  }
}
