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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      appBar: HomeAppBar( 
        title: 'Minang Food Classifier',
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
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
          ),
        ],
      ),
      body: Consumer<ClassificationProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeaderSection(context, size, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    _buildActionSection(context, provider, size, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    _buildResultSection(provider, isDark),
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

  Widget _buildHeaderSection(BuildContext context, Size size, bool isSmallScreen) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 100 : 140,
          height: isSmallScreen ? 100 : 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      Colors.grey.shade800.withOpacity(0.3),
                      Colors.grey.shade900.withOpacity(0.1),
                    ]
                  : [
                      Theme.of(context).primaryColor.withOpacity(0.2),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? Colors.black.withOpacity(0.5)
                    : Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: ClipOval(
              child: Image.asset(
                'assets/images/icon-minang.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.restaurant,
                    size: isSmallScreen ? 40 : 60,
                    color: Theme.of(context).primaryColor,
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Text(
          'Klasifikasi Makanan Minangkabau',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 22,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
          child: Text(
            'Unggah foto makanan untuk mengidentifikasi jenis makanan Minangkabau tradisional',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: isSmallScreen ? 13 : 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context, ClassificationProvider provider, Size size, bool isSmallScreen) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: isDark ? 2 : 4,
      color: isDark ? Colors.grey.shade800 : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          children: [
            Icon(
              Icons.photo_camera,
              size: isSmallScreen ? 48 : 64,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'Pilih Gambar Makanan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: isSmallScreen ? 18 : 20,
              ),
            ),
            SizedBox(height: isSmallScreen ? 4 : 8),
            Text(
              'Gunakan kamera atau pilih dari galeri',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showImagePicker,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(
                  'Pilih Gambar',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 14 : 16,
                    horizontal: 24,
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(ClassificationProvider provider, bool isDark) {
    if (provider.error != null) {
      return Card(
        color: isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.error, color: isDark ? Colors.red.shade300 : Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: TextStyle(
                        color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _showImagePicker,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.red.shade300 : Colors.red.shade700,
                    side: BorderSide(
                      color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                    ),
                  ),
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