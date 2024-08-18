import 'dart:io';

import 'package:filemanager/domain/repository/local_repository.dart';
import 'package:filemanager/failure.dart';
import 'package:filemanager/usecase.dart';
import 'package:fpdart/fpdart.dart';

class CopyFileUseCase implements UseCase<void, CopyFileParms> {
  final FileManagerLocalRepository _localRepository;

  CopyFileUseCase(FileManagerLocalRepository localRepository)
      : _localRepository = localRepository;
  @override
  Future<Either<Failure, void>> call(CopyFileParms parms) async {
    return await _localRepository.copyFile(parms.files, parms.destination);
  }
}

class CopyFileParms {
  final Set<FileSystemEntity> files;
  final Directory destination;

  CopyFileParms({required this.files, required this.destination});
}
