import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_colors.dart';

class CustomCamera extends StatefulWidget {
  final Function(File) onImageCaptured;
  final VoidCallback onCancel;

  const CustomCamera({
    Key? key,
    required this.onImageCaptured,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<CustomCamera> createState() => _CustomCameraState();
}

class _CustomCameraState extends State<CustomCamera>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      PermissionStatus cameraStatus = await Permission.camera.status;
      if (cameraStatus.isDenied) {
        cameraStatus = await Permission.camera.request();
      }

      if (!cameraStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Izin kamera diperlukan untuk menggunakan fitur ini'),
              backgroundColor: AppColors.color_FFAB2A,
            ),
          );
          widget.onCancel();
        }
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada kamera yang tersedia'),
              backgroundColor: AppColors.color_FFAB2A,
            ),
          );
          widget.onCancel();
        }
        return;
      }

      // Initialize camera controller
      _controller = CameraController(
        _cameras![_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menginisialisasi kamera: ${e.toString()}'),
            backgroundColor: AppColors.color_FFAB2A,
          ),
        );
        widget.onCancel();
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile image = await _controller!.takePicture();
      final File imageFile = File(image.path);

      if (mounted) {
        widget.onImageCaptured(imageFile);
      }
    } catch (e) {
      debugPrint('Take picture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: ${e.toString()}'),
            backgroundColor: AppColors.color_FFAB2A,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _switchCamera() {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    });

    _controller?.dispose();
    _initializeCamera();
  }

  void _toggleFlash() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _isFlashOn = !_isFlashOn;
    });

    _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.color_0FB7A6,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(_controller!),
          ),

          // Top controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  GestureDetector(
                    onTap: widget.onCancel,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  // Flash toggle
                  if (_controller!.value.isInitialized)
                    GestureDetector(
                      onTap: _toggleFlash,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Switch camera button
                  if (_cameras != null && _cameras!.length > 1)
                    GestureDetector(
                      onTap: _switchCamera,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),

                  // Capture button
                  GestureDetector(
                    onTap: _isCapturing ? null : _takePicture,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color:
                            _isCapturing ? Colors.grey : AppColors.color_0FB7A6,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: _isCapturing
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            )
                          : const Icon(
                              Icons.camera,
                              color: Colors.white,
                              size: 40,
                            ),
                    ),
                  ),

                  // Placeholder for balance
                  if (_cameras != null && _cameras!.length > 1)
                    const SizedBox(width: 60),
                ],
              ),
            ),
          ),

          // Center guide
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
