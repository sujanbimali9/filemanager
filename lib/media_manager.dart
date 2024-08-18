import 'dart:developer';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MediaHandler {
  final String cacheDirectoryName = 'media';
  String? cachePath;

  Future<String> _getCacheDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/$cacheDirectoryName');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  Future<File> _getCacheFile(File file) async {
    cachePath ??= await _getCacheDirectoryPath();
    return File('$cachePath/${file.path.hashCode}.jpg');
  }

  Future<File> getCompressedImage(File file) async {
    if ((await file.stat()).size < 100) {
      print('File size is less than 100 bytes, skipping compression');
      return file;
    }

    final cacheFile = await _getCacheFile(file);

    if (await cacheFile.exists()) {
      print('Cache file exists, returning cache file');
      return cacheFile;
    }

    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        cacheFile.path,
        quality: 75,
      );
      if (result != null) {
        print('Image compressed successfully');
        print('Original size: ${(await cacheFile.stat()).size} bytes');
        return cacheFile;
      } else {
        throw Exception('Image compression failed');
      }
    } catch (e) {
      log('Error compressing image: $e');
      return file;
    }
  }

  Future<File> getVideoThumbnail(File videoFile) async {
    final cacheFile = await _getCacheFile(videoFile);

    if (await cacheFile.exists()) {
      return cacheFile;
    }

    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: cacheFile.path,
        imageFormat: ImageFormat.JPEG,
        quality: 50,
      );

      if (thumbnailPath != null) {
        return File(thumbnailPath);
      } else {
        throw Exception('Thumbnail generation failed');
      }
    } catch (e) {
      log('Error generating video thumbnail: $e');
      return videoFile;
    }
  }

  Future<File> getCachedFile(File file) async {
    final cacheFile = await _getCacheFile(file);
    return await cacheFile.exists() ? cacheFile : file;
  }

  Future<void> clearCache() async {
    cachePath ??= await _getCacheDirectoryPath();
    final dir = Directory(cachePath!);
    if (await dir.exists()) {
      try {
        dir.deleteSync(recursive: true);
      } catch (e) {
        log('Error clearing cache: $e');
      }
    }
  }
}
