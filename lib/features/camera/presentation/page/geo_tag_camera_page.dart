import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:screenshot/screenshot.dart';
import '../controller/geo_camera_controller.dart';

class GeoTagCameraPage extends GetView<GeoCameraController> {
  const GeoTagCameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        return Stack(
          children: [
            // --- CAPTURE AREA (Camera + Overlay) ---
            // This entire widget tree is converted to an image
            Screenshot(
              controller: controller.screenshotController,
              child: Stack(
                children: [
                   // 1. Camera Preview (Full Screen)
                   SizedBox(
                     width: Get.width,
                     height: Get.height,
                     child: CameraPreview(controller.cameraController!),
                   ),
                   
                   // 2. Premium Glassmorphic Overlay (Bottom)
                   Positioned(
                     bottom: 20,
                     left: 16,
                     right: 16,
                     child: ClipRRect(
                       borderRadius: BorderRadius.circular(24),
                       child: BackdropFilter(
                         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                         child: Container(
                           padding: const EdgeInsets.all(12),
                           decoration: BoxDecoration(
                             color: Colors.black.withOpacity(0.4),
                             borderRadius: BorderRadius.circular(24),
                             border: Border.all(color: Colors.white.withOpacity(0.2)),
                           ),
                           child: Row(
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children: [
                               // Map Preview (Left Side)
                               Container(
                                 height: 85,
                                 width: 85,
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(16),
                                   border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                                   boxShadow: [
                                     BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
                                   ]
                                 ),
                                 child: ClipRRect(
                                   borderRadius: BorderRadius.circular(15),
                                   child: controller.isLocationLoaded.value
                                     ? FlutterMap(
                                         options: MapOptions(
                                           initialCenter: controller.initialCameraPosition.value,
                                           initialZoom: 15.0,
                                           interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                                         ),
                                         children: [
                                           TileLayer(
                                             urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                             userAgentPackageName: 'com.tree.expert',
                                             subdomains: ['a', 'b', 'c'],
                                           ),
                                           MarkerLayer(
                                             markers: [
                                               Marker(
                                                 point: controller.initialCameraPosition.value,
                                                 width: 30,
                                                 height: 30,
                                                 child: const Icon(Icons.location_on, color: Colors.blue, size: 30),
                                               ),
                                             ],
                                           ),
                                         ],
                                       )
                                     : const Center(child: CupertinoActivityIndicator(color: Colors.white)),
                                 ),
                               ),
                               const SizedBox(width: 12),
                               
                               // Location Details (Right Side)
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     // Date & Time
                                     Row(
                                       children: [
                                         Icon(Icons.access_time, color: Colors.orangeAccent, size: 14),
                                         SizedBox(width: 4),
                                         Expanded(
                                           child: Obx(() => Text(
                                             controller.dateTime.value,
                                             style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                           )),
                                         ),
                                       ],
                                     ),
                                     SizedBox(height: 4),

                                     // Coordinates
                                     Row(
                                       children: [
                                         Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                                         SizedBox(width: 4),
                                         Expanded(
                                           child: Obx(() => Text(
                                             "Lat: ${controller.currentPosition.value?.latitude?.toStringAsFixed(5) ?? '...'}  Lng: ${controller.currentPosition.value?.longitude?.toStringAsFixed(5) ?? '...'}",
                                             style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                                             maxLines: 1,
                                             overflow: TextOverflow.ellipsis,
                                           )),
                                         ),
                                       ],
                                     ),
                                     SizedBox(height: 4),

                                     // Address
                                     Row(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Icon(Icons.map, color: Colors.blueAccent, size: 14),
                                         SizedBox(width: 4),
                                         Expanded(
                                           child: Obx(() => Text(
                                             controller.currentAddress.value,
                                             maxLines: 2,
                                             overflow: TextOverflow.ellipsis,
                                             style: const TextStyle(color: Colors.white70, fontSize: 11),
                                           )),
                                         ),
                                       ],
                                     ),
                                     
                                     // Accuracy Tag
                                     SizedBox(height: 4),
                                     Container(
                                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                       decoration: BoxDecoration(
                                         color: Colors.white24,
                                         borderRadius: BorderRadius.circular(4),
                                       ),
                                       child: Obx(() => Text(
                                         "Accuracy: ${controller.accuracy.value}",
                                         style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                       )),
                                     ),
                                     
                                     // Project/Tree Info (only when from Add Tree page)
                                     if (controller.isFromAddTree) ...[
                                       SizedBox(height: 6),
                                       Row(
                                         children: [
                                           Icon(Icons.folder_outlined, color: Colors.greenAccent, size: 14),
                                           SizedBox(width: 4),
                                           Obx(() => Text(
                                             "Project: ${controller.projectNo.value}  |  Tree: ${controller.treeNo.value}",
                                             style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                           )),
                                         ],
                                       ),
                                     ],
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ),
                   ),
                ],
              ),
            ),

            // --- CONTROLS (Floating above capture area) ---
            
            // Back Button
            Positioned(
              top: 50,
              left: 20,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),

            // Capture Button (Floating at Bottom Center - Moved up to avoid overlap)
            Positioned(
              bottom: 160, 
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      print("Capture button tapped!"); // Debug log
                      // Check if saveToGallery is passed in arguments
                      final args = Get.arguments;
                      final bool saveToGallery = args is Map && args['saveToGallery'] == false ? false : true;
                      await controller.captureAndSave(saveToGallery: saveToGallery);
                    },
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 4),
                        color: Colors.white.withValues(alpha: 0.1),
                        boxShadow: [
                           BoxShadow(color: Colors.black26, blurRadius: 15, spreadRadius: 2)
                        ]
                      ),
                      child: Center(
                        child: Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                             color: Colors.white,
                             shape: BoxShape.circle,
                          ),
                          child: Icon(CupertinoIcons.camera_fill, color: Colors.black54, size: 32),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
