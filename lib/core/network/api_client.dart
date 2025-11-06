import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constant/api_constants.dart';
import 'api_interceptor.dart';
import 'network_exceptions.dart';

class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          ApiConstants.apiKeyHeader: ApiConstants.apiKey,
        },
      ),
    );
    
    _dio.interceptors.add(ApiInterceptor());
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      
      _logger.i('API Response: ${response.data}');
      return response.data;
    } on DioException catch (dioError) {
      _logger.e('Dio Error: ${dioError.message}');
      throw NetworkExceptions.getDioException(dioError);
    } catch (e) {
      _logger.e('Unexpected Error: $e');
      throw NetworkExceptions.unexpectedError();
    }
  }

  Future<dynamic> postMultipart(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final fullUrl = '${ApiConstants.baseUrl}$path';
      _logger.i('Making MULTIPART POST request to: $fullUrl');
      _logger.i('Headers: ${_dio.options.headers}');
      _logger.i('FormData fields: ${data.fields}');
      _logger.i('FormData files: ${data.files}');

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'API-KEY': ApiConstants.apiKey,
          },
        ),
      );
      
      _logger.i('API Response Success: ${response.statusCode}');
      return response.data;
    } on DioException catch (dioError) {
      _logger.e('Dio Error Type: ${dioError.type}');
      _logger.e('Dio Error Message: ${dioError.message}');
      _logger.e('Dio Status Code: ${dioError.response?.statusCode}');
      _logger.e('Dio Response Data: ${dioError.response?.data}');
      
      throw NetworkExceptions.getDioException(dioError);
    } catch (e) {
      _logger.e('Unexpected Error: $e');
      throw NetworkExceptions.unexpectedError();
    }
  }
}