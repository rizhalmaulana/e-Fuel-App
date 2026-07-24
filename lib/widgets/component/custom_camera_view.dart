import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

List<CameraDescription> cameras = [];

class CustomCameraView extends StatefulWidget {
  final String label;
  const CustomCameraView({super.key, required this.label});

  @override
  State<CustomCameraView> createState() => _CustomCameraViewState();
}

class _CustomCameraViewState extends State<CustomCameraView> with WidgetsBindingObserver {
  CameraController? controller;

  bool isCameraInitialized = false;
  bool isTakingPicture = false;
  String? errorMessage;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // If camera controller is not initialized, do nothing
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      // Free camera resource when app goes to background
      cameraController.dispose();
      if (mounted) {
        setState(() {
          isCameraInitialized = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      // Re-initialize camera when app returns to foreground
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (mounted) {
      setState(() {
        hasError = false;
        errorMessage = null;
      });
    }

    if (cameras.isEmpty) {
      try {
        cameras = await availableCameras();
      } catch (e, stack) {
        print("Camera Error: $e");
        try {
          await FirebaseCrashlytics.instance.recordError(
            e,
            stack,
            reason: 'Failed to retrieve available cameras in CustomCameraView',
          );
        } catch (_) {}
        if (mounted) {
          setState(() {
            hasError = true;
            errorMessage = "Kamera tidak terdeteksi pada perangkat Anda.";
          });
        }
        return;
      }
    }

    if (cameras.isEmpty) {
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = "Tidak ada kamera yang tersedia pada perangkat Anda.";
        });
      }
      return;
    }

    // Use ResolutionPreset.medium (usually 720p or 480p) to prevent OOM errors on lower-end devices
    controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller!.initialize();
      if (!mounted) return;
      setState(() {
        isCameraInitialized = true;
      });
    } catch (e, stack) {
      print("Camera Error: $e");
      try {
        await FirebaseCrashlytics.instance.recordError(
          e,
          stack,
          reason: 'Failed to initialize CameraController in CustomCameraView',
        );
      } catch (_) {}
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = "Gagal membuka kamera, karena kesalahan teknis kamera. Silahkan ketuk Coba Lagi!";
        });
      }
    }
  }

  Future<void> _takePicture() async {
    if (!isCameraInitialized || controller == null || isTakingPicture) return;

    setState(() {
      isTakingPicture = true;
    });

    try {
      final image = await controller!.takePicture();
      if (mounted) {
        Navigator.of(context).pop(image.path);
      }
    } catch (e, stack) {
      print("Camera Error: $e");
      try {
        await FirebaseCrashlytics.instance.recordError(
          e,
          stack,
          reason: 'Failed to take picture in CustomCameraView',
        );
      } catch (_) {}
      if (mounted) {
        setState(() {
          isTakingPicture = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengambil gambar: $e"),
            backgroundColor: AppColors.alertSoftRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.alertSoftRed, size: 64),
                const SizedBox(height: 16),
                Text(
                  errorMessage ?? "Terjadi kesalahan pada kamera.",
                  style: AppFonts.fUrbanistBold16.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _initCamera,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Coba Lagi",
                      style: AppFonts.fUrbanistBold16.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Tutup",
                    style: AppFonts.fUrbanistMedium16.copyWith(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!isCameraInitialized || controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(controller!),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 20,
                  left: 20,
                  right: 20
              ),
              color: Colors.black45,
              child: Column(
                children: [
                  Text(
                    "Ambil Foto",
                    style: AppFonts.fUrbanistRegular12.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  // INI LABEL YANG ANDA INGINKAN MUNCUL DI KAMERA
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: AppFonts.fUrbanistBold18.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),

                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400, width: 4),
                    ),
                    child: Center(
                      child: isTakingPicture
                          ? const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                      )
                          : const Icon(Icons.camera_alt, size: 30, color: AppColors.primary),
                    ),
                  ),
                ),

                const SizedBox(width: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}