import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/shared_prefs.dart';
import '../../features/trees/data/repository/trees_repository.dart';
import '../../features/trees/data/model/tree_entry.dart';
import '../../features/dashboard/presentation/controller/home_controller.dart';
import 'notification_service.dart';

class SyncService extends GetxService {
  final TreesRepository _treesRepository = Get.find<TreesRepository>();
  final AppNotificationService _notificationService = Get.find<AppNotificationService>();
  final RxBool isSyncing = false.obs;
  final RxMap<String, int> projectDrafts = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
  }

  /// Update the draft count for a specific project reactively
  void updateDraftCount(String projectId, int count) {
    // Wrap in microtask to avoid "setState() during build" if called from UI
    Future.microtask(() => projectDrafts[projectId] = count);
  }

  /// Reload all draft counts for known projects from storage
  void reloadAllDraftCounts(List<String> projectIds) {
    for (var id in projectIds) {
      final String key = "draft_trees_$id";
      final List<String>? encoded = SharedPrefs.getStringList(key);
      projectDrafts[id] = encoded?.length ?? 0;
    }
  }

  /// Get count of pending drafts for a specific project
  int getDraftCount(String projectId) {
    if (projectDrafts.containsKey(projectId)) {
      return projectDrafts[projectId]!;
    }
    
    final String key = "draft_trees_$projectId";
    final List<String>? encoded = SharedPrefs.getStringList(key);
    final count = encoded?.length ?? 0;
    
    // Update the map in the next microtask to avoid breaking the current build phase
    // This ensures reactivity without the "setState() during build" exception
    Future.microtask(() => projectDrafts[projectId] = count);
    
    return count;
  }

  /// Sync drafts for a specific project in the background
  Future<void> syncProjectDrafts(String projectId) async {
    if (isSyncing.value) return;
    
    final String key = "draft_trees_$projectId";
    final List<String>? initialEncoded = SharedPrefs.getStringList(key);
    
    if (initialEncoded == null || initialEncoded.isEmpty) return;
    
    final int notifyId = projectId.trim().hashCode;
    isSyncing.value = true;
    
    try {
      List<String> remainingEncoded = List.from(initialEncoded);
      int totalToSync = remainingEncoded.length;
      int successCount = 0;
      const int chunkSize = 5;

      // Initial notification
      await _notificationService.showSyncProgress(
        id: notifyId,
        title: "Syncing Tree Data",
        body: "Preparing $totalToSync trees for upload...",
        progress: 0,
        maxProgress: totalToSync,
      );

      while (remainingEncoded.isNotEmpty) {
        int currentBatchSize = (remainingEncoded.length < chunkSize) ? remainingEncoded.length : chunkSize;
        
        // Update notification progress
        await _notificationService.showSyncProgress(
           id: notifyId,
           title: "Syncing Tree Data",
           body: "Sent $successCount of $totalToSync trees...",
           progress: successCount,
           maxProgress: totalToSync,
        );

        final List<String> chunkEncoded = remainingEncoded.sublist(0, currentBatchSize);
        final List<Map<String, dynamic>> treesData = [];
        
        for (String item in chunkEncoded) {
          final TreeEntry entry = TreeEntry.fromLocalJson(jsonDecode(item));
          final jsonData = await entry.toJson();
          treesData.add(jsonData);
        }

        final response = await _treesRepository.submitTrees(treesData);
        
        if (response.success) {
          successCount += currentBatchSize;
          remainingEncoded.removeRange(0, currentBatchSize);
          
          if (remainingEncoded.isEmpty) {
            SharedPrefs.remove(key);
          } else {
            SharedPrefs.setStringList(key, remainingEncoded);
          }
          updateDraftCount(projectId, remainingEncoded.length);
          
          // Add a small delay between batches to reduce CPU load and heat
          await Future.delayed(const Duration(milliseconds: 500));
        } else {
           throw Exception(response.message ?? "Failed to sync chunk");
        }
      }

      // Final success notification
      await _notificationService.showSyncComplete(
        id: notifyId,
        title: "Sync Complete!",
        body: "Successfully uploaded $totalToSync trees.",
      );

      Get.snackbar("Sync Complete", "Successfully uploaded $totalToSync trees.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green, colorText: Colors.white);
      
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchProjects();
      }
    } catch (e) {
      print("Sync Error: $e");
      await _notificationService.cancel(notifyId);
      Get.snackbar("Sync Failed", "Could not sync trees. Error: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange, colorText: Colors.white);
    } finally {
      isSyncing.value = false;
    }
  }
}
