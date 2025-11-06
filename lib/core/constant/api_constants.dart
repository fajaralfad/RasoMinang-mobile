import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  
  static String get baseUrl => dotenv.get('API_BASE_URL', fallback: '');
  static String get predictEndpoint => dotenv.get('API_PREDICT_ENDPOINT', fallback: '/predict');
  static String get apiKeyHeader => dotenv.get('API_KEY_HEADER', fallback: 'x-api-key');
  static String get apiKey => dotenv.get('API_KEY', fallback: '');
  
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static bool get isConfigured {
    return baseUrl.isNotEmpty && apiKey.isNotEmpty;
  }
  
  static void printConfig() {
    print('API Base URL: $baseUrl');
    print('API Predict Endpoint: $predictEndpoint');
    print('API Key Header: $apiKeyHeader');
    print('API Key: ${apiKey.isNotEmpty ? "***configured***" : "NOT SET"}');
  }
}