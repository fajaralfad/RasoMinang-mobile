import 'package:klasifikasi_makanan_minang/core/network/api_client.dart';
import 'package:klasifikasi_makanan_minang/core/network/network_exceptions.dart';
import 'package:klasifikasi_makanan_minang/core/constant/api_constants.dart';
import '../models/prediction_request.dart';
import '../models/prediction_response.dart';

abstract class FoodClassificationRemoteDataSource {
  Future<PredictionResponse> classifyFood(PredictionRequest request);
}

class FoodClassificationRemoteDataSourceImpl
    implements FoodClassificationRemoteDataSource {
  final ApiClient apiClient;

  FoodClassificationRemoteDataSourceImpl({required this.apiClient});

   @override
  Future<PredictionResponse> classifyFood(PredictionRequest request) async {
    try {
      final formData = await request.toFormData();
      
      final response = await apiClient.postMultipart(
        ApiConstants.predictEndpoint,
        data: formData,
      );
      
      return PredictionResponse.fromJson(response);
    } on NetworkExceptions catch (e) {
      return PredictionResponse(
        success: false,
        error: e.toString(),
      );
    }
  }
}

