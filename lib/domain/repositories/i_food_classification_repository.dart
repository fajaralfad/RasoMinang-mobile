import 'package:klasifikasi_makanan_minang/data/models/prediction_response.dart';
import '../entities/prediction_entity.dart';

abstract class IFoodClassificationRepository {
  Future<PredictionResponse> classifyFood(String imagePath);
  Future<List<PredictionEntity>> getPredictionHistory();
  Future<void> savePredictionToHistory(PredictionEntity prediction);
  Future<void> clearPredictionHistory();
}