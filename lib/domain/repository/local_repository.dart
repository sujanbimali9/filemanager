import 'dart:io';

import 'package:filemanager/failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class FileManagerLocalRepository {
  Future<Either<Failure, void>> deleteFile(Set<FileSystemEntity> file);
  Future<Either<Failure, Directory>> createDirectory(
      Directory directory, String directoryName);
  Future<Either<Failure, void>> copyFile(
      Set<FileSystemEntity> files, Directory destination);
  Future<Either<Failure, void>> moveFile(
      Set<FileSystemEntity> files, Directory destination);
  Future<Either<Failure, FileSystemEntity>> renameFile(
      FileSystemEntity file, String newName);
  Future<Either<Failure, FileSystemEntity>> compressFile(
      Set<FileSystemEntity> file);
  Future<Either<Failure, void>> extractFile(FileSystemEntity file);
  Future<Either<Failure, ShareResult>> shareFile(Set<FileSystemEntity> file);
}
