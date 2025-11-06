import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/classification_provider.dart';
import '../widgets/prediction_result_card.dart';
import '../widgets/image_picker_bottom_sheet.dart';
import '../widgets/loading_overlay.dart';
import '../screens/history_screen.dart';
import '../widgets/custom_app_bar.dart';
import 'camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassificationProvider>().loadPredictionHistory();
    });
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ImagePickerBottomSheet(
        onImageSelected: _classifyImage,
        onCameraSelected: _openCamera,
      ),
    );
  }

  void _classifyImage(String imagePath) {
    context.read<ClassificationProvider>().classifyImage(imagePath);
  }

  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          onImageCaptured: _classifyImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Minang Food Classifier',
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
            tooltip: 'Riwayat Prediksi',
          ),
        ],
      ),
      body: Consumer<ClassificationProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 32),
                    _buildActionSection(context, provider),
                    const SizedBox(height: 32),
                    _buildResultSection(provider),
                  ],
                ),
              ),
              if (provider.isLoading) const LoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.2),
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: ClipOval(
              child: Image.asset(
                'assets/images/icon-minang.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.restaurant,
                    size: 60,
                    color: Theme.of(context).primaryColor,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Klasifikasi Makanan Minangkabau',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Unggah foto makanan untuk mengidentifikasi jenis makanan Minangkabau tradisional',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context, ClassificationProvider provider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.photo_camera,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih Gambar Makanan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Gunakan kamera atau pilih dari galeri',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showImagePicker,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Pilih Gambar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(ClassificationProvider provider) {
    if (provider.error != null) {
      return Card(
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _showImagePicker,
                  child: const Text('Coba Lagi'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.lastPrediction?.data != null) {
      return PredictionResultCard(
        predictionData: provider.lastPrediction!.data!,
        onRetry: _showImagePicker,
      );
    }

    return const SizedBox.shrink();
  }
}