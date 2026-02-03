import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/features/trees/data/model/tree_model.dart';
import 'package:tree_expert/features/trees/data/repository/trees_repository.dart';
import 'download_options_bottom_sheet.dart';

class TreeSelectionBottomSheet extends StatefulWidget {
  final String projectName;
  final int projectId;
  final int treesCount;

  const TreeSelectionBottomSheet({
    super.key,
    required this.projectName,
    required this.projectId,
    required this.treesCount,
  });

  @override
  State<TreeSelectionBottomSheet> createState() => _TreeSelectionBottomSheetState();
}

class _TreeSelectionBottomSheetState extends State<TreeSelectionBottomSheet> {
  final TreesRepository _repository = Get.find<TreesRepository>();
  
  List<TreeModel> _trees = [];
  bool _isLoading = true;
  String? _error;

  String? _selectedFromTreeNo;
  String? _selectedToTreeNo;
  
  // Helper to find index locally
  int get _startIndex => _trees.indexWhere((t) => t.treeNo == _selectedFromTreeNo);
  int get _endIndex => _trees.indexWhere((t) => t.treeNo == _selectedToTreeNo);

  // Hardcoded rate per tree
  static const int _ratePerTree = 10;

  @override
  void initState() {
    super.initState();
    _fetchTrees();
  }

  Future<void> _fetchTrees() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _repository.getTreesByProject(widget.projectId.toString());
      if (response.success && response.data != null) {
        setState(() {
          _trees = response.data!;
          _isLoading = false;
          
          // Default selection: All
          if (_trees.isNotEmpty) {
            _selectedFromTreeNo = _trees.first.treeNo;
            _selectedToTreeNo = _trees.last.treeNo;
          }
        });
      } else {
        setState(() {
          _error = response.message ?? "Failed to load trees";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
        _isLoading = false;
      });
    }
  }

  int get _calculatedAmount {
    if (_startIndex == -1 || _endIndex == -1) return 0;
    
    // Ensure accurate range calculation
    final count = (_endIndex - _startIndex).abs() + 1;
    return count * _ratePerTree;
  }

  void _handlePay() {
    // Navigate to download options
    Get.back(); // Close current sheet
    Get.bottomSheet(
      DownloadOptionsBottomSheet(
        projectName: widget.projectName,
        projectId: widget.projectId,
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => Get.back(), child: Text("Close"))
          ],
        ),
      );
    }

    if (_trees.isEmpty) {
       return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("No trees available in this project."),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => Get.back(), child: Text("Close"))
          ],
        )
       );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20, 
        right: 20, 
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Handle bar
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            "Select Trees",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Total Trees: ${_trees.length}",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          
          SizedBox(height: 24),

          // Dropdowns Row
          Row(
            children: [
              // FROM
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("From Tree", style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedFromTreeNo,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      menuMaxHeight: 300,
                      items: _trees.map((t) {
                        return DropdownMenuItem(value: t.treeNo, child: Text(t.treeNo));
                      }).toList(),
                      onChanged: (val) {
                         if (val != null) {
                           setState(() {
                             _selectedFromTreeNo = val;
                             
                             // Auto-adjust To if invalid range
                             if (_startIndex > _endIndex) {
                               _selectedToTreeNo = val;
                             }
                           });
                         }
                      },
                    ),
                  ],
                ),
              ),
              
              SizedBox(width: 16),
              
              // TO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   Text("To Tree", style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedToTreeNo,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      menuMaxHeight: 300,
                      items: _trees.map((t) {
                        return DropdownMenuItem(value: t.treeNo, child: Text(t.treeNo));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                           final newIndex = _trees.indexWhere((t) => t.treeNo == val);
                           if (newIndex >= _startIndex) {
                              setState(() {
                                _selectedToTreeNo = val;
                              });
                           } else {
                             Get.snackbar("Invalid Selection", "To Tree cannot be before From Tree", snackPosition: SnackPosition.BOTTOM);
                           }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 32),
          
          // Amount and Pay Button
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade100)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Amount",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    Text(
                      "₹$_calculatedAmount",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _handlePay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    "Pay Now",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
