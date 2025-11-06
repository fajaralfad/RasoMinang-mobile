class PredictionResponse {
  final bool success;
  final PredictionData? data;
  final String? error;
  final String? filename;

  PredictionResponse({
    required this.success,
    this.data,
    this.error,
    this.filename,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    try {
      // PENTING: API mengirim 'prediction' bukan 'data'
      final predictionJson = json['prediction'] as Map<String, dynamic>?;
      
      return PredictionResponse(
        success: json['success'] ?? false,
        data: predictionJson != null 
            ? PredictionData.fromJson(predictionJson) 
            : null,
        filename: json['filename'] as String?,
        error: json['error'] as String?,
      );
    } catch (e) {
      print('Error parsing PredictionResponse: $e');
      return PredictionResponse(
        success: false,
        error: 'Gagal parsing response: $e',
      );
    }
  }
}

class PredictionData {
  final String predictedClass;
  final double confidence;
  final Map<String, double> probabilities;

  PredictionData({
    required this.predictedClass,
    required this.confidence,
    required this.probabilities,
  });

  factory PredictionData.fromJson(Map<String, dynamic> json) {
    try {
      // Parse all_predictions array menjadi Map
      final Map<String, double> probs = {};
      
      if (json['all_predictions'] != null) {
        final allPredictions = json['all_predictions'] as List;
        for (var item in allPredictions) {
          final className = item['class'] as String;
          final conf = (item['confidence'] as num).toDouble();
          probs[className] = conf;
        }
      }

      return PredictionData(
        predictedClass: json['predicted_class'] ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        probabilities: probs,
      );
    } catch (e) {
      print('Error parsing PredictionData: $e');
      rethrow;
    }
  }

  double get confidenceValue => confidence;

  String get formattedConfidence {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }
}