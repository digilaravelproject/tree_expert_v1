import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class TreeEntry {
  String? wardPlotNo;
  String? plotNo;
  String? treeNo;
  String? treeName;
  String? treeId;
  String? scientificName;
  String? scientificNameId;
  String? family;
  String? familyId;
  String? girth;
  String? height;
  String? canopy;
  String? age;
  String? condition;
  String? proposedFor;
  String? ownership;
  String? address;
  String? landmark;
  String? concernPerson;
  String? remark;
  String? latitude;
  String? longitude;
  String? accuracy;
  String? unit;
  String? projectId;
  String? userId;
  List<String> photos;

  TreeEntry({
    this.projectId,
    this.userId,
    this.wardPlotNo,
    this.plotNo,
    this.treeNo,
    this.treeName,
    this.treeId,
    this.scientificName,
    this.scientificNameId,
    this.family,
    this.familyId,
    this.girth,
    this.height,
    this.canopy,
    this.age,
    this.condition,
    this.proposedFor,
    this.ownership,
    this.address,
    this.landmark,
    this.concernPerson,
    this.remark,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.unit,
    this.photos = const [],
  });
  
  /// Convert image file paths to compressed base64 strings
  Future<List<String>> _convertPhotosToBase64() async {
    List<String> base64Images = [];
    
    for (String photoPath in photos) {
      try {
        final file = File(photoPath);
        if (await file.exists()) {
           // We now trust the file is already compressed on capture for better heat management
           final bytes = await file.readAsBytes();
           final base64String = base64Encode(bytes);
           base64Images.add(base64String);
        }
      } catch (e) {
        print("Error encoding photo to base64: $e");
      }
    }
    
    return base64Images;
  }
  
  Future<Map<String, dynamic>> toJson() async {
    // Convert photos to base64 and join with commas
    final base64Images = await _convertPhotosToBase64();
    final photosString = base64Images.join(',');
    
    // Determine the base tree name to use as fallback
    final String displayTreeName = (treeId != null && treeId!.isNotEmpty) ? treeId! : (treeName ?? '');
    
    // Determine scientific name: use ID if present, else use scientificName if not empty, else fallback to displayTreeName
    final String finalScientificName = (scientificNameId != null && scientificNameId!.isNotEmpty) 
        ? scientificNameId! 
        : (scientificName != null && scientificName!.trim().isNotEmpty) 
            ? scientificName! 
            : displayTreeName;

    // Determine family name: use ID if present, else use family if not empty, else fallback to displayTreeName
    final String finalFamily = (familyId != null && familyId!.isNotEmpty) 
        ? familyId! 
        : (family != null && family!.trim().isNotEmpty) 
            ? family! 
            : displayTreeName;

    return {
      'project_id': projectId,
      'user_id': userId,
      'project_id': projectId,
      'user_id': userId,
      'ward_plot_no': wardPlotNo,
      'plot_no': plotNo,
      'tree_no': treeNo,
      'tree_name': displayTreeName,
      'tree_id': treeId,
      'scientific_name': finalScientificName,
      'scientific_name_id': scientificNameId,
      'family': finalFamily,
      'family_name_id': familyId,
      'girth': girth,
      'height': height,
      'canopy': canopy,
      'age': age,
      'condition': condition,
      'proposed_for': proposedFor,
      'ownership': ownership,
      'address': address,
      'landmark': landmark,
      'concern_person': concernPerson,
      'remark': remark,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'unit': unit,
      'tree_image_upload': photosString, // Base64 images as comma-separated string
    };
  }

  /// Convert to simple JSON for local drafts storage (uses paths, not base64)
  Map<String, dynamic> toLocalJson() {
    return {
      'wardPlotNo': wardPlotNo,
      'plotNo': plotNo,
      'treeNo': treeNo,
      'treeName': treeName,
      'treeId': treeId,
      'scientificName': scientificName,
      'scientificNameId': scientificNameId,
      'family': family,
      'familyId': familyId,
      'girth': girth,
      'height': height,
      'canopy': canopy,
      'age': age,
      'condition': condition,
      'proposedFor': proposedFor,
      'ownership': ownership,
      'address': address,
      'landmark': landmark,
      'concernPerson': concernPerson,
      'remark': remark,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'unit': unit,
      'projectId': projectId,
      'userId': userId,
      'photos': photos,
    };
  }

  /// Create TreeEntry from simple local JSON drafts storage
  factory TreeEntry.fromLocalJson(Map<String, dynamic> json) {
    return TreeEntry(
      wardPlotNo: json['wardPlotNo'],
      plotNo: json['plotNo'],
      treeNo: json['treeNo'],
      treeName: json['treeName'],
      treeId: json['treeId'],
      scientificName: json['scientificName'],
      scientificNameId: json['scientificNameId'],
      family: json['family'],
      familyId: json['familyId'],
      girth: json['girth'],
      height: json['height'],
      canopy: json['canopy'],
      age: json['age'],
      condition: json['condition'],
      proposedFor: json['proposedFor'],
      ownership: json['ownership'],
      address: json['address'],
      landmark: json['landmark'],
      concernPerson: json['concernPerson'],
      remark: json['remark'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      accuracy: json['accuracy'],
      unit: json['unit'],
      projectId: json['projectId'],
      userId: json['userId'],
      photos: List<String>.from(json['photos'] ?? []),
    );
  }
}
