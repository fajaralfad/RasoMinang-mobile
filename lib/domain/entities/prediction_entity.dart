class PredictionEntity {
  final String id;
  final String predictedClass;
  final double confidence;
  final String imagePath;
  final DateTime timestamp;
  final Map<String, double> probabilities;

  PredictionEntity({
    required this.id,
    required this.predictedClass,
    required this.confidence,
    required this.imagePath,
    required this.timestamp,
    required this.probabilities,
  });

  factory PredictionEntity.fromJson(Map<String, dynamic> json) {
    return PredictionEntity(
      id: json['id'],
      predictedClass: json['predictedClass'],
      confidence: json['confidence'].toDouble(),
      imagePath: json['imagePath'],
      timestamp: DateTime.parse(json['timestamp']),
      probabilities: Map<String, double>.from(json['probabilities']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'predictedClass': predictedClass,
      'confidence': confidence,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'probabilities': probabilities,
    };
  }

  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get confidencePercentage {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }
}