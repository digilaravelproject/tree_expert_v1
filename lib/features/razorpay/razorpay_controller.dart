/*
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class RazorpayController extends GetxController {
  late Razorpay _razorpay;

  @override
  void onInit() {
    super.onInit();

    _razorpay = Razorpay();

    // Payment success
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );

    // Payment error
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );

    // External wallet
    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );
  }

  /// 🔹 Open Razorpay
  void openCheckout({
    required int amount, // amount in RUPEES
    required String name,
    required String description,
    required String mobile,
    required String email,
    String? orderId, // Order ID from create-order API
    String? key, // Key from create-order API
  }) {
    var options = {
      'key': key ?? 'rzp_test_S9yXFuXcf0S6Ll', // Use API key if provided
      'amount': amount * 100, // ⚠️ amount paisa me hota hai
      'name': name,
      'description': description,
      'prefill': {
        'contact': mobile,
        'email': email,
      },
      'theme': {
        'color': '#2E7D32',
      }
    };

    // Add order_id if provided
    if (orderId != null) {
      options['order_id'] = orderId;
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  /// ✅ SUCCESS
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Get.snackbar(
      'Payment Success',
      'Payment ID: ${response.paymentId}',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    print("response paymentId : "+response.paymentId.toString()+"response signature : "+response.signature.toString());

    // 🔔 Yaha backend ko payment_id bhejna hota hai
  }

  /// ❌ FAILURE
  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      'Payment Failed',
      response.message ?? 'Payment cancelled',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  /// 💳 WALLET
  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      'Wallet Selected',
      response.walletName ?? '',
    );
  }

  @override
  void onClose() {
    _razorpay.clear(); // memory leak avoid
    super.onClose();
  }
}

*/




import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tree_expert/features/razorpay/payment_repository.dart';
import '../../widgets/payment_success_dialog.dart';

class RazorpayController extends GetxController {
  late Razorpay _razorpay;
  final PaymentRepository _paymentRepository = Get.find<PaymentRepository>();


  @override
  void onInit() {
    super.onInit();

    _razorpay = Razorpay();

    // Payment success
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );

    // Payment error
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );

    // External wallet
    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );
  }

  /// 🔹 Open Razorpay
  void openCheckout({
    required int amount,
    required String name,
    required String description,
    required String mobile,
    required String email,
    String? orderId,
    String? key,
    required List<int> treeIds, // tree_ids for verification
    required int userId,
  }) {
    var options = {
      'key': key ?? 'rzp_test_S9yXFuXcf0S6Ll', // Use key from create-order API
      'amount': amount * 100,
      'name': name,
      'description': description,
      'prefill': {
        'contact': mobile,
        'email': email,
      },
      'theme': {
        'color': '#2E7D32',
      }
    };

    if (orderId != null) {
      options['order_id'] = orderId;
    }

    // Store these for verification after success
    _pendingVerification = {
      'user_id': userId,
      'tree_ids': treeIds,
      'amount': amount,
      'order_id': orderId,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  Map<String, dynamic>? _pendingVerification;

  /// ✅ SUCCESS
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("_handlePaymentSuccess: ${response.paymentId}, Signature: ${response.signature}");

    if (_pendingVerification != null) {

      final orderId = _pendingVerification!['order_id'];

      if (orderId == null) {
        print("⚠️ Order ID is null – skipping verification");
        return;
      }
      // await _verifyPayment(
      //   razorpayOrderId: orderId,
      //   razorpayPaymentId: response.paymentId ?? '',
      //   razorpaySignature: response.signature ?? '',
      //   userId: _pendingVerification!['user_id'],
      //   amount: _pendingVerification!['amount'],
      //   treeIds: List<int>.from(_pendingVerification!['tree_ids']),
      // );


      final res = await _paymentRepository.verifyPayment(
        razorpayOrderId: orderId,
        razorpayPaymentId: response.paymentId ?? "",
        razorpaySignature: response.signature ?? '',
        userId: _pendingVerification!['user_id'],
        amount: _pendingVerification!['amount'],
        treeIds: List<int>.from(_pendingVerification!['tree_ids']),
      );

      if (res.success) {
        // Show success dialog instead of snackbar
        print("response for verify : "+response.toString());
        
        PaymentSuccessDialog.show(
          amount: _pendingVerification!['amount'].toString(),
          paymentId: response.paymentId ?? '',
          treeCount: List<int>.from(_pendingVerification!['tree_ids']).length,
          onOkPressed: () {
            // Optional: Navigate back or refresh data
            print("Payment success dialog OK pressed");
          },
        );
      } else {
        // error toast
        Get.snackbar(
          'Verification Failed',
          res.message ?? 'Payment verification failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }


      _pendingVerification = null; // clear after verification
    }
  }

  /// ❌ FAILURE
  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      'Payment Failed',
      response.message ?? 'Payment cancelled',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );

    print("_handlePaymentError : "+response.message.toString());
  }

  /// 💳 WALLET
  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      'Wallet Selected',
      response.walletName ?? '',
    );
    print("_handleExternalWallet : "+response.walletName.toString());

  }

  /// 🔔 Payment Verification API call
  /*Future<void> _verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int userId,
    required int amount,
    required List<int> treeIds,
  }) async {
    final url = Uri.parse(
        'https://darkorange-baboon-922736.hostingersite.com/public/api/payment/verify');

    final body = {
      "razorpay_order_id": razorpayOrderId,
      "razorpay_payment_id": razorpayPaymentId,
      "razorpay_signature": razorpaySignature,
      "user_id": userId.toString(),
      "amount": amount.toString(),
      "tree_ids": treeIds,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      print("response for verify : "+response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        print("response for verify : "+response.body);
        Get.snackbar(
          'Payment Verified',
          'Your payment has been successfully verified.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Verification Failed',
          data['message'] ?? 'Payment verification failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to verify payment: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }*/

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}

