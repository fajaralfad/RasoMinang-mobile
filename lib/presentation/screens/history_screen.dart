// screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/classification_provider.dart';
import '../../presentation/widgets/history/history_item_widget.dart';
import '../../presentation/widgets/history/empty_history_widget.dart';
import '../../presentation/widgets/history/confirm_dialog.dart';
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

  Future<void> _loadHistory() async {
    print('Loading history...');
    await Provider.of<ClassificationProvider>(context, listen: false)
        .loadPredictionHistory();
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Hapus Riwayat',
        message: 'Apakah Anda yakin ingin menghapus semua riwayat prediksi? Tindakan ini tidak dapat dibatalkan.',
        confirmText: 'Hapus Semua',
        cancelText: 'Batal',
        onConfirm: _clearHistory,
        confirmColor: Colors.red,
      ),
    );
  }

  Future<void> _clearHistory() async {
    await Provider.of<ClassificationProvider>(context, listen: false)
        .clearPredictionHistory();
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Riwayat berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleRefresh() async {
    await Provider.of<ClassificationProvider>(context, listen: false)
        .loadPredictionHistory();
  }

  void _handleStartClassification() {
    Navigator.pop(context);
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
            onPressed: _showClearHistoryDialog,
            tooltip: 'Hapus Riwayat',
          ),
        ],
      ),
      body: Consumer<ClassificationProvider>(
        builder: (context, provider, child) {
          // Debug information
          print('History Screen - Items: ${provider.predictionHistory.length}');
          print('History Screen - Loading: ${provider.isHistoryLoading}');
          print('History Screen - Error: ${provider.error}');

          if (provider.isHistoryLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat riwayat...'),
                ],
              ),
            );
          }

          if (provider.error != null && provider.predictionHistory.isEmpty) {
            return _buildErrorState(provider.error!);
          }

          if (provider.predictionHistory.isEmpty) {
            return EmptyHistoryWidget(
              onStartClassification: _handleStartClassification,
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: Column(
              children: [
                // Header with count
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Total: ${provider.predictionHistory.length} prediksi',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // History list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.predictionHistory.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final prediction = provider.predictionHistory[index];
                      print('Rendering history item: ${prediction.predictedClass}');
                      return HistoryItemWidget(prediction: prediction);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadHistory,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}