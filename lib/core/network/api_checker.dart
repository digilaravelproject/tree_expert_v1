import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../constent/app_constants.dart';
import '../storage/shared_prefs.dart';
import '../storage/token_manger.dart';
import '../utils/custom_snackbar.dart';
import '../utils/logger.dart';
import 'error_handler.dart';

class ApiChecker {
  // Navigation key for logout navigation (set this in main.dart)
  static GlobalKey<NavigatorState>? navigatorKey;

  static Response checkResponse(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return response;
      case 401:
        _showErrorMessage(response, 'Unauthorized access. Please login_mobile again.');
        _logout();
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Unauthorized',
        );
      case 403:
        _showErrorMessage(response, 'Access forbidden');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Forbidden',
        );
      case 404:
        _showErrorMessage(response, 'Resource not found');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Not Found',
        );
      case 408:
        _showErrorMessage(response, 'Request timeout. Please try again.');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request Timeout',
        );
      case 422:
        _showValidationErrors(response);
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Validation Error',
        );
      case 429:
        _showErrorMessage(response, 'Too many requests. Please wait and try again.');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Too Many Requests',
        );
      case 500:
        _showErrorMessage(response, 'Server error. Please try again later.');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Server Error',
        );
      case 502:
        _showErrorMessage(response, 'Bad gateway. Server is temporarily unavailable.');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Bad Gateway',
        );
      case 503:
        _showErrorMessage(response, 'Service temporarily unavailable. Please try again.');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Service Unavailable',
        );
      default:
        _showErrorMessage(response, 'Something went wrong');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Something went wrong',
        );
    }
  }

  static Response handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          CustomSnackbar.showError(
            message: 'Connection timeout. Please check your internet and try again.',
          );
          break;
        case DioExceptionType.sendTimeout:
          CustomSnackbar.showError(message: 'Request timeout. Please try again.');
          break;
        case DioExceptionType.receiveTimeout:
          CustomSnackbar.showError(
            message: 'Server is taking too long to respond. Please try again.',
          );
          break;
        case DioExceptionType.badCertificate:
          CustomSnackbar.showError(
            message: 'Security certificate error. Please contact support.',
          );
          break;
        case DioExceptionType.badResponse:
          if (error.response != null) {
            // Handle specific status codes
            final statusCode = error.response!.statusCode;
            if (statusCode == 401) {
              _logout();
              return Response(
                requestOptions: error.requestOptions,
                statusCode: statusCode,
                data: error.response!.data,
              );
            }

            try {
              ErrorResponse errorResponse = ErrorResponse.fromJson(error.response!.data);
              if (errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
                CustomSnackbar.showError(
                  message: errorResponse.errors!.first.message ?? 'Unknown error',
                );
              } else if (error.response?.data['msg'] != null) {
                CustomSnackbar.showError(
                  message: error.response!.data['msg'].toString(),
                );
              } else if (error.response?.data['message'] != null) {
                CustomSnackbar.showError(
                  message: error.response!.data['message'].toString(),
                );
              } else {
                CustomSnackbar.showError(message: 'Something went wrong');
              }
            } catch (e) {
              if (error.response?.data is Map) {
                final data = error.response!.data as Map;
                CustomSnackbar.showError(
                  message: data['msg']?.toString() ??
                      data['message']?.toString() ??
                      'Something went wrong',
                );
              } else {
                CustomSnackbar.showError(message: 'Something went wrong');
              }
            }
          } else {
            CustomSnackbar.showError(message: 'Server error. Please try again.');
          }
          break;
        case DioExceptionType.cancel:
          CustomSnackbar.showError(message: 'Request cancelled');
          break;
        case DioExceptionType.connectionError:
          CustomSnackbar.showError(
            message: 'No internet connection. Please check your network and try again.',
          );
          break;
        case DioExceptionType.unknown:
          if (error.error != null) {
            final errorString = error.error.toString();
            if (errorString.contains('SocketException') ||
                errorString.contains('Failed host lookup')) {
              CustomSnackbar.showError(
                message: 'Network error. Please check your internet connection.',
              );
            } else if (errorString.contains('HttpException')) {
              CustomSnackbar.showError(message: 'Connection failed. Please try again.');
            } else {
              CustomSnackbar.showError(message: 'Something went wrong. Please try again.');
            }
          } else {
            CustomSnackbar.showError(message: 'Something went wrong. Please try again.');
          }
          break;
      }

      Logger.e('DioError Type: ${error.type}');
      Logger.e('DioError Message: ${error.message}');
      Logger.e('DioError: ${error.error}');

      return Response(
        requestOptions: error.requestOptions,
        statusCode: error.response?.statusCode ?? 500,
        data: error.response?.data ?? {
          'res': 'error',
          'msg': _getErrorMessage(error),
        },
      );
    } else {
      Logger.e('Error: $error');
      CustomSnackbar.showError(message: 'Unexpected error occurred. Please try again.');

      return Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 500,
        data: {'res': 'error', 'msg': 'Unexpected error occurred'},
      );
    }
  }

  static String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Request timeout';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.badResponse:
        if (error.response?.data is Map) {
          final data = error.response!.data as Map;
          return data['msg']?.toString() ??
              data['message']?.toString() ??
              'Server error';
        }
        return 'Server error';
      default:
        return 'Something went wrong';
    }
  }

  static void _showErrorMessage(Response response, [String? defaultMessage]) {
    String message = defaultMessage ?? 'Something went wrong';

    if (response.data != null && response.data is Map) {
      final data = response.data as Map;
      message = data['msg']?.toString() ??
          data['message']?.toString() ??
          data['error']?.toString() ??
          message;
    }

    CustomSnackbar.showError(message: message);
  }

  static void _showValidationErrors(Response response) {
    if (response.data != null) {
      try {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response.data);
        if (errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
          String errorMsg = errorResponse.errors!
              .map((e) => e.message ?? '')
              .where((msg) => msg.isNotEmpty)
              .join('\n');
          CustomSnackbar.showError(
            message: errorMsg.isNotEmpty ? errorMsg : 'Validation errors occurred',
          );
        } else {
          CustomSnackbar.showError(message: 'Validation Error');
        }
      } catch (e) {
        if (response.data is Map) {
          final data = response.data as Map;
          String message = data['msg']?.toString() ??
              data['message']?.toString() ??
              'Validation Error';
          CustomSnackbar.showError(message: message);
        } else {
          CustomSnackbar.showError(message: 'Validation Error');
        }
      }
    } else {
      CustomSnackbar.showError(message: 'Validation Error');
    }
  }

  static void _logout() {
    SharedPrefs.remove(AppConstants.userDataPref);
    SharedPrefs.setBool(AppConstants.isLoggedInPref, false);
    TokenManager.clearToken();

    // GetX Navigation - Navigate to sign-in and clear all previous routes
    Get.offAllNamed('/sign-in'); // Replace with your actual sign-in route

    // Alternative: If you want to use the navigator key
    // if (navigatorKey?.currentContext != null) {
    //   navigatorKey!.currentState?.pushNamedAndRemoveUntil(
    //     '/sign-in',
    //     (route) => false,
    //   );
    // }
  }

  static void showResponseError(Response response) {
    if (response.data != null) {
      try {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response.data);
        if (errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
          CustomSnackbar.showError(
            message: errorResponse.errors!.first.message ?? 'An error occurred',
          );
          return;
        }
      } catch (e) {
        // If parsing fails, continue to default error handling
      }

      if (response.data is Map) {
        final data = response.data as Map;
        CustomSnackbar.showError(
          message: data['msg']?.toString() ??
              data['message']?.toString() ??
              data['error']?.toString() ??
              'Something went wrong',
        );
      } else {
        CustomSnackbar.showError(message: 'Something went wrong');
      }
    } else {
      CustomSnackbar.showError(message: 'Something went wrong');
    }
  }

  @Deprecated('Use showResponseError instead')
  static void checkApi(Response response, {bool showToaster = false}) {
    if (showToaster && response.statusCode != 200 && response.statusCode != 201) {
      showResponseError(response);
    }
  }
}