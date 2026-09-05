import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  bool _isCheckingAccess = false;
  String? _error;

  int? _selectedFromCount;
  int? _selectedToCount;
  
  // Export links state
  Map<String, dynamic>? _exportLinksData;
  bool _showDownloadOptions = false;

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
      final userId = SharedPrefs.getInt(AppConstants.userIdPref) ?? 0;
      final response = await _repository.getTreesByProject(
        widget.projectId.toString(),
        userId: userId,
      );
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

  // Get selected trees based on from/to count (Modified: Now always returns all trees)
  List<TreeModel> get _selectedTrees {
    return _allTrees;
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

  // Count of free trees in selection
  int get _selectedFreeTreeCount {
    return _selectedTrees.where((t) => t.isFree ?? false).length;
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

  Future<void> _checkAccessAndGetLinks() async {
    if (_selectedTreeIds.isEmpty) {
      Get.snackbar("Error", "No trees selected", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() {
      _isCheckingAccess = true;
      _error = null;
    });

    try {
      final userId = SharedPrefs.getInt(AppConstants.userIdPref) ?? 0;
      
      final response = await _paymentRepository.getProjectExportLinks(
        userId: userId,
        projectId: widget.projectId,
        treeIds: _selectedTreeIds,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final paymentRequired = data['payment_required'];

        if (paymentRequired == null) {
          // No payment required - directly open download options
          final links = data['links'] as Map<String, dynamic>?;
          if (links != null) {
            setState(() {
              _isCheckingAccess = false;
            });
            Get.back();
            Get.bottomSheet(
              DownloadOptionsBottomSheet(
                projectName: widget.projectName,
                projectId: widget.projectId,
                selectedTreeIds: _selectedTreeIds,
                exportLinks: links,
              ),
              isScrollControlled: true,
            );
          } else {
            setState(() {
              _error = "No download links available";
              _isCheckingAccess = false;
            });
          }
        } else {
          // Payment required - show payment UI
          setState(() {
            _exportLinksData = data;
            _isCheckingAccess = false;
          });
        }
      } else {
        setState(() {
          _error = response.message ?? "Failed to check access";
          _isCheckingAccess = false;
        });
        Get.snackbar(
          "Error",
          response.message ?? "Failed to check access",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
        _isCheckingAccess = false;
      });
      Get.snackbar(
        "Error",
        "Failed to check access: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handlePaymentRequired(Map<String, dynamic> paymentRequired) async {
    final treeIds = paymentRequired['tree_ids'] as List?;
    final totalAmount = paymentRequired['total_amount'] as num?;

    if (treeIds == null || totalAmount == null) {
      Get.snackbar("Error", "Invalid payment data", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final userId = SharedPrefs.getInt(AppConstants.userIdPref) ?? 0;
      
      final response = await _paymentRepository.createOrder(
        userId: userId,
        amount: totalAmount.toInt(),
        treeIds: List<int>.from(treeIds),
      );

      if (response.success && response.data != null) {
        final orderId = response.data!['order_id'] as String?;
        final key = response.data!['key'] as String?;
        
        razorpayController.openCheckout(
          amount: totalAmount.toInt(),
          name: 'Tree Expert',
          description: 'Project: ${widget.projectName}',
          mobile: '9651017054',
          email: 'awantikayadav014@gmail.com',
          orderId: orderId,
          key: key,
          treeIds: List<int>.from(treeIds),
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

  void _showDownloadLinks() {
    if (_exportLinksData == null) return;

    final links = _exportLinksData!['links'] as Map<String, dynamic>?;
    if (links == null) return;

    Get.back();
    Get.bottomSheet(
      DownloadOptionsBottomSheet(
        projectName: widget.projectName,
        projectId: widget.projectId,
        selectedTreeIds: _selectedTreeIds,
        exportLinks: links,
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

          // Dropdowns Row (Commented out to remove tree selection)
          /*
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
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      menuMaxHeight: 300,
                      selectedItemBuilder: (context) {
                        return countList.map((count) {
                          final tree = _allTrees[count - 1];
                          return Text(
                            "$count-${tree.treeName}",
                            style: TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          );
                        }).toList();
                      },
                      items: countList.map((count) {
                        final tree = _allTrees[count - 1];
                        final isPaid = tree.payment == 1;
                        final isFree = tree.isFree ?? false;
                        return DropdownMenuItem(
                          value: count, 
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("$count-",style: TextStyle(fontSize: 11),),
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 80),
                                child: Text(
                                  "${tree.treeName}",
                                  style: TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text("(${tree.treeNo})", style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                              SizedBox(width: 4),
                              if (isFree)
                                Icon(CupertinoIcons.checkmark_seal_fill, size: 14, color: Colors.blue)
                              else if (isPaid) 
                                Icon(Icons.check_circle, size: 14, color: Colors.green)
                              else
                                Icon(Icons.radio_button_unchecked, size: 14, color: Colors.orange),
                            ],
                          )
                        );
                      }).toList(),
                      onChanged: (val) {
                         if (val != null) {
                           setState(() {
                             _selectedFromCount = val;
                             _exportLinksData = null; // Reset previous access check
                             
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
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      menuMaxHeight: 300,
                      selectedItemBuilder: (context) {
                        final toItems = _selectedFromCount == null 
                          ? countList 
                          : countList.where((count) => count >= _selectedFromCount!).toList();
                          
                        return toItems.map((count) {
                          final tree = _allTrees[count - 1];
                          return Text(
                            "$count-${tree.treeName}",
                            style: TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          );
                        }).toList();
                      },
                      items: _selectedFromCount == null 
                        ? [] 
                        : countList.where((count) => count >= _selectedFromCount!).map((count) {
                            final tree = _allTrees[count - 1];
                            final isPaid = tree.payment == 1;
                            final isFree = tree.isFree ?? false;
                            return DropdownMenuItem(
                              value: count, 
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("$count-",style: TextStyle(fontSize: 11),),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 80),
                                    child: Text(
                                      "${tree.treeName}",
                                      style: TextStyle(fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text("(${tree.treeNo})", style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                                  SizedBox(width: 4),
                                  if (isFree)
                                    Icon(CupertinoIcons.checkmark_seal_fill, size: 14, color: Colors.blue)
                                  else if (isPaid) 
                                    Icon(Icons.check_circle, size: 14, color: Colors.green)
                                  else
                                    Icon(Icons.radio_button_unchecked, size: 14, color: Colors.orange),
                                ],
                              )
                            );
                          }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedToCount = val;
                            _exportLinksData = null; // Reset previous access check
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          */

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
                    "Selected: ${_selectedTrees.length} trees | Paid: ${_selectedTrees.length - _selectedUnpaidTreeCount} | Unpaid: $_selectedUnpaidTreeCount | Free: $_selectedFreeTreeCount",
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],

          // Action Buttons
          if (_selectedFromCount != null && _selectedToCount != null) ...[
            if (_exportLinksData != null && _exportLinksData!['payment_required'] != null) ...[
              // Show payment required UI
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
                              "₹${(_exportLinksData!['payment_required']['total_amount'] as num).toStringAsFixed(2)} (${(_exportLinksData!['payment_required']['tree_ids'] as List).length} trees)",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: _isProcessingPayment ? null : () => _handlePaymentRequired(_exportLinksData!['payment_required']),
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
            ] else ...[
              // Initial download button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isCheckingAccess ? null : _checkAccessAndGetLinks,
                  icon: _isCheckingAccess 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.download),
                  label: Text(_isCheckingAccess ? "Checking Access..." : "Download"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
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
