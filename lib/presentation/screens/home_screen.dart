// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/classification_provider.dart';
import '../providers/home_provider.dart';
import '../../presentation/widgets/home/prediction_result_card.dart';
import '../../presentation/widgets/home/image_picker_bottom_sheet.dart';
import '../widgets/loading_overlay.dart';
import '../../presentation/widgets/home/home_header_section.dart';
import '../../presentation/widgets/home/home_action_section.dart';
import '../../presentation/widgets/home/home_error_widget.dart';
import '../../presentation/widgets/home/home_app_bar.dart';
import 'history_screen.dart';
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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Provider.of<HomeProvider>(context, listen: false).initializeApp();
    await Provider.of<ClassificationProvider>(
      context,
      listen: false,
    ).loadPredictionHistory();
  }

  void _showImagePicker() {
    Provider.of<HomeProvider>(
      context,
      listen: false,
    ).logInteraction('image_picker_opened');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => ImagePickerBottomSheet(
            onImageSelected: _classifyImage,
            onCameraSelected: _openCamera,
          ),
    );
  }

  Future<void> _classifyImage(String imagePath) async {
    final classificationProvider = Provider.of<ClassificationProvider>(
      context,
      listen: false,
    );
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    homeProvider.logInteraction('image_classification_started');

    await classificationProvider.classifyImage(imagePath);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      classificationProvider.loadPredictionHistory();
    });
  }

  void _openCamera() {
    Provider.of<HomeProvider>(
      context,
      listen: false,
    ).logInteraction('camera_opened');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(onImageCaptured: _classifyImage),
      ),
    );
  }

  void _openHistory() {
    Provider.of<HomeProvider>(
      context,
      listen: false,
    ).logInteraction('history_opened');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
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
              onPressed: _openHistory,
              tooltip: 'Riwayat Prediksi',
            ),
          ),
        ],
      ),
      body: Consumer2<ClassificationProvider, HomeProvider>(
        builder: (context, classificationProvider, homeProvider, child) {
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
                    HomeHeaderSection(
                      isSmallScreen: isSmallScreen,
                      isDark: isDark,
                    ),
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    HomeActionSection(
                      onPickImage: _showImagePicker,
                      isSmallScreen: isSmallScreen,
                      isDark: isDark,
                    ),
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    _buildResultSection(classificationProvider, isDark),
                  ],
                ),
              ),
              if (classificationProvider.isLoading ||
                  homeProvider.isInitializing)
                const LoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultSection(ClassificationProvider provider, bool isDark) {
    if (provider.error != null) {
      return HomeErrorWidget(
        errorMessage: provider.error!,
        onRetry: _showImagePicker,
        isDark: isDark,
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
