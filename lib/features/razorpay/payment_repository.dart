import 'package:get/get.dart';
import '../../core/constent/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';

class PaymentRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();


  /// Create payment order
  /// Returns order_id, key, key_secret from API
  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required int userId,
    required int amount,
    required List<int> treeIds,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.createPaymentOrder,
        data: {
          'user_id': userId,
          'amount': amount,
          'tree_ids': treeIds,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        if (data['success'] == true) {
          return ApiResponse.success(
            {
              'order_id': data['order_id'],
              'key': data['key'],
              'key_secret': data['key_secret'],
              'amount': data['amount'],
              'tree_ids': data['tree_ids'],
            },
            message: data['message'] ?? 'Order created successfully',
            code: response.statusCode,
          );
        } else {
          return ApiResponse.error(
            data['message'] ?? 'Failed to create order',
            code: response.statusCode,
          );
        }
      } else {
        return ApiResponse.error(
          'Failed to create order',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error creating order: $e',
        error: e,
      );
    }
  }



  /// Verify Razorpay payment
  Future<ApiResponse<Map<String, dynamic>>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int userId,
    required int amount,
    required List<int> treeIds,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.paymentVerify,
        data: {
          "razorpay_order_id": razorpayOrderId,
          "razorpay_payment_id": razorpayPaymentId,
          "razorpay_signature": razorpaySignature,
          "user_id": userId,
          "amount": amount,
          "tree_ids": treeIds,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data['success'] == true) {
          return ApiResponse.success(
            data,
            message: data['message'] ?? 'Payment verified successfully',
            code: response.statusCode,
          );
        } else {
          return ApiResponse.error(
            data['message'] ?? 'Payment verification failed',
            code: response.statusCode,
          );
        }
      } else {
        return ApiResponse.error(
          'Payment verification failed',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error verifying payment: $e',
        error: e,
      );
    }
  }

  /// Get project export links
  /// Returns download links and payment info if required
  Future<ApiResponse<Map<String, dynamic>>> getProjectExportLinks({
    required int userId,
    required int projectId,
    required List<int> treeIds,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.getProjectExportLinks,
        data: {
          'user_id': userId,
          'project_id': projectId,
          'tree_ids': treeIds,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        if (data['success'] == true) {
          return ApiResponse.success(
            data,
            message: data['message'] ?? 'Export links retrieved successfully',
            code: response.statusCode,
          );
        } else {
          return ApiResponse.error(
            data['message'] ?? 'Failed to get export links',
            code: response.statusCode,
          );
        }
      } else {
        return ApiResponse.error(
          'Failed to get export links',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error getting export links: $e',
        error: e,
      );
    }
  }

}
