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

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isLoading = true;
  bool _isCameraReady = false;
  bool _isFlashOn = false;
  bool _isTakingPicture = false;
  bool _isSwitchingCamera = false;
  bool _isDisposed = false;
  CameraLensDirection _currentLens = CameraLensDirection.back;
  String? _errorMessage;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.dispose();
  }

  Future<void> _disposeController() async {
    try {
      if (_controller != null) {
        final controller = _controller!;
        _controller = null;
        
        if (controller.value.isInitialized) {
          await controller.dispose();
        }
      }
    } catch (e) {
      debugPrint('Error disposing controller: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    if (state == AppLifecycleState.inactive) {
      _disposeController();
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_isDisposed) return;

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _hasError = false;
          _errorMessage = null;
          _isCameraReady = false;
        });
      }

      final permissionStatus = await Permission.camera.status;
      if (!permissionStatus.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          if (mounted && !_isDisposed) {
            setState(() {
              _hasError = true;
              _errorMessage = 'Izin kamera diperlukan untuk menggunakan fitur ini';
              _isLoading = false;
            });
          }
          return;
        }
      }

      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('Tidak ada kamera yang tersedia');
      }

      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      await _initializeCameraController(backCamera);
    } catch (e) {
      _handleError('Gagal menginisialisasi kamera: $e');
    }
  }

  Future<void> _initializeCameraController(CameraDescription camera) async {
    if (_isDisposed) return;

    try {
      await _disposeController();

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (_isDisposed) {
        await _disposeController();
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isCameraReady = true;
          _hasError = false;
          _errorMessage = null;
          _currentLens = camera.lensDirection;
          _isSwitchingCamera = false;
        });
      }
    } catch (e) {
      _handleError('Gagal menginisialisasi kontrol kamera: $e');
    }
  }

  void _handleError(String message) {
    if (_isDisposed || !mounted) return;

    setState(() {
      _isLoading = false;
      _isCameraReady = false;
      _hasError = true;
      _errorMessage = message;
      _isSwitchingCamera = false;
      _isTakingPicture = false;
    });
  }

  bool get _isControllerValid {
    return _controller != null && 
           !_isDisposed &&
           _controller!.value.isInitialized;
  }

  Future<void> _takePicture() async {
    if (!_isControllerValid || _isTakingPicture || _isSwitchingCamera) {
      _showSnackBar('Kamera belum siap');
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isTakingPicture = true;
        });
      }

      final XFile picture = await _controller!.takePicture();
      
      if (_isDisposed) return;
      
      if (mounted) {
        widget.onImageCaptured(picture.path);
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isTakingPicture = false;
        });
        _showSnackBar('Gagal mengambil foto: $e');
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || 
        _cameras!.length < 2 || 
        _isSwitchingCamera || 
        _isTakingPicture ||
        _hasError ||
        _isDisposed) {
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isSwitchingCamera = true;
        });
      }

      final currentIndex = _cameras!.indexWhere(
        (camera) => camera.lensDirection == _currentLens,
      );

      CameraDescription nextCamera;
      if (currentIndex == -1 || currentIndex + 1 >= _cameras!.length) {
        nextCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras!.first,
        );
      } else {
        nextCamera = _cameras![currentIndex + 1];
      }

      await _initializeCameraController(nextCamera);
      
    } catch (e) {
      _handleError('Gagal mengganti kamera: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (!_isControllerValid || _isTakingPicture || _isSwitchingCamera) return;

    try {
      if (_controller!.value.flashMode == FlashMode.off) {
        await _controller!.setFlashMode(FlashMode.torch);
        if (mounted && !_isDisposed) {
          setState(() {
            _isFlashOn = true;
          });
        }
      } else {
        await _controller!.setFlashMode(FlashMode.off);
        if (mounted && !_isDisposed) {
          setState(() {
            _isFlashOn = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error toggling flash: $e');
      _showSnackBar('Gagal mengatur flash');
    }
  }

  void _showSnackBar(String message) {
    if (mounted && !_isDisposed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _retryInitialize() async {
    if (_isDisposed) return;
    
    if (mounted) {
      setState(() {
        _hasError = false;
        _errorMessage = null;
        _isLoading = true;
      });
    }
    await _initializeCamera();
  }

  Widget _buildCameraPreview() {
    if (_hasError) {
      return _buildErrorState();
    }

    if (!_isControllerValid) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    try {
      final size = MediaQuery.of(context).size;
      var scale = 1.0;

      if (_controller!.value.aspectRatio < size.aspectRatio) {
        scale = size.aspectRatio / _controller!.value.aspectRatio;
      }

      return Transform.scale(
        scale: scale,
        child: Center(
          child: CameraPreview(_controller!),
        ),
      );
    } catch (e) {
      debugPrint('Error building camera preview: $e');
      return _buildErrorState();
    }
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Kamera Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Terjadi kesalahan pada kamera',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _retryInitialize,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Kembali',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraControls() {
    final size = MediaQuery.of(context).size;
    final captureButtonSize = size.width * 0.2;
    final iconButtonSize = size.width * 0.12;
    final bottomPadding = size.height * 0.05;

    return Positioned(
      bottom: bottomPadding,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton(
                    onPressed: _toggleFlash,
                    icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    size: iconButtonSize,
                    isDisabled: _isTakingPicture || _isSwitchingCamera,
                  ),
                  _buildCaptureButton(
                    size: captureButtonSize,
                    isDisabled: _isTakingPicture || _isSwitchingCamera,
                  ),
                  _buildIconButton(
                    onPressed: _switchCamera,
                    icon: Icons.cameraswitch,
                    size: iconButtonSize,
                    isDisabled: _isTakingPicture || 
                               _isSwitchingCamera || 
                               (_cameras?.length ?? 0) < 2,
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
              child: Text(
                'Ketuk lingkaran untuk mengambil foto',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: size.width * 0.035,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required VoidCallback onPressed,
    required IconData icon,
    required double size,
    bool isDisabled = false,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: isDisabled ? null : onPressed,
          icon: Icon(
            icon,
            color: isDisabled ? Colors.grey : Colors.white,
            size: size * 0.5,
          ),
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton({required double size, bool isDisabled = false}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.7 : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : _takePicture,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDisabled ? Colors.grey : Colors.white,
              width: 4,
            ),
            boxShadow: [
              if (!isDisabled)
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDisabled ? Colors.grey : Colors.white,
            ),
            child: _isTakingPicture
                ? Padding(
                    padding: EdgeInsets.all(size * 0.15),
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : null,
          ),
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
          _buildCameraPreview(),
          if (!_hasError)
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
          if (_isCameraReady && !_hasError && !_isSwitchingCamera) 
            _buildCameraControls(),
          if (_isSwitchingCamera)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          if (_isLoading && !_hasError && !_isSwitchingCamera) 
            const LoadingOverlay(),
        ],
      ),
    );
  }
}