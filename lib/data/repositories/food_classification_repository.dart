import 'dart:convert';
import 'package:klasifikasi_makanan_minang/core/utils/image_utils.dart';
import 'package:klasifikasi_makanan_minang/data/datasources/food_classification_remote_data_source.dart';
import '../models/prediction_request.dart';
import '../models/prediction_response.dart';
import 'package:klasifikasi_makanan_minang/domain/entities/prediction_entity.dart';
import 'package:klasifikasi_makanan_minang/domain/repositories/i_food_classification_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodClassificationRepository implements IFoodClassificationRepository {
  final FoodClassificationRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  FoodClassificationRepository({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  Future<void> clearPredictionHistory() async {
    await sharedPreferences.remove('prediction_history');
  }

  @override
  Future<PredictionResponse> classifyFood(String imagePath) async {
    try {
      // Compress image
      final compressedImage = await ImageUtils.compressImage(imagePath);
      final fileName = ImageUtils.getFileNameFromPath(imagePath);

      // Create request dengan File, bukan base64
      final request = PredictionRequest(
        imageFile: compressedImage,
        fileName: fileName,
      );

      return await remoteDataSource.classifyFood(request);
    } catch (e) {
      return PredictionResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  @override
  Future<List<PredictionEntity>> getPredictionHistory() async {
    final historyJson = sharedPreferences.getStringList('prediction_history') ?? [];
    return historyJson.map((json) {
      final map = jsonDecode(json);
      return PredictionEntity.fromJson(map);
    }).toList();
  }

  @override
  Future<void> savePredictionToHistory(PredictionEntity prediction) async {
    final history = await getPredictionHistory();
    history.insert(0, prediction);
    
    // Keep only last 50 predictions
    final limitedHistory = history.take(50).toList();
    
    final historyJson = limitedHistory.map((pred) => jsonEncode(pred.toJson())).toList();
    await sharedPreferences.setStringList('prediction_history', historyJson);
  }
}