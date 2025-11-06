import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/custom_app_bar.dart';

class CameraScreen extends StatefulWidget {
  final Function(String) onImageCaptured;

  const CameraScreen({
    super.key,
    required this.onImageCaptured,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isLoading = true;
  bool _isCameraReady = false;
  bool _isFlashOn = false;
  CameraLensDirection _currentLens = CameraLensDirection.back;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      // Check camera permission
      final permissionStatus = await Permission.camera.status;
      if (!permissionStatus.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Izin kamera diperlukan untuk menggunakan fitur ini'),
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.pop(context);
          }
          return;
        }
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        throw Exception('Tidak ada kamera yang tersedia');
      }

      // Initialize back camera first
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      await _initializeCameraController(backCamera);
    } catch (e) {
      _showError('Gagal menginisialisasi kamera: $e');
    }
  }

  Future<void> _initializeCameraController(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isCameraReady = true;
          _currentLens = camera.lensDirection;
        });
      }
    } catch (e) {
      _showError('Gagal menginisialisasi kontrol kamera: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraReady || _controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamera belum siap'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final XFile picture = await _controller!.takePicture();
      
      // Langsung kirim path gambar tanpa menyimpan ke variabel yang tidak digunakan
      if (mounted) {
        widget.onImageCaptured(picture.path);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    try {
      setState(() {
        _isCameraReady = false;
      });

      final currentIndex = _cameras!.indexWhere(
        (camera) => camera.lensDirection == _currentLens,
      );

      final nextIndex = (currentIndex + 1) % _cameras!.length;
      final nextCamera = _cameras![nextIndex];

      await _initializeCameraController(nextCamera);
    } catch (e) {
      _showError('Gagal mengganti kamera: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      if (_controller!.value.flashMode == FlashMode.off) {
        await _controller!.setFlashMode(FlashMode.torch);
        setState(() {
          _isFlashOn = true;
        });
      } else {
        await _controller!.setFlashMode(FlashMode.off);
        setState(() {
          _isFlashOn = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengatur flash: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: CameraPreview(_controller!),
    );
  }

  Widget _buildCameraControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Column(
          children: [
            // Camera switch and flash buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Flash Button
                IconButton(
                  onPressed: _toggleFlash,
                  icon: Icon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black38,
                    padding: const EdgeInsets.all(16),
                  ),
                ),

                // Capture Button
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Switch Camera Button
                IconButton(
                  onPressed: _switchCamera,
                  icon: const Icon(
                    Icons.cameraswitch,
                    color: Colors.white,
                    size: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black38,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Instruction text
            Text(
              'Ketuk lingkaran untuk mengambil foto',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          _buildCameraPreview(),

          // App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomAppBar(
              title: 'Kamera',
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
              backgroundColor: Colors.transparent,
              textColor: Colors.white,
              elevation: 0,
            ),
          ),

          // Camera Controls
          if (_isCameraReady) _buildCameraControls(),

          // Loading Overlay
          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }
}