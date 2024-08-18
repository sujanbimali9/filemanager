import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:filemanager/exception.dart';
import 'package:share_plus/share_plus.dart';

abstract class FileManagerLocalDataSource {
  Future<void> deleteFile(Set<FileSystemEntity> file);
  Future<Directory> createDirectory(Directory directory, String directoryName);
  Future<void> copyFile(Set<FileSystemEntity> files, Directory destination);
  Future<void> moveFile(Set<FileSystemEntity> files, Directory destination);
  Future<FileSystemEntity> renameFile(FileSystemEntity file, String newName);
  Future<FileSystemEntity> compressFile(Set<FileSystemEntity> file);
  Future<void> extractFile(FileSystemEntity file);
  Future<ShareResult> shareFile(Set<FileSystemEntity> file);
}

class FileManagerLocalDataSourceImp implements FileManagerLocalDataSource {
  @override
  Future<void> deleteFile(Set<FileSystemEntity> file) async {
    try {
      for (final f in file) {
        await f.delete(recursive: true);
      }
      return;
    } catch (e) {
      throw ServerException('Failed to delete file: ${e.toString()}');
    }
  }

  @override
  Future<Directory> createDirectory(
      Directory directory, String directoryName) async {
    try {
      final newDirectory = Directory('${directory.path}/$directoryName');
      final newDir = await newDirectory.create();
      return newDir;
    } catch (e) {
      throw ServerException('Failed to create directory: ${e.toString()}');
    }
  }

  @override
  Future<void> copyFile(
      Set<FileSystemEntity> files, Directory destination) async {
    try {
      for (final file in files) {
        final newPath = '${destination.path}/${file.uri.pathSegments.last}';
        if (file is Directory) {
          await _copyDirectory(file, Directory(newPath));
        } else if (file is File) {
          await file.copy(newPath);
        }
      }
    } catch (e) {
      throw ServerException('Failed to copy file(s): ${e.toString()}');
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    try {
      if (!await destination.exists()) {
        await destination.create(recursive: true);
      }
      await for (final entity
          in source.list(recursive: false, followLinks: false)) {
        final newPath = '${destination.path}/${entity.uri.pathSegments.last}';
        if (entity is File) {
          await entity.copy(newPath);
        } else if (entity is Directory) {
          await _copyDirectory(entity, Directory(newPath));
        }
      }
    } catch (e) {
      throw ServerException('Failed to copy directory: ${e.toString()}');
    }
  }

  @override
  Future<void> moveFile(
      Set<FileSystemEntity> files, Directory destination) async {
    log('moveFile');
    try {
      for (final file in files) {
        final newPath = '${destination.path}/${file.uri.pathSegments.last}';
        await file.rename(newPath);
      }
    } catch (e) {
      throw ServerException('Failed to move file(s): ${e.toString()}');
    }
  }

  @override
  Future<FileSystemEntity> renameFile(
      FileSystemEntity file, String newName) async {
    try {
      final updatedFile = await file.rename(newName);
      return updatedFile;
    } catch (e) {
      throw ServerException('Failed to rename file: ${e.toString()}');
    }
  }

  @override
  Future<FileSystemEntity> compressFile(Set<FileSystemEntity> file) async {
    try {
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Failed to compress file: ${e.toString()}');
    }
  }

  @override
  Future<void> extractFile(FileSystemEntity file) async {
    try {
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Failed to extract file: ${e.toString()}');
    }
  }

  @override
  Future<ShareResult> shareFile(Set<FileSystemEntity> file) async {
    try {
      final result =
          await Share.shareXFiles(file.map((e) => XFile(e.path)).toList());
      return result;
    } catch (e) {
      throw ServerException('Failed to share file: ${e.toString()}');
    }
  }
}
