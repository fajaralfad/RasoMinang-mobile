import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io'; 
import 'package:klasifikasi_makanan_minang/core/constant/app_constants.dart';
import 'package:klasifikasi_makanan_minang/domain/entities/prediction_entity.dart';
import '../providers/classification_provider.dart';
import '../widgets/custom_app_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    await Provider.of<ClassificationProvider>(context, listen: false)
        .loadPredictionHistory();
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text('Apakah Anda yakin ingin menghapus semua riwayat prediksi? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<ClassificationProvider>(context, listen: false)
                  .clearPredictionHistory();
            },
            child: const Text(
              'Hapus Semua',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Riwayat Prediksi',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearHistory,
            tooltip: 'Hapus Riwayat',
          ),
        ],
      ),
      body: Consumer<ClassificationProvider>(
        builder: (context, provider, child) {
          if (provider.predictionHistory.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadPredictionHistory(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.predictionHistory.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final prediction = provider.predictionHistory[index];
                return _buildHistoryItem(prediction, context);
              },
            ),
          );
        },
      ),
    );
  }

  // ... (method _buildEmptyState, _buildHistoryItem, _getConfidenceColor, _formatDate tetap sama)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Riwayat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hasil prediksi akan muncul di sini',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Mulai Klasifikasi'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(PredictionEntity prediction, BuildContext context) {
    final foodName = AppConstants.foodLabels[prediction.predictedClass] ?? 
        prediction.predictedClass;
    final description = AppConstants.foodDescriptions[prediction.predictedClass] ?? 
        '';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(prediction.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.fastfood,
                        color: Colors.grey[500],
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Informasi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Confidence dan Tanggal
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(prediction.confidence)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _getConfidenceColor(prediction.confidence)
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          prediction.confidencePercentage,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getConfidenceColor(prediction.confidence),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(prediction.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return Colors.green;
    if (confidence > 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}