// providers/classification_provider.dart
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
  bool _isHistoryLoading = false;

  bool get isLoading => _isLoading;
  bool get isHistoryLoading => _isHistoryLoading;
  PredictionResponse? get lastPrediction => _lastPrediction;
  String? get error => _error;
  List<PredictionEntity> get predictionHistory => _predictionHistory;

  Future<void> classifyImage(String imagePath) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await classifyFoodUseCase.execute(imagePath);
      
      if (response.success && response.data != null) {
        _lastPrediction = response;
        
        final prediction = PredictionEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          predictedClass: response.data!.predictedClass,
          confidence: response.data!.confidenceValue,
          imagePath: imagePath,
          timestamp: DateTime.now(),
          probabilities: response.data!.probabilities,
        );
        
        await repository.savePredictionToHistory(prediction);
        await _loadPredictionHistoryImmediate();
        
        print('Prediction saved to history: ${prediction.predictedClass}');
      } else {
        _error = response.error ?? 'Classification failed';
      }
    } catch (e) {
      _error = 'Error classifying image: $e';
      print('Classification error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPredictionHistory() async {
    if (_isHistoryLoading) return;
    
    _isHistoryLoading = true;
    notifyListeners();

    try {
      _predictionHistory = await repository.getPredictionHistory();
      print('Loaded ${_predictionHistory.length} predictions from history');
    } catch (e) {
      _error = 'Error loading history: $e';
      print('History loading error: $e');
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPredictionHistoryImmediate() async {
    try {
      _predictionHistory = await repository.getPredictionHistory();
      print('Immediate reload: ${_predictionHistory.length} predictions');
    } catch (e) {
      print('Immediate history reload error: $e');
    }
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
    try {
      await repository.clearPredictionHistory();
      _predictionHistory.clear();
      notifyListeners();
      print('Prediction history cleared');
    } catch (e) {
      _error = 'Error clearing history: $e';
      notifyListeners();
    }
  }

  bool isPredictionInHistory(String imagePath) {
    return _predictionHistory.any((prediction) => prediction.imagePath == imagePath);
  }

  PredictionEntity? getPredictionById(String id) {
    try {
      return _predictionHistory.firstWhere((prediction) => prediction.id == id);
    } catch (e) {
      return null;
    }
  }
}