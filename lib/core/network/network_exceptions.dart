import 'package:dio/dio.dart';

class NetworkExceptions implements Exception {
  final String message;

  const NetworkExceptions(this.message);

  factory NetworkExceptions.getDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkExceptions('Connection timeout');
      case DioExceptionType.sendTimeout:
        return NetworkExceptions('Send timeout');
      case DioExceptionType.receiveTimeout:
        return NetworkExceptions('Receive timeout');
      case DioExceptionType.badCertificate:
        return NetworkExceptions('Bad certificate');
      case DioExceptionType.badResponse:
        return NetworkExceptions.handleResponse(
          error.response!.statusCode!,
          error.response!.data,
        );
      case DioExceptionType.cancel:
        return NetworkExceptions('Request cancelled');
      case DioExceptionType.connectionError:
        return NetworkExceptions('Connection error');
      case DioExceptionType.unknown:
        return NetworkExceptions('Unknown error occurred');
    }
  }

  factory NetworkExceptions.handleResponse(int statusCode, dynamic response) {
    switch (statusCode) {
      case 400:
        return NetworkExceptions('Bad request');
      case 401:
        return NetworkExceptions('Unauthorized');
      case 403:
        return NetworkExceptions('Forbidden');
      case 404:
        return NetworkExceptions('Not found');
      case 409:
        return NetworkExceptions('Conflict');
      case 408:
        return NetworkExceptions('Request timeout');
      case 422:
        return NetworkExceptions(
          'Data yang dikirim tidak sesuai format yang diharapkan server.',
        );
      case 500:
        return NetworkExceptions('Internal server error');
      case 503:
        return NetworkExceptions('Service unavailable');
      default:
        return NetworkExceptions('Received invalid status code: $statusCode');
    }
  }

  factory NetworkExceptions.unexpectedError() {
    return NetworkExceptions('Unexpected error occurred');
  }

  @override
  String toString() => message;
}
