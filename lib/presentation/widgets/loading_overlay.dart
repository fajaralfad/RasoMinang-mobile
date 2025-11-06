import 'package:flutter/material.dart';

/// Widget overlay loading yang menutupi seluruh screen
class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54, // Background semi-transparan
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Loading Indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              
              // Pesan loading
              Text(
                message ?? 'Mengklasifikasikan...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              // Sub-pesan
              Text(
                'Harap tunggu sebentar',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alternative loading overlay dengan design yang lebih modern
class ModernLoadingOverlay extends StatelessWidget {
  final String title;
  final String subtitle;

  const ModernLoadingOverlay({
    super.key,
    this.title = 'Memproses',
    this.subtitle = 'Sedang menganalisis gambar makanan',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated food icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                      strokeWidth: 4,
                    ),
                  ),
                  Icon(
                    Icons.restaurant,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Progress text
              Text(
                'Ini mungkin memakan waktu beberapa detik',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading overlay untuk operasi yang lebih cepat
class SimpleLoadingOverlay extends StatelessWidget {
  const SimpleLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}

/// Hook untuk menampilkan loading overlay secara manual
class LoadingOverlayHelper {
  static void show({
    required BuildContext context,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Mencegah dismiss dengan back button
        child: LoadingOverlay(message: message),
      ),
    );
  }

  static void showModern({
    required BuildContext context,
    String title = 'Memproses',
    String subtitle = 'Sedang menganalisis gambar makanan',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: ModernLoadingOverlay(
          title: title,
          subtitle: subtitle,
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

/// Widget wrapper untuk dengan mudah menambahkan loading overlay
class LoadingOverlayHandler extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;

  const LoadingOverlayHandler({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) LoadingOverlay(message: loadingMessage),
      ],
    );
  }
}