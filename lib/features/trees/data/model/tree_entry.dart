class TreeEntry {
  String? wardPlotNo;
  String? treeNo;
  String? treeName;
  String? scientificName;
  String? family;
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
    this.treeNo,
    this.treeName,
    this.scientificName,
    this.family,
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
  
  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'user_id': userId,
      'ward_plot_no': wardPlotNo,
      'tree_no': treeNo,
      'tree_name': treeName,
      'scientific_name': scientificName,
      'family': family,
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
      'photos': photos, // This might need handling for file upload vs path
    };
  }
}
