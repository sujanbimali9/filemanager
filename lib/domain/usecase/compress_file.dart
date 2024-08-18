import 'dart:io';

import 'package:filemanager/domain/repository/local_repository.dart';
import 'package:filemanager/failure.dart';
import 'package:filemanager/usecase.dart';
import 'package:fpdart/fpdart.dart';

class CompressFileUseCase
    implements UseCase<FileSystemEntity, CompressFileParms> {
  final FileManagerLocalRepository _localRepository;

  CompressFileUseCase(FileManagerLocalRepository localRepository)
      : _localRepository = localRepository;
  @override
  Future<Either<Failure, FileSystemEntity>> call(
      CompressFileParms parms) async {
    return await _localRepository.compressFile(parms.files);
  }
}

class CompressFileParms {
  final Set<FileSystemEntity> files;

  CompressFileParms({required this.files});
}
