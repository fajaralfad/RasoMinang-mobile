import 'package:flutter/foundation.dart';
import 'package:klasifikasi_makanan_minang/data/models/prediction_response.dart';
import 'package:klasifikasi_makanan_minang/domain/entities/prediction_entity.dart';
import 'package:klasifikasi_makanan_minang/domain/usecases/classify_food_usecase.dart';
import 'package:klasifikasi_makanan_minang/domain/repositories/i_food_classification_repository.dart';

class ClassificationProvider with ChangeNotifier {
  final ClassifyFoodUseCase classifyFoodUseCase;
  final IFoodClassificationRepository repository;

  ClassificationProvider({
    required this.classifyFoodUseCase,
    required this.repository,
  });

  bool _isLoading = false;
  PredictionResponse? _lastPrediction;
  String? _error;
  List<PredictionEntity> _predictionHistory = [];

  bool get isLoading => _isLoading;
  PredictionResponse? get lastPrediction => _lastPrediction;
  String? get error => _error;
  List<PredictionEntity> get predictionHistory => _predictionHistory;

  Future<void> classifyImage(String imagePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await classifyFoodUseCase.execute(imagePath);
      
      if (response.success && response.data != null) {
        _lastPrediction = response;
        
        // Save to history
        final prediction = PredictionEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          predictedClass: response.data!.predictedClass,
          confidence: response.data!.confidenceValue,
          imagePath: imagePath,
          timestamp: DateTime.now(),
          probabilities: response.data!.probabilities,
        );
        
        await repository.savePredictionToHistory(prediction);
        await loadPredictionHistory();
      } else {
        _error = response.error ?? 'Classification failed';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPredictionHistory() async {
    _predictionHistory = await repository.getPredictionHistory();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearLastPrediction() {
    _lastPrediction = null;
    notifyListeners();
  }

  Future<void> clearPredictionHistory() async {
  await repository.clearPredictionHistory();
  _predictionHistory.clear();
  notifyListeners();
}
}