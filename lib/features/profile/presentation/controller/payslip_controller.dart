import 'package:get/get.dart';
import '../../../../core/constent/app_constants.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../../data/model/payslip_model.dart';
import '../../data/repository/profile_repository.dart';

class PayslipController extends GetxController {
  final ProfileRepository _profileRepository = ProfileRepository();

  // Observable Data
  final RxList<PayslipModel> payslips = <PayslipModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt totalCount = 0.obs;
  final RxDouble totalAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPayslips();
  }

  /// Fetch User Payslips
  Future<void> fetchPayslips() async {
    int? userId = SharedPrefs.getInt(AppConstants.userIdPref);
    if (userId == null) {
      Get.snackbar("Error", "User ID not found");
      return;
    }

    isLoading.value = true;
    
    try {
      final response = await _profileRepository.getUserSubscriptions(userId);
      
      if (response.success && response.data != null) {
        payslips.assignAll(response.data!.data);
        totalCount.value = response.data!.count;
        
        // Calculate total amount
        double total = 0.0;
        for (var payslip in payslips) {
          total += double.tryParse(payslip.amount) ?? 0.0;
        }
        totalAmount.value = total;
        
        print("Payslips fetched: ${payslips.length}");
      } else {
        Get.snackbar("Error", response.message ?? "Failed to fetch payslips");
      }
    } catch (e) {
      print("Error fetching payslips: $e");
      Get.snackbar("Error", "Failed to fetch payslips: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh Payslips
  Future<void> refreshPayslips() async {
    await fetchPayslips();
  }

  /// Get formatted date
  String getFormattedDate(String dateString) {
    try {
      // Handle the new date format: "2026-02-05 11:06"
      if (dateString.contains(' ')) {
        List<String> parts = dateString.split(' ');
        String datePart = parts[0];
        String timePart = parts.length > 1 ? parts[1] : '';
        
        List<String> dateParts = datePart.split('-');
        if (dateParts.length == 3) {
          String day = dateParts[2];
          String month = dateParts[1];
          String year = dateParts[0];
          
          if (timePart.isNotEmpty) {
            return "$day/$month/$year at $timePart";
          } else {
            return "$day/$month/$year";
          }
        }
      }
      
      // Fallback to original parsing
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  /// Get formatted amount
  String getFormattedAmount(String amount) {
    try {
      double value = double.parse(amount);
      return "₹${value.toStringAsFixed(2)}";
    } catch (e) {
      return "₹$amount";
    }
  }
}