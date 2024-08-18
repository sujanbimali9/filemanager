import 'dart:io';
import 'package:filemanager/media_manager.dart';
import 'package:flutter/material.dart';

class ItemIcon extends StatelessWidget {
  const ItemIcon({super.key, required this.file});
  final FileSystemEntity file;

  @override
  Widget build(BuildContext context) {
    return getFileIcon(file);
  }

  static final Map<String, String> _extensionToIconMap = {
    // Images
    'jpg': 'assets/icons/image.png',
    'jpeg': 'assets/icons/image.png',
    'png': 'assets/icons/image.png',
    'gif': 'assets/icons/image.png',
    'webp': 'assets/icons/image.png',
    // Videos
    'mp4': 'assets/icons/video.png',
    'mkv': 'assets/icons/video.png',
    'avi': 'assets/icons/video.png',
    'webm': 'assets/icons/video.png',
    'flv': 'assets/icons/video.png',
    'mov': 'assets/icons/video.png',
    // Audio
    'mp3': 'assets/icons/audio.png',
    'wav': 'assets/icons/audio.png',
    'ogg': 'assets/icons/audio.png',
    'flac': 'assets/icons/audio.png',
    'm4a': 'assets/icons/audio.png',
    // Documents
    'pdf': 'assets/icons/pdf.png',
    'doc': 'assets/icons/document.png',
    'docx': 'assets/icons/document.png',
    'xls': 'assets/icons/document.png',
    'xlsx': 'assets/icons/document.png',
    'ppt': 'assets/icons/document.png',
    'pptx': 'assets/icons/document.png',
    'txt': 'assets/icons/document.png',
    // Compressed Files
    'zip': 'assets/icons/compress.png',
    'rar': 'assets/icons/compress.png',
    '7z': 'assets/icons/compress.png',
    'tar': 'assets/icons/compress.png',
    'gz': 'assets/icons/compress.png',
    'bz2': 'assets/icons/compress.png',
    'xz': 'assets/icons/compress.png',
    // APK
    'apk': 'assets/icons/apk.png',
    // Unknown
    'unknown': 'assets/icons/unknown.png',
  };

  Widget getFileIcon(FileSystemEntity entity) {
    if (entity is Directory) {
      return buildIconContainer(assetPath: 'assets/icons/folder.png');
    }

    final ext = entity.path.split('.').last.toLowerCase();
    final iconPath =
        _extensionToIconMap[ext] ?? _extensionToIconMap['unknown']!;

    if (_isImageFile(ext)) {
      return buildImage(entity as File);
    } else if (_isVideoFile(ext)) {
      return buildVideo(entity as File);
    } else {
      return buildIconContainer(assetPath: iconPath);
    }
  }

  bool _isImageFile(String ext) {
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  bool _isVideoFile(String ext) {
    return ['mp4', 'mkv', 'avi', 'webm', 'flv', 'mov'].contains(ext);
  }

  Widget buildVideo(File entity) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder<File?>(
              future: MediaHandler().getVideoThumbnail(entity),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 50,
                    width: 50,
                    color: Colors.grey.shade200,
                  );
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return Container(
                    height: 50,
                    width: 50,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  );
                }
                return Image.file(
                  snapshot.data!,
                  height: 50,
                  cacheHeight: 200,
                  cacheWidth: 200,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 50,
                      width: 50,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    );
                  },
                );
              }),
          Positioned(
            bottom: 4,
            right: 4,
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
          )
        ],
      ),
    );
  }

  Widget buildImage(File entity) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: FutureBuilder<File?>(
          future: MediaHandler().getCompressedImage(entity),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 50,
                width: 50,
                color: Colors.grey.shade200,
              );
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Container(
                height: 50,
                width: 50,
                color: Colors.grey.shade200,
              );
            }
            return Image.file(
              snapshot.data!,
              height: 50,
              width: 50,
              cacheHeight: 200,
              cacheWidth: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 50,
                  width: 50,
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                );
              },
            );
          }),
    );
  }

  Widget buildIconContainer({
    required String assetPath,
    Color? color,
    Color? iconColor,
  }) {
    return Container(
      height: 50,
      width: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color ?? Colors.blue.shade100,
      ),
      child: Image.asset(
        assetPath,
        color: iconColor ?? Colors.blue.shade900,
        height: 25,
        width: 25,
      ),
    );
  }
}
