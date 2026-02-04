import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/features/trees/data/model/tree_model.dart';
import 'package:tree_expert/features/trees/data/repository/trees_repository.dart';
import '../../../../core/constent/app_constants.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../../../auth/services/auth_service.dart';
import '../../../razorpay/payment_repository.dart';
import '../../../razorpay/razorpay_controller.dart';
import 'download_options_bottom_sheet.dart';

class TreeSelectionBottomSheet extends StatefulWidget {
  final String projectName;
  final int projectId;
  final int treesCount;
  final double activeTreePrice;

  const TreeSelectionBottomSheet({
    super.key,
    required this.projectName,
    required this.projectId,
    required this.treesCount,
    required this.activeTreePrice,
  });

  @override
  State<TreeSelectionBottomSheet> createState() => _TreeSelectionBottomSheetState();
}

class _TreeSelectionBottomSheetState extends State<TreeSelectionBottomSheet> {
  final TreesRepository _repository = Get.find<TreesRepository>();
  final PaymentRepository _paymentRepository = PaymentRepository();
  final RazorpayController razorpayController = Get.put(RazorpayController());

  List<TreeModel> _allTrees = [];
  bool _isLoading = true;
  bool _isProcessingPayment = false;
  String? _error;

  int? _selectedFromCount;
  int? _selectedToCount;

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
          _allTrees = response.data!;
          _isLoading = false;
          
          // Default selection: All trees
          if (_allTrees.isNotEmpty) {
            _selectedFromCount = 1;
            _selectedToCount = _allTrees.length;
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

  // Get selected trees based on from/to count
  List<TreeModel> get _selectedTrees {
    if (_selectedFromCount == null || _selectedToCount == null || _allTrees.isEmpty) {
      return [];
    }
    final startIdx = _selectedFromCount! - 1;
    final endIdx = _selectedToCount!;
    return _allTrees.sublist(startIdx, endIdx.clamp(0, _allTrees.length));
  }

  // Get tree IDs of selected trees
  List<int> get _selectedTreeIds {
    return _selectedTrees.map((t) => t.id).toList();
  }

  // Get tree IDs of selected unpaid trees only
  List<int> get _selectedUnpaidTreeIds {
    return _selectedTrees.where((t) => t.payment == 0).map((t) => t.id).toList();
  }

  int get _selectedTreeCount {
    if (_selectedFromCount == null || _selectedToCount == null) return 0;
    return (_selectedToCount! - _selectedFromCount!).abs() + 1;
  }

  // Count of unpaid trees in selection
  int get _selectedUnpaidTreeCount {
    return _selectedTrees.where((t) => t.payment == 0).length;
  }

  double get _calculatedAmount {
    return _selectedUnpaidTreeCount * widget.activeTreePrice;
  }

  // Check if all selected trees are already paid OR if it's company login
  bool get _allSelectedTreesPaid {
    final bool isCompany = Get.find<AuthService>().isCompanyLogin.value;
    if (isCompany) return true; // Company can access everything without payment
    
    return _selectedTrees.isNotEmpty && _selectedTrees.every((t) => t.payment == 1);
  }

  Future<void> _handlePay() async {
    if (_selectedUnpaidTreeIds.isEmpty) {
      Get.snackbar("Error", "No unpaid trees selected", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Get user ID
      final userId = SharedPrefs.getInt(AppConstants.userIdPref) ?? 0;
      
      // Call create-order API with only unpaid tree IDs
      final response = await _paymentRepository.createOrder(
        userId: userId,
        amount: _calculatedAmount.toInt(),
        treeIds: _selectedUnpaidTreeIds,
      );

      if (response.success && response.data != null) {
        final orderId = response.data!['order_id'] as String?;
        final key = response.data!['key'] as String?;
        
        razorpayController.openCheckout(
          amount: _calculatedAmount.toInt(),
          name: 'Tree Expert',
          description: 'Project: ${widget.projectName}',
          mobile: '9651017054', // Get from user profile ideally
          email: 'awantikayadav014@gmail.com', // Get from user profile
          orderId: orderId,
          key: key,
          treeIds: _selectedUnpaidTreeIds,
          userId: userId,
        );
        Get.back();

      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Failed to create order",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to process payment: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  void _handleView() {
    // Close current sheet and open download options with selected tree IDs
    Get.back();
    Get.bottomSheet(
      DownloadOptionsBottomSheet(
        projectName: widget.projectName,
        projectId: widget.projectId,
        selectedTreeIds: _selectedTreeIds,
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

    // If no trees available
    if (_allTrees.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, color: Colors.orange, size: 40),
            SizedBox(height: 12),
            Text("No trees found in this project", textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => Get.back(), child: Text("Close"))
          ],
        ),
      );
    }
    
    // Generate count list (1, 2, 3, ...)
    final countList = List<int>.generate(_allTrees.length, (i) => i + 1);
    
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
            "Total Trees: ${_allTrees.length} | Paid: ${_allTrees.where((t) => t.payment == 1).length} | Unpaid: ${_allTrees.where((t) => t.payment == 0).length}",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          SizedBox(height: 4),
          Text(
            "Rate: ₹${widget.activeTreePrice.toStringAsFixed(2)} per tree",
            style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600),
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
                    DropdownButtonFormField<int>(
                      value: _selectedFromCount,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      menuMaxHeight: 300,
                      items: countList.map((count) {
                        final tree = _allTrees[count - 1];
                        final isPaid = tree.payment == 1;
                        return DropdownMenuItem(
                          value: count, 
                          child: Row(
                            children: [
                              Text("$count"),
                              SizedBox(width: 4),
                              Text("(${tree.treeNo})", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              SizedBox(width: 4),
                              if (isPaid) 
                                Icon(Icons.check_circle, size: 16, color: Colors.green)
                              else
                                Icon(Icons.radio_button_unchecked, size: 16, color: Colors.orange),
                            ],
                          )
                        );
                      }).toList(),
                      onChanged: (val) {
                         if (val != null) {
                           setState(() {
                             _selectedFromCount = val;
                             
                             // Reset To selection if it's now invalid
                             if (_selectedToCount != null && _selectedToCount! < val) {
                               _selectedToCount = val; // Set to same as from (minimum valid value)
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
                    DropdownButtonFormField<int>(
                      value: _selectedToCount,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      menuMaxHeight: 300,
                      items: _selectedFromCount == null 
                        ? [] 
                        : countList.where((count) => count >= _selectedFromCount!).map((count) {
                            final tree = _allTrees[count - 1];
                            final isPaid = tree.payment == 1;
                            return DropdownMenuItem(
                              value: count, 
                              child: Row(
                                children: [
                                  Text("$count"),
                                  SizedBox(width: 4),
                                  Text("(${tree.treeNo})", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  SizedBox(width: 4),
                                  if (isPaid) 
                                    Icon(Icons.check_circle, size: 16, color: Colors.green)
                                  else
                                    Icon(Icons.radio_button_unchecked, size: 16, color: Colors.orange),
                                ],
                              )
                            );
                          }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedToCount = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Selection Summary
          if (_selectedFromCount != null && _selectedToCount != null) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selection Summary",
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue.shade800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Selected: $_selectedTreeCount trees | Paid: ${_selectedTreeCount - _selectedUnpaidTreeCount} | Unpaid: $_selectedUnpaidTreeCount",
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],

          // Action Buttons
          if (_selectedFromCount != null && _selectedToCount != null) ...[
            if (_allSelectedTreesPaid) ...[
              // All selected trees are paid OR company login - show View button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleView,
                  icon: Icon(Icons.visibility),
                  label: Text("View / Download"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              // Show company access message if applicable
              if (Get.find<AuthService>().isCompanyLogin.value) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100)
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.business, color: Colors.blue.shade700, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Company Access: No payment required",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              // Some trees are unpaid - show payment info and buttons
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade100)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Payment Required",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            Text(
                              "₹${_calculatedAmount.toStringAsFixed(2)} ($_selectedUnpaidTreeCount unpaid trees)",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: _isProcessingPayment ? null : _handlePay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isProcessingPayment
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                "Pay Now",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      "After payment, you'll be able to view and download the selected trees.",
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ],
          
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
