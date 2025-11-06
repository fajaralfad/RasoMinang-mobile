import 'package:flutter/material.dart';
import 'package:klasifikasi_makanan_minang/core/constant/app_constants.dart';
import 'package:klasifikasi_makanan_minang/data/models/prediction_response.dart';

class PredictionResultCard extends StatelessWidget {
  final PredictionData predictionData;
  final VoidCallback? onRetry;

  const PredictionResultCard({
    super.key,
    required this.predictionData,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final foodName = AppConstants.foodLabels[predictionData.predictedClass] ?? 
        predictionData.predictedClass;
    final description = AppConstants.foodDescriptions[predictionData.predictedClass] ?? 
        'Deskripsi tidak tersedia';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hasil Klasifikasi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    foodName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      predictionData.formattedConfidence,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: _getConfidenceColor(
                      predictionData.confidenceValue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildProbabilitiesList(context),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProbabilitiesList(BuildContext context) {
    final sortedProbabilities = predictionData.probabilities.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Probabilitas Lainnya:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...sortedProbabilities.map((entry) {
          final label = AppConstants.foodLabels[entry.key] ?? entry.key;
          final percentage = (entry.value * 100).toStringAsFixed(1);
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return Colors.green;
    if (confidence > 0.6) return Colors.orange;
    return Colors.red;
  }
}