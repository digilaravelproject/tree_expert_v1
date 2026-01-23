import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import '../constent/app_constants.dart';
import '../storage/shared_prefs.dart';
import '../storage/token_manger.dart';
import '../utils/logger.dart';
import 'api_checker.dart';
import '../constent/api_constants.dart';
import 'multipart.dart';
import 'retry_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
      contentType: 'application/json',
      validateStatus: (status) => status != null && status < 600, // Accept all responses
    );

    // Add logging interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await TokenManager.getToken();
        String? language = SharedPrefs.getString(AppConstants.languagePref);

        print("DEBUG_TOKEN: Retrieved token = '${token ?? 'NULL/EMPTY'}'");

        if (token != null && token.isNotEmpty) {
          options.headers["Authorization"] = "Bearer $token";
          print("DEBUG_TOKEN: Authorization header ADDED");
        } else {
          print("DEBUG_TOKEN: NO TOKEN - Skipping Authorization header");
        }
        
        // Add Default API Key
        options.headers[ApiConstants.xApiKey] = ApiConstants.xApiValue;

        if (language != null && language.isNotEmpty) {
          options.headers["language"] = language;
        }
        options.headers["Content-Type"] = "application/json";

        // Logging Request
        print("DEBUG_HEADERS: ${options.headers}"); // FORCE PRINT
        Logger.d('┌─────────────── REQUEST ───────────────');
        Logger.d('│ Method  : ${options.method}');
        Logger.d('│ URL     : ${options.baseUrl}${options.path}');
        Logger.d('│ Headers : ${options.headers}');
        if (options.queryParameters.isNotEmpty) {
          Logger.d('│ Query   : ${options.queryParameters}');
        }
        if (options.data != null) Logger.d('│ Body    : ${options.data}');
        Logger.d('└───────────────────────────────────────');

        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Logging Response
        Logger.d('┌─────────────── RESPONSE ──────────────');
        Logger.d('│ Method      : ${response.requestOptions.method}');
        Logger.d('│ URL         : ${response.requestOptions.baseUrl}${response.requestOptions.path}');
        Logger.d('│ Status Code : ${response.statusCode}');
        Logger.d('│ Response    : ${response.data}');
        Logger.d('└───────────────────────────────────────');

        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // Logging Error
        Logger.e('┌─────────────── ERROR ─────────────────');
        Logger.e('│ Method   : ${e.requestOptions.method}');
        Logger.e('│ URL      : ${e.requestOptions.baseUrl}${e.requestOptions.path}');
        Logger.e('│ Message  : ${e.message}');
        Logger.e('│ Error    : ${e.error}');
        if (e.response != null) Logger.e('│ Response : ${e.response?.data}');
        Logger.e('└───────────────────────────────────────');

        return handler.next(e);
      },
    ));

    // Add retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: (message) => Logger.w(message),
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );
  }

  // ------------------- GET -------------------
  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
        bool handleError = false,
        bool showToaster = false,
        bool enableRetry = true,
      }) async {
    try {
      // Set retry option
      final requestOptions = options ?? Options();
      if (!enableRetry) {
        requestOptions.disableRetry = true;
      }

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      if (handleError) {
        return ApiChecker.checkResponse(response);
      }

      if (showToaster && response.statusCode != 200 && response.statusCode != 201) {
        ApiChecker.showResponseError(response);
      }

      return response;
    } catch (e) {
      return ApiChecker.handleError(e);
    }
  }

  // ------------------- POST -------------------
  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        bool handleError = false,
        bool showToaster = false,
        bool enableRetry = true,
      }) async {
    try {
      final requestOptions = options ?? Options();
      if (!enableRetry) {
        requestOptions.disableRetry = true;
      }

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (handleError) {
        return ApiChecker.checkResponse(response);
      }

      if (showToaster && response.statusCode != 200 && response.statusCode != 201) {
        ApiChecker.showResponseError(response);
      }

      return response;
    } catch (e) {
      return ApiChecker.handleError(e);
    }
  }

  // ------------------- PUT -------------------
  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        bool handleError = false,
        bool showToaster = false,
        bool enableRetry = true,
      }) async {
    try {
      final requestOptions = options ?? Options();
      if (!enableRetry) {
        requestOptions.disableRetry = true;
      }

      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (handleError) {
        return ApiChecker.checkResponse(response);
      }

      if (showToaster && response.statusCode != 200 && response.statusCode != 201) {
        ApiChecker.showResponseError(response);
      }

      return response;
    } catch (e) {
      return ApiChecker.handleError(e);
    }
  }

  // ------------------- DELETE -------------------
  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        bool handleError = false,
        bool showToaster = false,
        bool enableRetry = true,
      }) async {
    try {
      final requestOptions = options ?? Options();
      if (!enableRetry) {
        requestOptions.disableRetry = true;
      }

      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );

      if (handleError) {
        return ApiChecker.checkResponse(response);
      }

      if (showToaster && response.statusCode != 200 && response.statusCode != 201) {
        ApiChecker.showResponseError(response);
      }

      return response;
    } catch (e) {
      return ApiChecker.handleError(e);
    }
  }

  // ------------------- POST MULTIPART -------------------
  Future<Response> postMultipartData(
      String path,
      Map<String, String> body,
      List<MultipartBody> multipartBody,
      List<MultipartDocument> otherFile, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        bool fromChat = false,
        bool handleError = false,
        bool showToaster = false,
        bool enableRetry = true,
      }) async {
    try {
      FormData formData = FormData();

      // Add text fields
      body.forEach((key, value) {
        formData.fields.add(MapEntry(key, value));
      });

      // Add images
      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          if (kIsWeb) {
            List<int> bytes = await multipart.file!.readAsBytes();
            formData.files.add(MapEntry(
              multipart.key,
              MultipartFile.fromBytes(
                bytes,
                filename: basename(multipart.file!.path),
                contentType: MediaType('image', 'jpg'),
              ),
            ));
          } else {
            File file = File(multipart.file!.path);
            formData.files.add(MapEntry(
              multipart.key,
              await MultipartFile.fromFile(
                file.path,
                filename: basename(file.path),
              ),
            ));
          }
        }
      }

      // Add documents
      for (MultipartDocument file in otherFile) {
        if (kIsWeb) {
          if (fromChat) {
            PlatformFile platformFile = file.file!.files.first;
            formData.files.add(MapEntry(
              'image[]',
              MultipartFile.fromBytes(
                platformFile.bytes!,
                filename: platformFile.name,
              ),
            ));
          } else {
            var fileBytes = file.file!.files.first.bytes!;
            formData.files.add(MapEntry(
              file.key,
              MultipartFile.fromBytes(
                fileBytes,
                filename: file.file!.files.first.name,
              ),
            ));
          }
        } else {
          File other = File(file.file!.files.single.path!);
          formData.files.add(MapEntry(
            file.key,
            await MultipartFile.fromFile(
              other.path,
              filename: basename(other.path),
            ),
          ));
        }
      }

      final requestOptions = options ?? Options();
      if (!enableRetry) {
        requestOptions.disableRetry = true;
      }

      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (handleError) {
        return ApiChecker.checkResponse(response);
      }

      if (showToaster && response.statusCode != 200 && response.statusCode != 201) {
        ApiChecker.showResponseError(response);
      }

      return response;
    } catch (e) {
      return ApiChecker.handleError(e);
    }
  }
}