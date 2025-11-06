import 'package:klasifikasi_makanan_minang/data/models/prediction_response.dart';
import '../repositories/i_food_classification_repository.dart';

class ClassifyFoodUseCase {
  final IFoodClassificationRepository repository;

  ClassifyFoodUseCase({required this.repository});

  Future<PredictionResponse> execute(String imagePath) async {
    return await repository.classifyFood(imagePath);
  }
}