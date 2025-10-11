import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:romlerk/core/theme/app_colors.dart';

class DocumentImageViewerScreen extends StatelessWidget {
  final String imageUrl;

  const DocumentImageViewerScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🔹 Fullscreen zoomable image
          Positioned.fill(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(color: AppColors.green),
              ),
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image,
                    size: 60, color: AppColors.darkGray),
              ),
            ),
          ),

          // 🔹 Close button (top-left)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  tooltip: "Close",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
