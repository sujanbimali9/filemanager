import 'dart:io';

import 'package:filemanager/data/data_source/local_data_source.dart';
import 'package:filemanager/domain/repository/local_repository.dart';
import 'package:filemanager/exception.dart';
import 'package:filemanager/failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:share_plus/share_plus.dart';

class FileManagerLocalRepositoryImp implements FileManagerLocalRepository {
  final FileManagerLocalDataSource _localDataSource;

  FileManagerLocalRepositoryImp(FileManagerLocalDataSource localDataSource)
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, void>> deleteFile(Set<FileSystemEntity> file) async {
    try {
      return right(await _localDataSource.deleteFile(file));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Directory>> createDirectory(
      Directory directory, String directoryName) async {
    try {
      return right(
          await _localDataSource.createDirectory(directory, directoryName));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> copyFile(
      Set<FileSystemEntity> files, Directory destination) async {
    try {
      return right(await _localDataSource.copyFile(files, destination));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> moveFile(
      Set<FileSystemEntity> files, Directory destination) async {
    try {
      return right(await _localDataSource.moveFile(files, destination));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, FileSystemEntity>> renameFile(
      FileSystemEntity file, String newName) async {
    try {
      return right(await _localDataSource.renameFile(file, newName));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, FileSystemEntity>> compressFile(
      Set<FileSystemEntity> file) async {
    try {
      return right(await _localDataSource.compressFile(file));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> extractFile(FileSystemEntity file) async {
    try {
      return right(await _localDataSource.extractFile(file));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, ShareResult>> shareFile(
      Set<FileSystemEntity> file) async {
    try {
      return right(await _localDataSource.shareFile(file));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
